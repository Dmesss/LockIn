import Foundation
import Network
import AppKit

public class SyncServer {
    public static let shared = SyncServer()

    // MARK: - Sprites Directory Resolution
    public static var spritesDirectory: String = {
        if let resPath = Bundle.main.resourcePath {
            let bundleSprites = (resPath as NSString).appendingPathComponent("Sprites")
            if FileManager.default.fileExists(atPath: bundleSprites) { return bundleSprites }
        }
        let cwdSprites = (FileManager.default.currentDirectoryPath as NSString).appendingPathComponent("dist/Sprites")
        if FileManager.default.fileExists(atPath: cwdSprites) { return cwdSprites }
        if let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let userSprites = appSupport.appendingPathComponent("LockIn/Sprites").path
            try? FileManager.default.createDirectory(atPath: userSprites, withIntermediateDirectories: true)
            return userSprites
        }
        return "/tmp/LockIn/Sprites"
    }()

    // MARK: - Sprite Sheet Atlas Support
    private static var atlasImage: CGImage? = {
        let path = (SyncServer.spritesDirectory as NSString).appendingPathComponent("DuckSpritesheet.png")
        guard let dataProvider = CGDataProvider(url: URL(fileURLWithPath: path) as CFURL),
              let cg = CGImage(pngDataProviderSource: dataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent) else {
            return nil
        }
        return cg
    }()

    private static var atlasFrames: [String: CGRect] = {
        let path = (SyncServer.spritesDirectory as NSString).appendingPathComponent("atlas.json")
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let frames = json["frames"] as? [String: [String: Int]] else {
            return [:]
        }
        var res: [String: CGRect] = [:]
        for (name, box) in frames {
            if let x = box["x"], let y = box["y"], let w = box["w"], let h = box["h"] {
                res[name] = CGRect(x: x, y: y, width: w, height: h)
            }
        }
        return res
    }()

    private static var spriteCropCache: [String: Data] = [:]
    private static let cacheLock = NSLock()

    private var listener: NWListener?
    private var sseClients: [NWConnection] = []
    public let port: UInt16 = 8765
    private var isRunning = false

    private init() {}

    public func start() {
        guard !isRunning else { return }
        isRunning = true

        let params = NWParameters.tcp
        do {
            let l = try NWListener(using: params, on: NWEndpoint.Port(rawValue: port)!)
            l.service = NWListener.Service(type: "_duckpet._tcp")

            l.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    print("[SyncServer] Local Wi-Fi Sync Server ready on port \(self.port) (Bonjour: _duckpet._tcp)")
                case .failed(let err):
                    print("[SyncServer] Listener failed: \(err)")
                default: break
                }
            }

            l.newConnectionHandler = { [weak self] conn in
                self?.handleConnection(conn)
            }

            l.start(queue: .main)
            self.listener = l
        } catch {
            print("[SyncServer] Failed to initialize NWListener: \(error)")
        }
    }

    public func stop() {
        listener?.cancel()
        listener = nil
        for client in sseClients { client.cancel() }
        sseClients.removeAll()
        isRunning = false
    }

    private func handleConnection(_ conn: NWConnection) {
        conn.start(queue: .main)
        conn.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, _, err in
            guard let self = self, let data = data, !data.isEmpty,
                  let req = String(data: data, encoding: .utf8) else {
                conn.cancel()
                return
            }
            self.routeRequest(req: req, conn: conn)
        }
    }

    private func routeRequest(req: String, conn: NWConnection) {
        let lines = req.components(separatedBy: "\r\n")
        guard let firstLine = lines.first else { conn.cancel(); return }
        let tokens = firstLine.components(separatedBy: " ")
        guard tokens.count >= 2 else { conn.cancel(); return }
        let method = tokens[0]
        let pathWithQuery = tokens[1]
        let path = pathWithQuery.components(separatedBy: "?").first ?? pathWithQuery

        // Extract body for POST requests
        var body = ""
        if let emptyLineIdx = lines.firstIndex(of: "") {
            body = lines[(emptyLineIdx + 1)...].joined(separator: "\r\n")
        }

        // 1. CORS Preflight
        if method == "OPTIONS" {
            let resp = "HTTP/1.1 204 No Content\r\nAccess-Control-Allow-Origin: *\r\nAccess-Control-Allow-Methods: GET, POST, OPTIONS\r\nAccess-Control-Allow-Headers: Content-Type\r\n\r\n"
            sendResponse(resp.data(using: .utf8)!, conn: conn, close: true)
            return
        }

        // 2. Server-Sent Events (SSE) Stream
        if path == "/api/events" {
            let header = "HTTP/1.1 200 OK\r\nContent-Type: text/event-stream\r\nCache-Control: no-cache\r\nConnection: keep-alive\r\nAccess-Control-Allow-Origin: *\r\n\r\n"
            conn.send(content: header.data(using: .utf8), completion: .contentProcessed { [weak self] _ in
                guard let self = self else { return }
                self.sseClients.append(conn)
                // Send immediate current state snapshot
                self.sendSSEState(to: conn)
            })
            return
        }

        // 3. REST API Endpoints
        if path == "/api/state" {
            let json = getCurrentStateJSON()
            sendJSONResponse(json, conn: conn)
            return
        }

        if path == "/api/pomodoro/start" {
            var minutes = 25
            var mode = PomodoroMode.focus
            if let data = body.data(using: .utf8),
               let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let m = dict["minutes"] as? Int { minutes = m }
                if let modeStr = dict["mode"] as? String {
                    if modeStr == "shortBreak" { mode = .shortBreak }
                    else if modeStr == "longBreak" { mode = .longBreak }
                }
            }
            DispatchQueue.main.async {
                PomodoroManager.shared.start(durationMinutes: minutes, mode: mode)
                self.broadcastState()
            }
            sendJSONResponse("{\"status\":\"ok\"}", conn: conn)
            return
        }

        if path == "/api/pomodoro/pause" {
            DispatchQueue.main.async {
                PomodoroManager.shared.pause()
                self.broadcastState()
            }
            sendJSONResponse("{\"status\":\"ok\"}", conn: conn)
            return
        }

        if path == "/api/pomodoro/resume" {
            DispatchQueue.main.async {
                PomodoroManager.shared.resume()
                self.broadcastState()
            }
            sendJSONResponse("{\"status\":\"ok\"}", conn: conn)
            return
        }

        if path == "/api/pomodoro/stop" {
            DispatchQueue.main.async {
                PomodoroManager.shared.stop()
                self.broadcastState()
            }
            sendJSONResponse("{\"status\":\"ok\"}", conn: conn)
            return
        }

        if path == "/api/wardrobe/hat" {
            var selectedHat: String? = nil
            if let data = body.data(using: .utf8),
               let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                selectedHat = dict["hat"] as? String
            }
            if let h = selectedHat, let hatEnum = DuckHat(rawValue: h) {
                if DuckState.shared.unlockedHats.contains(h) {
                    DispatchQueue.main.async {
                        DuckState.shared.currentHat = hatEnum
                        DuckSpriteRenderer.shared.clearCache()
                        DuckWindow.shared?.contentView?.needsDisplay = true
                        MenuBarController.shared.updateMenu()
                        self.broadcastState()
                    }
            sendJSONResponse("{\"status\":\"ok\"}", conn: conn)
                } else {
                    let price = DuckState.shared.hatPrice(h)
                    sendJSONResponse("{\"error\":\"hat_locked\",\"price\":\(price),\"coins\":\(DuckState.shared.focusCoins)}", conn: conn)
                }
            } else {
                sendJSONResponse("{\"error\":\"invalid_hat\"}", conn: conn)
            }
            return
        }

        if path == "/api/shop/buy" {
            var selectedHat: String? = nil
            if let data = body.data(using: .utf8),
               let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                selectedHat = dict["hat"] as? String
            }
            if let h = selectedHat {
                let res = DuckState.shared.buyHat(h)
                if res.success {
                    DispatchQueue.main.async {
                        DuckSpriteRenderer.shared.clearCache()
                        DuckWindow.shared?.contentView?.needsDisplay = true
                        MenuBarController.shared.updateMenu()
                        self.broadcastState()
                    }
            sendJSONResponse("{\"status\":\"ok\"}", conn: conn)
                } else {
                    let errMsg = res.error ?? "purchase_failed"
                    sendJSONResponse("{\"error\":\"\(errMsg)\",\"coins\":\(DuckState.shared.focusCoins)}", conn: conn)
                }
            } else {
                sendJSONResponse("{\"error\":\"missing_hat\"}", conn: conn)
            }
            return
        }

        if path == "/api/shop/claim_daily" {
            DispatchQueue.main.async {
                DuckState.shared.addFocusCoins(50)
                self.broadcastState()
            }
            sendJSONResponse("{\"status\":\"ok\"}", conn: conn)
            return
        }

        
        if path == "/api/profile/upload_avatar" {
            if let data = body.data(using: .utf8),
               let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let base64Str = dict["image"] as? String {
                let cleanBase64 = base64Str.components(separatedBy: ",").last ?? base64Str
                if let imgData = Data(base64Encoded: cleanBase64) {
                    let filename = "custom_avatar_\(Int(Date().timeIntervalSince1970)).png"
                    let filePath = (SyncServer.spritesDirectory as NSString).appendingPathComponent(filename)
                    try? imgData.write(to: URL(fileURLWithPath: filePath))
                    let urlPath = "/sprites/\(filename)"
                    DispatchQueue.main.async {
                        DuckState.shared.userAvatar = urlPath
                        self.broadcastState()
                    }
                    self.sendJSONResponse("{\"status\":\"ok\",\"avatarUrl\":\"\(urlPath)\"}", conn: conn)
                    return
                }
            }
            self.sendJSONResponse("{\"status\":\"error\"}", conn: conn)
            return
        }

        if path == "/api/profile/update" {
            var newName: String? = nil
            var newHandle: String? = nil
            var newAvatar: String? = nil
            var newTier: String? = nil
            if let data = body.data(using: .utf8),
               let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                newName = dict["name"] as? String
                newHandle = dict["handle"] as? String
                newAvatar = dict["avatar"] as? String
                newTier = dict["tier"] as? String
            }
            DispatchQueue.main.async {
                if let n = newName { DuckState.shared.userName = n }
                if let h = newHandle { DuckState.shared.userHandle = h }
                if let a = newAvatar { DuckState.shared.userAvatar = a }
                if let t = newTier { DuckState.shared.userTier = t }
                DuckWindow.shared?.contentView?.needsDisplay = true
                self.broadcastState()
            }
            sendJSONResponse("{\"status\":\"ok\"}", conn: conn)
            return
        }

        if path == "/api/focus/task" {
            var taskText: String = ""
            if let data = body.data(using: .utf8),
               let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let t = dict["task"] as? String {
                taskText = t
            }
            DispatchQueue.main.async {
                DuckState.shared.setFocusTask(taskText)
                DuckWindow.shared?.contentView?.needsDisplay = true
                self.broadcastState()
            }
            sendJSONResponse("{\"status\":\"saved\",\"task\":\"\(taskText)\"}", conn: conn)
            return
        }

        if path == "/api/duck/action" {
            var actionStr: String? = nil
            if let data = body.data(using: .utf8),
               let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                actionStr = dict["action"] as? String
            }
            DispatchQueue.main.async {
                switch actionStr {
                case "summon": DuckWindow.shared?.summonToCursor()
                case "perch": DuckWindow.shared?.perchOnActiveWindow()
                case "toggleVis": DuckWindow.shared?.toggleVisibility()
                case "pond": DuckWindow.shared?.sendToPond()
                case "pet": DuckWindow.shared?.petDuck()
                case "feed": DuckWindow.shared?.feedBread()
                case "jump": DuckWindow.shared?.jump()
                default: break
                }
                self.broadcastState()
            }
            sendJSONResponse("{\"status\":\"executed\"}", conn: conn)
            return
        }

        if path == "/api/duck/move" {
            var dx: CGFloat = 0
            var dy: CGFloat = 0
            if let data = body.data(using: .utf8),
               let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let numX = dict["dx"] as? Double { dx = CGFloat(numX) }
                if let numY = dict["dy"] as? Double { dy = CGFloat(numY) }
            }
            DispatchQueue.main.async {
                DuckWindow.shared?.applyJoystick(dx: dx, dy: dy)
            }
            sendJSONResponse("{\"status\":\"ok\"}", conn: conn)
            return
        }

        
                if path == "/api/weather/refresh" {
            WeatherService.shared.fetchWeather()
            sendJSONResponse("{\"status\":\"refreshing\"}", conn: conn)
            return
        }

        if path == "/api/music/next" {
            SpotifyTracker.shared.nextTrack()
            sendJSONResponse("{\"status\":\"next\"}", conn: conn)
            return
        }

        if path == "/api/music/previous" {
            SpotifyTracker.shared.previousTrack()
            sendJSONResponse("{\"status\":\"previous\"}", conn: conn)
            return
        }

        if path == "/api/music/playpause" || path == "/api/music/toggle" {
            SpotifyTracker.shared.playPause()
            sendJSONResponse("{\"status\":\"toggled\"}", conn: conn)
            return
        }

        if path == "/api/mac/action" {
            var actionName = "toggle_island"
            if let data = body.data(using: .utf8),
               let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let a = dict["action"] as? String {
                actionName = a
            }
            self.executeMacAction(actionName)
            self.sendJSONResponse("{\"status\":\"ok\",\"action\":\"\(actionName)\"}", conn: conn)
            return
        }

        if path == "/api/settings/sound" {
            var soundName: String = "lofi"
            if let data = body.data(using: .utf8),
               let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let s = dict["sound"] as? String {
                soundName = s
            }
            DuckState.shared.pomodoroSoundFX = soundName
            sendJSONResponse("{\"status\":\"saved\",\"sound\":\"\(soundName)\"}", conn: conn)
            return
        }

        // 4. Serve Sprites from dist/Sprites/ (Direct file or Atlas extraction)
        if path.hasPrefix("/sprites/") {
            let filename = String(path.dropFirst("/sprites/".count))
            let filePath = (SyncServer.spritesDirectory as NSString).appendingPathComponent(filename)

            // 4a. Direct file on disk (custom uploads, DuckSpritesheet.png, atlas.json)
            if FileManager.default.fileExists(atPath: filePath),
               let imgData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
                let mime = filename.hasSuffix(".json") ? "application/json" : "image/png"
                let header = "HTTP/1.1 200 OK\r\nContent-Type: \(mime)\r\nCache-Control: public, max-age=86400\r\nAccess-Control-Allow-Origin: *\r\nContent-Length: \(imgData.count)\r\n\r\n"
                var fullData = header.data(using: String.Encoding.utf8)!
                fullData.append(imgData)
                sendResponse(fullData, conn: conn, close: true)
                return
            }

            // 4b. Memory cache from Atlas
            Self.cacheLock.lock()
            let cached = Self.spriteCropCache[filename]
            Self.cacheLock.unlock()

            if let cachedData = cached {
                let header = "HTTP/1.1 200 OK\r\nContent-Type: image/png\r\nCache-Control: public, max-age=86400\r\nAccess-Control-Allow-Origin: *\r\nContent-Length: \(cachedData.count)\r\n\r\n"
                var fullData = header.data(using: String.Encoding.utf8)!
                fullData.append(cachedData)
                sendResponse(fullData, conn: conn, close: true)
                return
            }

            // 4c. Extract from in-memory DuckSpritesheet.png
            if let rect = Self.atlasFrames[filename],
               let atlas = Self.atlasImage,
               let cropped = atlas.cropping(to: rect) {
                let rep = NSBitmapImageRep(cgImage: cropped)
                if let pngData = rep.representation(using: .png, properties: [:]) {
                    Self.cacheLock.lock()
                    Self.spriteCropCache[filename] = pngData
                    Self.cacheLock.unlock()

                    let header = "HTTP/1.1 200 OK\r\nContent-Type: image/png\r\nCache-Control: public, max-age=86400\r\nAccess-Control-Allow-Origin: *\r\nContent-Length: \(pngData.count)\r\n\r\n"
                    var fullData = header.data(using: String.Encoding.utf8)!
                    fullData.append(pngData)
                    sendResponse(fullData, conn: conn, close: true)
                    return
                }
            }
        }

        // 5. Serve Lockin Mobile Web / PWA UI
        let html = LockinWebUI.getHTML()
        let resp = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: \(html.utf8.count)\r\n\r\n\(html)"
        sendResponse(resp.data(using: .utf8)!, conn: conn, close: true)
    }

    private func sendJSONResponse(_ json: String, conn: NWConnection) {
        let resp = "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nAccess-Control-Allow-Origin: *\r\nContent-Length: \(json.utf8.count)\r\n\r\n\(json)"
        sendResponse(resp.data(using: .utf8)!, conn: conn, close: true)
    }

    private func sendResponse(_ data: Data, conn: NWConnection, close: Bool) {
        conn.send(content: data, completion: .contentProcessed { _ in
            if close { conn.cancel() }
        })
    }

    public func getCurrentStateJSON() -> String {
        let pomo = PomodoroManager.shared
        let hat = DuckState.shared.currentHat
        let isLowBat = DuckState.shared.isLowBattery
        let isHighCpu = DuckState.shared.isHighCpu
        let batLevel = DuckState.shared.batteryPercent
        let cpuUsage = DuckState.shared.cpuUsage

        let dict: [String: Any] = [
            "pomodoro": [
                "isActive": pomo.isActive,
                "isRunning": pomo.isRunning,
                "isPaused": pomo.status == .paused,
                "timeString": pomo.timeString,
                "remainingSeconds": pomo.remainingSeconds,
                "totalSeconds": pomo.totalSeconds,
                "progress": pomo.progress,
                "mode": pomo.mode.rawValue,
                "modeTitle": pomo.mode.title
            ],
            "duck": [
                "currentHat": hat.rawValue,
                "hatName": hat.displayName,
                "energy": Int(DuckState.shared.energy),
                "happiness": Int(DuckState.shared.happiness),
                "hunger": Int(DuckState.shared.hunger),
                "mood": DuckState.shared.moodTitle,
                "moodDesc": DuckState.shared.moodDesc,
                "action": DuckState.shared.currentAction.rawValue,
                "isLowBattery": isLowBat,
                "isHighCpu": isHighCpu,
                "batteryPercent": batLevel,
                "cpuUsage": String(format: "%.1f", cpuUsage),
                "focusTask": DuckState.shared.focusTask
            ],
            "music": [
                "isPlaying": DuckState.shared.isPlayingMusic,
                "track": DuckState.shared.currentTrack,
                "artist": DuckState.shared.currentArtist,
                "artworkUrl": DuckState.shared.currentArtworkUrl,
                "position": DuckState.shared.currentPosition,
                "duration": DuckState.shared.currentDuration
            ],
            "weather": [
                "temp": DuckState.shared.weatherTemp,
                "city": DuckState.shared.weatherCity,
                "condition": DuckState.shared.weatherCondition,
                "icon": DuckState.shared.weatherIcon,
                "isRaining": DuckState.shared.isRaining,
                "isNight": DuckState.shared.isNight,
                "isHotSunny": DuckState.shared.isHotSunny
            ],
            "soundFX": DuckState.shared.pomodoroSoundFX,
            "user": [
                "name": DuckState.shared.userName,
                "handle": DuckState.shared.userHandle,
                "avatar": DuckState.shared.userAvatar,
                "tier": DuckState.shared.userTier
            ],
            "mac": [
                "isMuted": isMacAudioMuted(),
                "batteryPercent": DuckState.shared.batteryPercent
            ],
            "economy": [
                "coins": DuckState.shared.focusCoins,
                "totalFocusMinutes": DuckState.shared.totalFocusMinutes,
                "completedSessions": DuckState.shared.completedSessionsCount,
                "unlockedHats": Array(DuckState.shared.unlockedHats)
            ],
            "serverTime": Date().timeIntervalSince1970
        ]

        if let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
           let str = String(data: data, encoding: .utf8) {
            return str
        }
        return "{}"
    }

    public func broadcastState() {
        let json = getCurrentStateJSON()
        let msg = "data: \(json)\n\n"
        guard let data = msg.data(using: .utf8) else { return }

        sseClients.removeAll { client in
            client.state == .cancelled || client.state == .failed(NWError.posix(.ECANCELED))
        }

        for client in sseClients {
            client.send(content: data, completion: .idempotent)
        }
    }

    private func sendSSEState(to conn: NWConnection) {
        let json = getCurrentStateJSON()
        let msg = "data: \(json)\n\n"
        if let data = msg.data(using: .utf8) {
            conn.send(content: data, completion: .idempotent)
        }
    }

    public func executeMacAction(_ action: String) {
        switch action {
        case "lock":
            let p = Process()
            p.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
            p.arguments = ["displaysleepnow"]
            try? p.run()
        case "mute":
            // Trigger native macOS F10 media key event (NX_KEYTYPE_MUTE = 7)
            // This triggers the native macOS volume HUD bezel and toggles audio natively
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                func postMediaKey(key: Int32) {
                    func doKey(down: Bool) {
                        let flags = NSEvent.ModifierFlags(rawValue: (down ? 0xa00 : 0xb00))
                        let data1 = Int((key << 16) | (down ? 0xa00 : 0xb00))
                        let ev = NSEvent.otherEvent(with: .systemDefined,
                                                    location: .zero,
                                                    modifierFlags: flags,
                                                    timestamp: 0,
                                                    windowNumber: 0,
                                                    context: nil,
                                                    subtype: 8,
                                                    data1: data1,
                                                    data2: -1)
                        ev?.cgEvent?.post(tap: .cghidEventTap)
                    }
                    doKey(down: true)
                    doKey(down: false)
                }
                let prevMuted = self.isMacAudioMuted()
                postMediaKey(key: 7) // NX_KEYTYPE_MUTE (Native F10)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if self.isMacAudioMuted() == prevMuted {
                        let script = "set volume output muted not (output muted of (get volume settings))"
                        if let appleScript = NSAppleScript(source: script) {
                            var err: NSDictionary?
                            appleScript.executeAndReturnError(&err)
                        }
                    }
                    self.broadcastState()
                }
            }
        case "toggle_island":
            DispatchQueue.main.async {
                DynamicIslandWindow.shared?.toggleExpansion()
            }
        case "mirror", "toggle_mirror":
            DispatchQueue.main.async {
                DynamicIslandWindow.shared?.toggleMirror()
            }
        case "focus_shield":
            let script = "set volume output muted true"
            if let appleScript = NSAppleScript(source: script) {
                var err: NSDictionary?
                appleScript.executeAndReturnError(&err)
            }
            DispatchQueue.main.async {
                if !DuckState.shared.isPomodoroActive {
                    PomodoroManager.shared.start()
                }
                DynamicIslandWindow.shared?.setExpanded(true)
            }
            broadcastState()
        default:
            break
        }
    }

    private func isMacAudioMuted() -> Bool {
        let script = "output muted of (get volume settings)"
        if let appleScript = NSAppleScript(source: script) {
            var err: NSDictionary?
            let desc = appleScript.executeAndReturnError(&err)
            return desc.booleanValue
        }
        return false
    }
}

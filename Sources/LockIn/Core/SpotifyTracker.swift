import AppKit
import Foundation

public class SpotifyTracker {
    public static let shared = SpotifyTracker()

    public typealias Observer = (String, String, Bool) -> Void
    private var observers: [UUID: Observer] = [:]

    private var timer: Timer?
    private var lastTrack = ""
    private var lastArtist = ""
    private var lastArtworkUrl = ""
    private var lastPlaying = false
    private var lastPosition: Double = 0.0
    private let queue = DispatchQueue(label: "com.duckpet.spotifytracker", qos: .userInitiated)

    private func postMediaKey(key: Int32) {
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

    private init() {
        setupDistributedNotifications()
    }

    @discardableResult
    public func addObserver(_ callback: @escaping Observer) -> UUID {
        let id = UUID()
        observers[id] = callback
        callback(DuckState.shared.currentTrack, DuckState.shared.currentArtist, DuckState.shared.isPlayingMusic)
        return id
    }

    public func removeObserver(_ id: UUID) {
        observers.removeValue(forKey: id)
    }

    private func setupDistributedNotifications() {
        DistributedNotificationCenter.default().addObserver(
            forName: NSNotification.Name("com.spotify.client.PlaybackStateChanged"),
            object: nil,
            queue: .main
        ) { [weak self] notif in
            guard let self = self else { return }
            if let userInfo = notif.userInfo {
                let playerState = userInfo["Player State"] as? String ?? ""
                let track = userInfo["Name"] as? String ?? ""
                let artist = userInfo["Artist"] as? String ?? ""
                let isPlaying = (playerState.lowercased() == "playing")

                self.applyTrackUpdate(track: track, artist: artist, isPlaying: isPlaying, artworkUrl: "", position: 0.0, duration: 0.0)
            }
            self.checkPlayback()
        }
    }

    public func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { [weak self] _ in
            self?.checkPlayback()
        }
        checkPlayback()
    }

    public func stopPolling() {
        timer?.invalidate()
        timer = nil
    }

    public func checkPlayback() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let spotifyScript = """
            if application "Spotify" is running then
                tell application "Spotify"
                    set pState to (player state as string)
                    if pState is not "stopped" then
                        set tName to name of current track
                        set tArtist to artist of current track
                        set tArt to ""
                        try
                            set tArt to artwork url of current track
                        end try
                        set tPos to player position
                        set tDur to duration of current track
                        return tName & "|||" & tArtist & "|||" & tArt & "|||" & tPos & "|||" & tDur & "|||" & pState
                    end if
                end tell
            end if
            """
            
            var isPlaying = false
            var track = ""
            var artist = ""
            var artworkUrl = ""
            var position: Double = 0.0
            var duration: Double = 0.0

            if let output = self.runOsascript(spotifyScript), !output.isEmpty && !output.contains("error") {
                let parts = output.components(separatedBy: "|||")
                if parts.count >= 2 {
                    track = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    artist = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)

                    if parts.count >= 6 {
                        let st = parts[5].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                        isPlaying = (st == "playing")
                    } else {
                        isPlaying = true
                    }

                    if parts.count >= 3 {
                        let art = parts[2].trimmingCharacters(in: .whitespacesAndNewlines)
                        if !art.isEmpty && art != "missing value" {
                            artworkUrl = art
                        }
                    }
                    if parts.count >= 4 {
                        let rawPos = parts[3].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")
                        position = Double(rawPos) ?? 0.0
                    }
                    if parts.count >= 5 {
                        let rawDur = parts[4].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")
                        let d = Double(rawDur) ?? 0.0
                        duration = d > 1000.0 ? (d / 1000.0) : d
                    }
                }
            } else {
                // Fallback to Music.app (Apple Music)
                let musicScript = """
                if application "Music" is running then
                    tell application "Music"
                        set pState to (player state as string)
                        if pState is not "stopped" then
                            set tName to name of current track
                            set tArtist to artist of current track
                            set tPos to player position
                            set tDur to duration of current track
                            return tName & "|||" & tArtist & "||||||" & tPos & "|||" & tDur & "|||" & pState
                        end if
                    end tell
                end if
                """
                if let output = self.runOsascript(musicScript), !output.isEmpty && !output.contains("error") {
                    let parts = output.components(separatedBy: "|||")
                    if parts.count >= 2 {
                        track = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                        artist = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)

                        if parts.count >= 6 {
                            let st = parts[5].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                            isPlaying = (st == "playing")
                        } else {
                            isPlaying = true
                        }

                        if parts.count >= 4 {
                            let rawPos = parts[3].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")
                            position = Double(rawPos) ?? 0.0
                        }
                        if parts.count >= 5 {
                            let rawDur = parts[4].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")
                            duration = Double(rawDur) ?? 0.0
                        }
                    }
                }
            }

            self.applyTrackUpdate(
                track: track,
                artist: artist,
                isPlaying: isPlaying,
                artworkUrl: artworkUrl,
                position: position,
                duration: duration
            )
        }
    }

    public func nextTrack() {
        queue.async { [weak self] in
            guard let self = self else { return }
            let script = """
            if application "Spotify" is running then
                tell application "Spotify" to next track
                return "spotify"
            else if application "Music" is running then
                tell application "Music" to next track
                return "music"
            else
                return "none"
            end if
            """
            let res = self.runOsascript(script)
            if res == nil || res == "none" {
                self.postMediaKey(key: 17) // NX_KEYTYPE_NEXT
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.checkPlayback()
            }
        }
    }

    public func previousTrack() {
        queue.async { [weak self] in
            guard let self = self else { return }
            let script = """
            if application "Spotify" is running then
                tell application "Spotify" to previous track
                return "spotify"
            else if application "Music" is running then
                tell application "Music" to previous track
                return "music"
            else
                return "none"
            end if
            """
            let res = self.runOsascript(script)
            if res == nil || res == "none" {
                self.postMediaKey(key: 18) // NX_KEYTYPE_PREVIOUS
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.checkPlayback()
            }
        }
    }

    public func playPause() {
        queue.async { [weak self] in
            guard let self = self else { return }
            let script = """
            if application "Spotify" is running then
                tell application "Spotify"
                    if player state is playing then
                        pause
                    else
                        play
                    end if
                end tell
                return "spotify"
            else if application "Music" is running then
                tell application "Music"
                    if player state is playing then
                        pause
                    else
                        play
                    end if
                end tell
                return "music"
            else
                return "none"
            end if
            """
            let res = self.runOsascript(script)
            if res == nil || res == "none" {
                self.postMediaKey(key: 16) // NX_KEYTYPE_PLAY
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.checkPlayback()
            }
        }
    }

    private func applyTrackUpdate(
        track: String,
        artist: String,
        isPlaying: Bool,
        artworkUrl: String,
        position: Double,
        duration: Double
    ) {
        let posDiff = abs(position - lastPosition)
        let changed = (track != lastTrack || artist != lastArtist || isPlaying != lastPlaying || (isPlaying && posDiff >= 2.0))

        lastTrack = track
        lastArtist = artist
        lastPlaying = isPlaying
        lastPosition = position

        // Download album artwork image if URL changed
        if isPlaying && !artworkUrl.isEmpty && artworkUrl != lastArtworkUrl {
            lastArtworkUrl = artworkUrl
            if let url = URL(string: artworkUrl) {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data, let img = NSImage(data: data) {
                        DispatchQueue.main.async {
                            DuckState.shared.currentArtwork = img
                        }
                    }
                }.resume()
            }
        } else if !isPlaying || track.isEmpty {
            lastArtworkUrl = ""
            DispatchQueue.main.async {
                DuckState.shared.currentArtwork = nil
            }
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            DuckState.shared.isPlayingMusic = isPlaying
            DuckState.shared.currentTrack = track
            DuckState.shared.currentArtist = artist
            DuckState.shared.currentArtworkUrl = artworkUrl
            if position > 0 {
                DuckState.shared.currentPosition = position
            }
            if duration > 0 {
                DuckState.shared.currentDuration = duration
            }

            if isPlaying && !track.isEmpty {
                if DuckState.shared.currentAction != .swimming &&
                   DuckState.shared.currentAction != .swimLeft &&
                   DuckState.shared.currentAction != .swimRight &&
                   DuckState.shared.currentAction != .dragged {
                    DuckState.shared.currentAction = .vibeMusic
                }
            }

            if changed {
                SyncServer.shared.broadcastState()
                for callback in self.observers.values {
                    callback(track, artist, isPlaying)
                }
            }
        }
    }

    private func runOsascript(_ script: String) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let str = String(data: data, encoding: .utf8) {
                return str.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            return nil
        }
        return nil
    }
}

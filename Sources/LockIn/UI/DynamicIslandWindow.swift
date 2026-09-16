import AppKit
import AVFoundation

// MARK: - LockIn Mac Notch Dynamic Island (Dynamic Adaptive Width)

public class DynamicIslandWindow: NSPanel {
    public static var shared: DynamicIslandWindow?

    private var islandView: DynamicIslandView!
    public var isExpanded: Bool = false
    public var isMirrorOpen: Bool = false
    private var isIslandVisible: Bool = true
    private var spotifyObserverId: UUID?

    // Notch measurements for current display
    public var screenNotchWidth: CGFloat = 185.0
    public var screenNotchHeight: CGFloat = 32.0
    public var hasPhysicalNotch: Bool = true

    // Dynamic Island Sizes
    public var compactWidth: CGFloat { screenNotchWidth }
    public var compactHeight: CGFloat { screenNotchHeight }

    // Adaptive Expanded Sizes
    public let calendarOnlyWidth: CGFloat = 480.0
    public let musicCalendarWidth: CGFloat = 510.0
    public let cameraWideWidth: CGFloat = 520.0
    public let expandedHeight: CGFloat = 148.0

    public var currentExpandedWidth: CGFloat {
        if isMirrorOpen {
            return cameraWideWidth
        } else if DuckState.shared.isPlayingMusic && !DuckState.shared.currentTrack.isEmpty {
            return musicCalendarWidth
        } else {
            return calendarOnlyWidth
        }
    }

    public init() {
        let screen = NSScreen.main ?? NSScreen.screens.first!
        let screenFrame = screen.frame

        let insetsTop: CGFloat
        if #available(macOS 12.0, *), screen.safeAreaInsets.top > 0 {
            insetsTop = screen.safeAreaInsets.top
            hasPhysicalNotch = true
        } else {
            insetsTop = max(24.0, screenFrame.maxY - screen.visibleFrame.maxY)
            hasPhysicalNotch = false
        }
        screenNotchHeight = insetsTop

        // Measure exact notch gap if auxiliary areas exist
        if #available(macOS 12.0, *),
           let leftArea = screen.auxiliaryTopLeftArea,
           let rightArea = screen.auxiliaryTopRightArea,
           leftArea.width > 0 && rightArea.width > 0 {
            screenNotchWidth = rightArea.minX - leftArea.maxX
        } else {
            screenNotchWidth = 185.0
        }

        let initW = screenNotchWidth
        let initH = screenNotchHeight
        let x = screenFrame.midX - (initW / 2.0)
        let y = screenFrame.maxY - initH

        let rect = NSRect(x: x, y: y, width: initW, height: initH)

        super.init(
            contentRect: rect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        Self.shared = self

        self.level = .statusBar
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = true
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let view = DynamicIslandView(frame: NSRect(x: 0, y: 0, width: initW, height: initH))
        view.windowController = self
        self.islandView = view
        self.contentView = view

        // Listen for track changes to dynamically adapt width when expanded
        spotifyObserverId = SpotifyTracker.shared.addObserver { [weak self] _, _, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if self.isExpanded && !self.isMirrorOpen {
                    self.updateWindowFrame(animated: true)
                }
            }
        }

        self.orderFront(nil)
    }

    deinit {
        if let id = spotifyObserverId {
            SpotifyTracker.shared.removeObserver(id)
        }
    }

    public func setExpanded(_ expand: Bool, animated: Bool = true) {
        guard expand != isExpanded else { return }
        isExpanded = expand

        if !expand && isMirrorOpen {
            closeMirror(animate: false)
        }

        updateWindowFrame(animated: animated)
    }

    public func updateWindowFrame(animated: Bool = true) {
        let screen = self.screen ?? NSScreen.main ?? NSScreen.screens.first!
        let screenFrame = screen.frame

        let targetW: CGFloat = isExpanded ? currentExpandedWidth : compactWidth
        let targetH: CGFloat = isExpanded ? expandedHeight : compactHeight
        let targetX = screenFrame.midX - (targetW / 2.0)
        let targetY = screenFrame.maxY - targetH

        let targetFrame = NSRect(x: targetX, y: targetY, width: targetW, height: targetH)

        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = animated ? 0.28 : 0.0
            ctx.allowsImplicitAnimation = true
            self.animator().setFrame(targetFrame, display: true)
            self.islandView?.animator().frame = NSRect(x: 0, y: 0, width: targetW, height: targetH)
        }, completionHandler: {
            self.setFrame(targetFrame, display: true)
            self.islandView?.frame = NSRect(x: 0, y: 0, width: targetW, height: targetH)
            self.islandView?.updateMirrorLayout()
            self.islandView?.needsDisplay = true
        })
    }

    public func toggleExpansion() {
        setExpanded(!isExpanded)
    }

    public func toggleVisibility() {
        isIslandVisible.toggle()
        if isIslandVisible {
            self.orderFront(nil)
        } else {
            self.orderOut(nil)
        }
    }

    // MARK: - Circular Live Mirror Mode

    public func toggleMirror() {
        if isMirrorOpen {
            closeMirror()
        } else {
            openMirror()
        }
    }

    public func openMirror() {
        guard !isMirrorOpen else { return }
        isMirrorOpen = true

        if !isExpanded {
            isExpanded = true
        }

        updateWindowFrame(animated: true)

        CameraMirrorController.shared.startSession { [weak self] success in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if self.isMirrorOpen {
                    self.islandView?.showMirrorPreview(success: success)
                    self.islandView?.updateMirrorLayout()
                }
            }
        }
    }

    public func closeMirror(animate: Bool = true) {
        guard isMirrorOpen else { return }
        isMirrorOpen = false

        islandView?.hideMirrorPreview()
        CameraMirrorController.shared.stopSession()

        updateWindowFrame(animated: animate)
    }
}

// MARK: - Dynamic Island View

public class DynamicIslandView: NSView {
    public weak var windowController: DynamicIslandWindow?
    public var isExpanded: Bool {
        return windowController?.isExpanded ?? false
    }

    private var trackingArea: NSTrackingArea?
    private var collapseTimer: Timer?
    private var tick: Int = 0
    private var refreshTimer: Timer?

    private var previewContainer: NSView?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupTracking()

        refreshTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.tick += 1
            if DuckState.shared.isPlayingMusic && DuckState.shared.currentDuration > 0 {
                DuckState.shared.currentPosition = min(DuckState.shared.currentDuration, DuckState.shared.currentPosition + 0.1)
            }
            self.needsDisplay = true
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        refreshTimer?.invalidate()
        collapseTimer?.invalidate()
    }

    private func setupTracking() {
        if let existing = trackingArea {
            removeTrackingArea(existing)
        }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        self.trackingArea = area
    }

    public override func layout() {
        super.layout()
        updateMirrorLayout()
    }

    public override func updateTrackingAreas() {
        super.updateTrackingAreas()
        setupTracking()
    }

    public override func mouseEntered(with event: NSEvent) {
        collapseTimer?.invalidate()
        windowController?.setExpanded(true)
    }

    public override func mouseExited(with event: NSEvent) {
        if windowController?.isMirrorOpen == true {
            return
        }
        collapseTimer?.invalidate()
        collapseTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
            self?.windowController?.setExpanded(false)
        }
    }

    // MARK: - Interactive Frames
    private var homeTabRect: NSRect { NSRect(x: 10, y: 120, width: 28, height: 26) }
    private var pomoTabRect: NSRect { NSRect(x: 38, y: 120, width: 28, height: 26) }
    private var cameraTabRect: NSRect { NSRect(x: bounds.width - 126, y: 120, width: 28, height: 26) }
    private var settingsIconRect: NSRect { NSRect(x: bounds.width - 97, y: 120, width: 26, height: 26) }

    // Column 1 (Spotify)
    private var spotifyLogoRect: NSRect { NSRect(x: 18, y: 36, width: 66, height: 66) }
    private var prevButtonRect: NSRect {
        let isMirror = windowController?.isMirrorOpen ?? false
        return NSRect(x: isMirror ? 88 : 96, y: 6, width: 30, height: 30)
    }
    private var playButtonRect: NSRect {
        let isMirror = windowController?.isMirrorOpen ?? false
        return NSRect(x: isMirror ? 126 : 140, y: 4, width: 34, height: 34)
    }
    private var nextButtonRect: NSRect {
        let isMirror = windowController?.isMirrorOpen ?? false
        return NSRect(x: isMirror ? 164 : 184, y: 6, width: 30, height: 30)
    }

    // Column 2 (Calendar & Focus)
    private var calendarCardRect: NSRect {
        let isMirror = windowController?.isMirrorOpen ?? false
        let calX: CGFloat = isMirror ? 204.0 : 250.0
        return NSRect(x: calX, y: 10, width: 180, height: 104)
    }

    // Column 3 (Circle Mirror)
    public var mirrorCircleRect: NSRect {
        let w = (windowController?.isMirrorOpen == true) ? (windowController?.cameraWideWidth ?? bounds.width) : bounds.width
        return NSRect(x: w - 132, y: 22, width: 92, height: 92)
    }

    public func updateMirrorLayout() {
        if let container = previewContainer {
            container.frame = mirrorCircleRect
            previewLayer?.frame = container.bounds
        }
    }

    public override func mouseDown(with event: NSEvent) {
        let loc = convert(event.locationInWindow, from: nil)

        if isExpanded {
            // Keep island open when clicked
            collapseTimer?.invalidate()
            collapseTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { [weak self] _ in
                if !(self?.windowController?.isMirrorOpen ?? false) {
                    self?.windowController?.setExpanded(false)
                }
            }

            // 1. Camera Mirror Toggle: Button beside Pomodoro, or clicking mirror circle when active
            if cameraTabRect.insetBy(dx: -4, dy: -4).contains(loc) || ((windowController?.isMirrorOpen ?? false) && mirrorCircleRect.contains(loc)) {
                windowController?.toggleMirror()
                return
            }

            // 2. Pomodoro Toggle: ONLY the Pomodoro button in top ear! (Never clicks on notch or calendar)
            if pomoTabRect.insetBy(dx: -4, dy: -4).contains(loc) {
                if PomodoroManager.shared.isActive {
                    PomodoroManager.shared.stop()
                } else {
                    // Start Pomodoro from notch: no default task unless customized from iPhone
                    if DuckState.shared.focusTask == "UI Design" {
                        DuckState.shared.setFocusTask("")
                    }
                    PomodoroManager.shared.start(durationMinutes: 25, mode: .focus)
                }
                needsDisplay = true
                return
            }

            // 3. Spotify Controls
            let hasMusic = DuckState.shared.isPlayingMusic && !DuckState.shared.currentTrack.isEmpty
            let isMirror = windowController?.isMirrorOpen ?? false
            if hasMusic || isMirror {
                // Controls under track title in expanded mode
                if prevButtonRect.insetBy(dx: -4, dy: -4).contains(loc) {
                    SpotifyTracker.shared.previousTrack()
                    needsDisplay = true
                    return
                }
                if playButtonRect.insetBy(dx: -4, dy: -4).contains(loc) {
                    SpotifyTracker.shared.playPause()
                    needsDisplay = true
                    return
                }
                if nextButtonRect.insetBy(dx: -4, dy: -4).contains(loc) {
                    SpotifyTracker.shared.nextTrack()
                    needsDisplay = true
                    return
                }
                if spotifyLogoRect.contains(loc) {
                    let script = "tell application \"Spotify\" to activate"
                    _ = Process.launchedProcess(launchPath: "/usr/bin/osascript", arguments: ["-e", script])
                    return
                }
            } else {
                // Compact Spotify buttons centered under the calendar in 480pt mode
                let calPrevRect = NSRect(x: 48, y: 10, width: 38, height: 36)
                let calPlayRect = NSRect(x: 90, y: 8, width: 54, height: 40)
                let calNextRect = NSRect(x: 148, y: 10, width: 38, height: 36)

                if calPrevRect.insetBy(dx: -4, dy: -4).contains(loc) {
                    SpotifyTracker.shared.previousTrack()
                    needsDisplay = true
                    return
                }
                if calPlayRect.insetBy(dx: -4, dy: -4).contains(loc) {
                    SpotifyTracker.shared.playPause()
                    needsDisplay = true
                    return
                }
                if calNextRect.insetBy(dx: -4, dy: -4).contains(loc) {
                    SpotifyTracker.shared.nextTrack()
                    needsDisplay = true
                    return
                }
            }

            // 4. Settings icon
            if settingsIconRect.insetBy(dx: -4, dy: -4).contains(loc) {
                MenuBarController.shared.showSettingsMenu(at: NSPoint(x: settingsIconRect.midX, y: settingsIconRect.minY), in: self)
                return
            }
        }

        // Notch click toggles expansion
        windowController?.toggleExpansion()
    }

    public func showMirrorPreview(success: Bool) {
        guard windowController?.isMirrorOpen == true else { return }
        let circleRect = mirrorCircleRect
        if previewContainer == nil {
            let container = NSView(frame: circleRect)
            container.wantsLayer = true
            container.layer?.cornerRadius = 46.0
            container.layer?.masksToBounds = true
            container.layer?.backgroundColor = NSColor.black.cgColor
            container.layer?.borderWidth = 1.0
            container.layer?.borderColor = NSColor(white: 0.22, alpha: 0.7).cgColor
            container.autoresizingMask = [.minXMargin]
            self.addSubview(container)
            self.previewContainer = container
        } else {
            previewContainer?.frame = circleRect
            previewContainer?.layer?.borderWidth = 1.0
            previewContainer?.layer?.borderColor = NSColor(white: 0.22, alpha: 0.7).cgColor
            previewContainer?.isHidden = false
        }

        if let container = previewContainer {
            previewLayer?.removeFromSuperlayer()
            previewLayer = nil
            if let layer = CameraMirrorController.shared.makePreviewLayer() {
                layer.frame = container.bounds
                layer.cornerRadius = 46.0
                layer.masksToBounds = true
                container.layer?.addSublayer(layer)
                self.previewLayer = layer
            }
        }
        needsDisplay = true
    }

    public func hideMirrorPreview() {
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
        previewContainer?.removeFromSuperview()
        previewContainer = nil
        needsDisplay = true
    }

    private func roundedBottomPath(bounds: NSRect, radius: CGFloat) -> NSBezierPath {
        let path = NSBezierPath()
        let r = min(radius, bounds.height / 2.0)
        path.move(to: NSPoint(x: bounds.minX, y: bounds.maxY))
        path.line(to: NSPoint(x: bounds.maxX, y: bounds.maxY))
        path.line(to: NSPoint(x: bounds.maxX, y: bounds.minY + r))
        path.appendArc(from: NSPoint(x: bounds.maxX, y: bounds.minY),
                       to: NSPoint(x: bounds.maxX - r, y: bounds.minY),
                       radius: r)
        path.line(to: NSPoint(x: bounds.minX + r, y: bounds.minY))
        path.appendArc(from: NSPoint(x: bounds.minX, y: bounds.minY),
                       to: NSPoint(x: bounds.minX, y: bounds.minY + r),
                       radius: r)
        path.close()
        return path
    }

    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let cornerRadius: CGFloat = isExpanded ? 26.0 : 10.0
        let path = roundedBottomPath(bounds: bounds, radius: cornerRadius)

        // Pitch Black body
        NSColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 0.99).setFill()
        path.fill()

        if isExpanded {
            drawTopEarBar()

            let hasMusic = DuckState.shared.isPlayingMusic && !DuckState.shared.currentTrack.isEmpty
            let isMirror = windowController?.isMirrorOpen ?? false

            if isMirror {
                // Mode 3: Camera active (520pt) - Spotify Player on left, Calendar in center, Mirror on right
                drawSpotifyColumn()
                drawCalendarColumn(calX: 204.0)
                // mirror handled by previewContainer layer
            } else if hasMusic {
                // Mode 2: Music playing (510pt)
                drawSpotifyColumn()
                drawCalendarColumn(calX: 250.0)
            } else {
                // Mode 1: Calendar & Weather Widget (480pt) - No duck, clean & native!
                drawCalendarColumn(calX: 20.0)
                drawWeatherColumn(startX: 264.0)
            }
        } else {
            drawCompactNotch()
        }
    }

    // MARK: - Compact Mode
    private func drawCompactNotch() {
        if DuckState.shared.isPomodoroActive {
            let dotRect = NSRect(x: (bounds.width - 6) / 2.0, y: 3, width: 6, height: 6)
            NSColor(red: 1.00, green: 0.00, blue: 0.48, alpha: 0.9).setFill()
            NSBezierPath(ovalIn: dotRect).fill()
        }
    }

    // MARK: - Top Ear Bar (Icons on Left & Right of Notch)
    private func drawTopEarBar() {
        // 1. Left Ear: [ 🏠 Home ] [ 🍅 Pomodoro ] (Clean, no background capsule)
        if let imgHome = NSImage(systemSymbolName: "house.fill", accessibilityDescription: nil) {
            let config = NSImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
            if let cfg = imgHome.withSymbolConfiguration(config) {
                let tinted = tintImage(cfg, color: .white)
                tinted.draw(in: NSRect(x: 16, y: 126, width: 16, height: 16))
            }
        }

        // 2. Pomodoro Icon
        let isPomo = DuckState.shared.isPomodoroActive
        let pomoColor: NSColor = isPomo ?
            NSColor(red: 1.00, green: 0.20, blue: 0.50, alpha: 1.0) : NSColor(white: 0.65, alpha: 1.0)

        if let imgPomo = NSImage(systemSymbolName: isPomo ? "flame.fill" : "timer", accessibilityDescription: nil) {
            let config = NSImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
            if let cfg = imgPomo.withSymbolConfiguration(config) {
                let tinted = tintImage(cfg, color: pomoColor)
                tinted.draw(in: NSRect(x: 44, y: 126, width: 16, height: 16))
            }
        }

        // 2. Right Ear: [ 🎦 Camera ] [ ⚙ Settings ] [ 🔋 34% ]
        let rightMargin: CGFloat = bounds.width

        // Camera Mirror Icon (SF Symbol web.camera.fill)
        let isMirror = windowController?.isMirrorOpen ?? false
        let mirColor: NSColor = isMirror ?
            NSColor(red: 0.18, green: 0.82, blue: 0.44, alpha: 1.0) : NSColor(white: 0.75, alpha: 1.0)

        let camSymbol = "web.camera.fill"
        if let imgCam = NSImage(systemSymbolName: camSymbol, accessibilityDescription: nil) {
            let config = NSImage.SymbolConfiguration(pointSize: 12, weight: .medium)
            if let cfg = imgCam.withSymbolConfiguration(config) {
                let tinted = tintImage(cfg, color: mirColor)
                tinted.draw(in: NSRect(x: rightMargin - 120, y: 126, width: 16, height: 16))
            }
        }

        // Settings gear icon
        if let imgGear = NSImage(systemSymbolName: "gearshape.fill", accessibilityDescription: nil) {
            let config = NSImage.SymbolConfiguration(pointSize: 12, weight: .medium)
            if let cfg = imgGear.withSymbolConfiguration(config) {
                let tinted = tintImage(cfg, color: NSColor(white: 0.75, alpha: 1.0))
                tinted.draw(in: NSRect(x: rightMargin - 92, y: 126, width: 16, height: 16))
            }
        }

        // Battery level & icon
        let bat = DuckState.shared.batteryPercent
        let batStr = "\(bat)%"
        let batAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 11, weight: .semibold),
            .foregroundColor: NSColor.white
        ]
        let astr = NSAttributedString(string: batStr, attributes: batAttrs)
        astr.draw(at: NSPoint(x: rightMargin - 66, y: 126))

        let batIconName: String
        if DuckState.shared.isCharging {
            batIconName = "battery.100.bolt"
        } else if bat >= 75 {
            batIconName = "battery.100"
        } else if bat >= 40 {
            batIconName = "battery.50"
        } else {
            batIconName = "battery.25"
        }

        if let imgBat = NSImage(systemSymbolName: batIconName, accessibilityDescription: nil) {
            let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
            if let cfg = imgBat.withSymbolConfiguration(config) {
                let tinted = tintImage(cfg, color: NSColor.white)
                tinted.draw(in: NSRect(x: rightMargin - 36, y: 126, width: 22, height: 14))
            }
        }
    }

    // MARK: - Left Duck Card removed: always show Spotify Player instead!

    // MARK: - Weather Widget Column (for 480pt Idle Mode - Centered & Clean)
    private func drawWeatherColumn(startX: CGFloat) {
        let rightEdgeX: CGFloat = bounds.width - 18.0 // 462.0
        let centerX: CGFloat = (startX + rightEdgeX) / 2.0 // 363.0
        let cardW: CGFloat = rightEdgeX - startX // 198.0
        let cardX: CGFloat = startX

        // 1. Weather Icon (Centered at top)
        let iconName = DuckState.shared.weatherIcon.isEmpty ? "cloud.sun.fill" : DuckState.shared.weatherIcon
        if let imgWeather = NSImage(systemSymbolName: iconName, accessibilityDescription: nil) {
            let config = NSImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
            if let cfg = imgWeather.withSymbolConfiguration(config) {
                let iconColor: NSColor
                if DuckState.shared.isRaining {
                    iconColor = NSColor(red: 0.38, green: 0.78, blue: 1.0, alpha: 1.0)
                } else if DuckState.shared.isNight {
                    iconColor = NSColor(red: 0.75, green: 0.82, blue: 1.0, alpha: 1.0)
                } else {
                    iconColor = NSColor(red: 1.0, green: 0.82, blue: 0.22, alpha: 1.0)
                }
                let tinted = tintImage(cfg, color: iconColor)
                tinted.draw(in: NSRect(x: centerX - 14, y: 64, width: 28, height: 26))
            }
        }

        // 2. Temperature & City (Centered in middle)
        let pStyle = NSMutableParagraphStyle()
        pStyle.alignment = .center

        let city = DuckState.shared.weatherCity.isEmpty ? "Local" : DuckState.shared.weatherCity
        let tempStr = String(format: "%.0f° • %@", DuckState.shared.weatherTemp, city)
        let tempAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 15, weight: .heavy),
            .foregroundColor: NSColor.white,
            .paragraphStyle: pStyle
        ]
        NSAttributedString(string: tempStr, attributes: tempAttrs).draw(in: NSRect(x: cardX, y: 38, width: cardW, height: 20))

        // 3. Condition (Centered at bottom)
        let condStr = DuckState.shared.weatherCondition.isEmpty ? "Partly Cloudy" : DuckState.shared.weatherCondition
        let condAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: NSColor(white: 0.65, alpha: 1.0),
            .paragraphStyle: pStyle
        ]
        NSAttributedString(string: condStr, attributes: condAttrs).draw(in: NSRect(x: cardX, y: 20, width: cardW, height: 16))
    }

    // MARK: - Column 1: Spotify Media Player
    private func drawSpotifyColumn() {
        let isPlaying = DuckState.shared.isPlayingMusic
        let rawTrack = DuckState.shared.currentTrack
        let rawArtist = DuckState.shared.currentArtist

        let track = rawTrack.isEmpty ? "Spotify" : rawTrack
        let artist = rawArtist.isEmpty ? (isPlaying ? "Music" : "Ready to Play") : rawArtist

        let isMirror = windowController?.isMirrorOpen ?? false

        // 1. Album Artwork Card (with real photo cover from Spotify)
        let cardRect = NSRect(x: 18, y: 36, width: 66, height: 66)

        if let artwork = DuckState.shared.currentArtwork {
            // Draw real album artwork with rounded corners!
            NSGraphicsContext.saveGraphicsState()
            let clip = NSBezierPath(roundedRect: cardRect, xRadius: 14, yRadius: 14)
            clip.addClip()
            artwork.draw(in: cardRect)
            NSGraphicsContext.restoreGraphicsState()

            // Subtle border
            NSColor(white: 0.22, alpha: 0.6).setStroke()
            let bPath = NSBezierPath(roundedRect: cardRect, xRadius: 14, yRadius: 14)
            bPath.lineWidth = 1.0
            bPath.stroke()

            // Mini Spotify logo badge on bottom-right corner of album art
            let badgeRect = NSRect(x: cardRect.maxX - 16, y: cardRect.minY - 2, width: 18, height: 18)
            drawMiniSpotifyBadge(rect: badgeRect)
        } else {
            // Fallback: Vibrant Spotify Green vector card
            let cardPath = NSBezierPath(roundedRect: cardRect, xRadius: 14, yRadius: 14)
            NSColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1.0).setFill()
            cardPath.fill()
            NSColor(white: 0.22, alpha: 0.5).setStroke()
            cardPath.lineWidth = 1.0
            cardPath.stroke()

            let greenCircleRect = NSRect(x: cardRect.minX + 8, y: cardRect.minY + 8, width: 48, height: 48)
            NSColor(red: 0.11, green: 0.73, blue: 0.33, alpha: 1.0).setFill()
            NSBezierPath(ovalIn: greenCircleRect).fill()

            let waveColor = NSColor.black
            waveColor.setStroke()

            let w1 = NSBezierPath()
            w1.move(to: NSPoint(x: greenCircleRect.minX + 11, y: greenCircleRect.minY + 30))
            w1.curve(to: NSPoint(x: greenCircleRect.minX + 37, y: greenCircleRect.minY + 35),
                     controlPoint1: NSPoint(x: greenCircleRect.minX + 20, y: greenCircleRect.minY + 36),
                     controlPoint2: NSPoint(x: greenCircleRect.minX + 29, y: greenCircleRect.minY + 37))
            w1.lineWidth = 3.2
            w1.lineCapStyle = .round
            w1.stroke()

            let w2 = NSBezierPath()
            w2.move(to: NSPoint(x: greenCircleRect.minX + 13, y: greenCircleRect.minY + 22))
            w2.curve(to: NSPoint(x: greenCircleRect.minX + 35, y: greenCircleRect.minY + 26),
                     controlPoint1: NSPoint(x: greenCircleRect.minX + 21, y: greenCircleRect.minY + 27),
                     controlPoint2: NSPoint(x: greenCircleRect.minX + 29, y: greenCircleRect.minY + 28))
            w2.lineWidth = 2.8
            w2.lineCapStyle = .round
            w2.stroke()

            let w3 = NSBezierPath()
            w3.move(to: NSPoint(x: greenCircleRect.minX + 16, y: greenCircleRect.minY + 15))
            w3.curve(to: NSPoint(x: greenCircleRect.minX + 32, y: greenCircleRect.minY + 18),
                     controlPoint1: NSPoint(x: greenCircleRect.minX + 22, y: greenCircleRect.minY + 19),
                     controlPoint2: NSPoint(x: greenCircleRect.minX + 27, y: greenCircleRect.minY + 20))
            w3.lineWidth = 2.4
            w3.lineCapStyle = .round
            w3.stroke()
        }

        // 2. Track Title & Artist
        let infoX: CGFloat = 92.0
        let maxW: CGFloat = isMirror ? 104.0 : 138.0

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 13, weight: .bold),
            .foregroundColor: NSColor.white
        ]
        let titleAstr = NSAttributedString(string: track, attributes: titleAttrs)
        titleAstr.draw(in: NSRect(x: infoX, y: 84, width: maxW, height: 18))

        let artistAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 11, weight: .semibold),
            .foregroundColor: NSColor(white: 0.72, alpha: 1.0)
        ]
        let artistAstr = NSAttributedString(string: artist, attributes: artistAttrs)
        artistAstr.draw(in: NSRect(x: infoX, y: 67, width: maxW, height: 16))

        // 3. Real Scrub Progress Bar (Matches exact track duration & position)
        let pos = DuckState.shared.currentPosition
        let dur = DuckState.shared.currentDuration
        let progressPercent: CGFloat = dur > 0 ? CGFloat(min(1.0, max(0.0, pos / dur))) : 0.0

        let scrubW: CGFloat = isMirror ? 104.0 : 130.0
        let scrubRect = NSRect(x: infoX, y: 56, width: scrubW, height: 3)
        NSColor(white: 0.25, alpha: 1.0).setFill()
        NSBezierPath(roundedRect: scrubRect, xRadius: 1.5, yRadius: 1.5).fill()

        let fillW = max(2.0, scrubRect.width * progressPercent)
        let fillRect = NSRect(x: infoX, y: 56, width: fillW, height: 3)
        NSColor(white: 0.85, alpha: 1.0).setFill()
        NSBezierPath(roundedRect: fillRect, xRadius: 1.5, yRadius: 1.5).fill()

        // Real Elapsed & Total Track Duration labels
        let timeAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: 9, weight: .regular),
            .foregroundColor: NSColor(white: 0.60, alpha: 1.0)
        ]
        let mPos = Int(pos) / 60
        let sPos = Int(pos) % 60
        let elapsedStr = String(format: "%d:%02d", mPos, sPos)

        let mDur = Int(dur) / 60
        let sDur = Int(dur) % 60
        let durStr = dur > 0 ? String(format: "%d:%02d", mDur, sDur) : "0:00"

        NSAttributedString(string: elapsedStr, attributes: timeAttrs).draw(at: NSPoint(x: infoX, y: 43))
        let durAstr = NSAttributedString(string: durStr, attributes: timeAttrs)
        let durSz = durAstr.size()
        durAstr.draw(at: NSPoint(x: infoX + scrubW - durSz.width, y: 43))

        // 4. Playback Controls (⏮ ▶ ⏭)
        let btnPrevX: CGFloat = isMirror ? 96 : 104
        let btnPlayX: CGFloat = isMirror ? 134 : 148
        let btnNextX: CGFloat = isMirror ? 172 : 192

        if let imgPrev = NSImage(systemSymbolName: "backward.end.fill", accessibilityDescription: nil) {
            let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .bold)
            if let cfg = imgPrev.withSymbolConfiguration(config) {
                let tinted = tintImage(cfg, color: NSColor(white: 0.85, alpha: 1.0))
                tinted.draw(in: NSRect(x: btnPrevX, y: 14, width: 14, height: 14))
            }
        }

        let playSym = isPlaying ? "pause.fill" : "play.fill"
        if let imgPlay = NSImage(systemSymbolName: playSym, accessibilityDescription: nil) {
            let config = NSImage.SymbolConfiguration(pointSize: 18, weight: .heavy)
            if let cfg = imgPlay.withSymbolConfiguration(config) {
                let tinted = tintImage(cfg, color: .white)
                tinted.draw(in: NSRect(x: btnPlayX, y: 12, width: 18, height: 18))
            }
        }

        if let imgNext = NSImage(systemSymbolName: "forward.end.fill", accessibilityDescription: nil) {
            let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .bold)
            if let cfg = imgNext.withSymbolConfiguration(config) {
                let tinted = tintImage(cfg, color: NSColor(white: 0.85, alpha: 1.0))
                tinted.draw(in: NSRect(x: btnNextX, y: 14, width: 14, height: 14))
            }
        }
    }

    private func drawMiniSpotifyBadge(rect: NSRect) {
        NSColor(red: 0.11, green: 0.73, blue: 0.33, alpha: 1.0).setFill()
        NSBezierPath(ovalIn: rect).fill()
        NSColor.black.setStroke()
        let b = NSBezierPath(ovalIn: rect)
        b.lineWidth = 1.0
        b.stroke()

        let waveColor = NSColor.black
        waveColor.setStroke()

        let w1 = NSBezierPath()
        w1.move(to: NSPoint(x: rect.minX + 4.5, y: rect.minY + 11.5))
        w1.curve(to: NSPoint(x: rect.maxX - 4.5, y: rect.minY + 13.5),
                 controlPoint1: NSPoint(x: rect.minX + 7, y: rect.minY + 14),
                 controlPoint2: NSPoint(x: rect.maxX - 7, y: rect.minY + 14.5))
        w1.lineWidth = 1.5
        w1.lineCapStyle = .round
        w1.stroke()

        let w2 = NSBezierPath()
        w2.move(to: NSPoint(x: rect.minX + 5.5, y: rect.minY + 8.5))
        w2.curve(to: NSPoint(x: rect.maxX - 5.5, y: rect.minY + 10.0),
                 controlPoint1: NSPoint(x: rect.minX + 8, y: rect.minY + 10.5),
                 controlPoint2: NSPoint(x: rect.maxX - 8, y: rect.minY + 11.0))
        w2.lineWidth = 1.3
        w2.lineCapStyle = .round
        w2.stroke()

        let w3 = NSBezierPath()
        w3.move(to: NSPoint(x: rect.minX + 6.5, y: rect.minY + 6.0))
        w3.curve(to: NSPoint(x: rect.maxX - 6.5, y: rect.minY + 7.0),
                 controlPoint1: NSPoint(x: rect.minX + 8.5, y: rect.minY + 7.5),
                 controlPoint2: NSPoint(x: rect.maxX - 8.5, y: rect.minY + 8.0))
        w3.lineWidth = 1.1
        w3.lineCapStyle = .round
        w3.stroke()
    }
    // MARK: - Column 2: Calendar & Controls
    private func drawCalendarColumn(calX: CGFloat) {
        // 1. Month & Year (e.g. Sep 2026)
        let now = Date()
        let cal = Calendar.current
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"

        let monthStr = monthFormatter.string(from: now)
        let yearStr = yearFormatter.string(from: now)

        let monthAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 14, weight: .heavy),
            .foregroundColor: NSColor.white
        ]
        NSAttributedString(string: monthStr, attributes: monthAttrs).draw(at: NSPoint(x: calX + 2, y: 84))

        let yearAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: NSColor(white: 0.60, alpha: 1.0)
        ]
        NSAttributedString(string: yearStr, attributes: yearAttrs).draw(at: NSPoint(x: calX + 2, y: 68))

        // 2. Mini Week Calendar (5-day strip matching boringNotch)
        let isMirror = windowController?.isMirrorOpen ?? false
        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let daySpacing: CGFloat = isMirror ? 26.0 : 31.0
        let startX = calX + (isMirror ? 38.0 : 46.0)

        for offset in -2...2 {
            guard let date = cal.date(byAdding: .day, value: offset, to: now) else { continue }
            let dayNum = cal.component(.day, from: date)
            let weekday = cal.component(.weekday, from: date)
            let dayName = dayNames[(weekday - 1) % 7]

            let colCenterX = startX + CGFloat(offset + 2) * daySpacing + (isMirror ? 12.0 : 14.0)
            let isToday = (offset == 0)

            let badgeSize: CGFloat = isMirror ? 20.0 : 22.0
            let circleBadge = NSRect(x: colCenterX - badgeSize / 2.0, y: 58, width: badgeSize, height: badgeSize)

            if isToday {
                // 1. Navy blue rounded capsule - perfectly centered
                let capW: CGFloat = isMirror ? 24.0 : 28.0
                let capRect = NSRect(x: colCenterX - capW / 2.0, y: 54, width: capW, height: 48)
                let cap = NSBezierPath(roundedRect: capRect, xRadius: 8, yRadius: 8)
                NSColor(red: 0.06, green: 0.22, blue: 0.48, alpha: 1.0).setFill()
                cap.fill()

                // 2. Circular bright blue badge - concentric and centered
                NSColor(red: 0.08, green: 0.48, blue: 0.98, alpha: 1.0).setFill()
                NSBezierPath(ovalIn: circleBadge).fill()
            }

            // Day Name (e.g. Wed) - 100% horizontally centered
            let nameAttrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 9.5, weight: isToday ? .bold : .medium),
                .foregroundColor: isToday ? NSColor.white : NSColor(white: 0.50, alpha: 1.0)
            ]
            let nameStr = NSAttributedString(string: dayName, attributes: nameAttrs)
            let nameSz = nameStr.size()
            nameStr.draw(at: NSPoint(x: colCenterX - nameSz.width / 2.0, y: 86))

            // Day Number (e.g. 16) - 100% horizontally and vertically centered inside circleBadge
            let numAttrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: isMirror ? 11 : 12, weight: isToday ? .heavy : .semibold),
                .foregroundColor: isToday ? NSColor.white : NSColor(white: 0.80, alpha: 1.0)
            ]
            let numStr = NSAttributedString(string: "\(dayNum)", attributes: numAttrs)
            let numSz = numStr.size()
            let numY = circleBadge.midY - numSz.height / 2.0 + 0.5
            numStr.draw(at: NSPoint(x: colCenterX - numSz.width / 2.0, y: numY))
        }

        // 3. Bottom of Calendar Column
        let hasMusic = DuckState.shared.isPlayingMusic && !DuckState.shared.currentTrack.isEmpty

        if !hasMusic && !isMirror {
            // In 400pt idle mode: Spotify transport controls (Prev, Play, Next)
            // Previous Track (centered under calendar)
            if let imgPrev = NSImage(systemSymbolName: "backward.end.fill", accessibilityDescription: nil) {
                let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .bold)
                if let cfg = imgPrev.withSymbolConfiguration(config) {
                    let tinted = tintImage(cfg, color: NSColor(white: 0.80, alpha: 1.0))
                    tinted.draw(in: NSRect(x: 62, y: 20, width: 14, height: 14))
                }
            }

            // Play / Pause Circle (Solid White Button with Black Icon, perfectly centered at x = 117)
            let playRect = NSRect(x: 102, y: 13, width: 30, height: 30)
            NSColor.white.setFill()
            NSBezierPath(ovalIn: playRect).fill()

            let isPlaying = DuckState.shared.isPlayingMusic
            let playSym = isPlaying ? "pause.fill" : "play.fill"
            if let imgPlay = NSImage(systemSymbolName: playSym, accessibilityDescription: nil) {
                let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .heavy)
                if let cfg = imgPlay.withSymbolConfiguration(config) {
                    let tinted = tintImage(cfg, color: .black)
                    let sz = cfg.size
                    let offset: CGFloat = isPlaying ? 0.0 : 1.0
                    let ix = playRect.midX - sz.width / 2.0 + offset
                    let iy = playRect.midY - sz.height / 2.0
                    tinted.draw(in: NSRect(x: ix, y: iy, width: sz.width, height: sz.height))
                }
            }

            // Next Track (centered under calendar)
            if let imgNext = NSImage(systemSymbolName: "forward.end.fill", accessibilityDescription: nil) {
                let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .bold)
                if let cfg = imgNext.withSymbolConfiguration(config) {
                    let tinted = tintImage(cfg, color: NSColor(white: 0.80, alpha: 1.0))
                    tinted.draw(in: NSRect(x: 158, y: 20, width: 14, height: 14))
                }
            }
        } else {
            // When expanded with music or mirror: Event or Pomodoro status
            if DuckState.shared.isPomodoroActive {
                if let imgTimer = NSImage(systemSymbolName: "timer", accessibilityDescription: nil) {
                    let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .bold)
                    if let cfg = imgTimer.withSymbolConfiguration(config) {
                        let tinted = tintImage(cfg, color: NSColor(red: 1.0, green: 0.28, blue: 0.22, alpha: 1.0))
                        tinted.draw(in: NSRect(x: calX + 46 + 64, y: 38, width: 18, height: 18))
                    }
                }
                let m = PomodoroManager.shared.remainingSeconds / 60
                let s = PomodoroManager.shared.remainingSeconds % 60
                let pomoStr = String(format: "🍅 Pomodoro: %02d:%02d", m, s)
                let pStyle = NSMutableParagraphStyle()
                pStyle.alignment = .center
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: NSFont.systemFont(ofSize: 12, weight: .bold),
                    .foregroundColor: NSColor(red: 1.0, green: 0.28, blue: 0.22, alpha: 1.0),
                    .paragraphStyle: pStyle
                ]
                NSAttributedString(string: pomoStr, attributes: attrs).draw(in: NSRect(x: calX + 46, y: 20, width: 146, height: 16))

                let subAttrs: [NSAttributedString.Key: Any] = [
                    .font: NSFont.systemFont(ofSize: 10, weight: .regular),
                    .foregroundColor: NSColor(white: 0.60, alpha: 1.0),
                    .paragraphStyle: pStyle
                ]
                NSAttributedString(string: "Stay focused & keep going!", attributes: subAttrs).draw(in: NSRect(x: calX + 46, y: 7, width: 146, height: 14))
            } else {
                // REAL-TIME WEATHER WIDGET (Dynamic Island Notch)
                let centerAreaX = startX + (isMirror ? 52.0 : 62.0)
                let textW: CGFloat = isMirror ? 126.0 : 146.0
                let textX = startX + (isMirror ? -4.0 : 0.0)

                let iconName = DuckState.shared.weatherIcon.isEmpty ? "cloud.sun.fill" : DuckState.shared.weatherIcon
                if let imgWeather = NSImage(systemSymbolName: iconName, accessibilityDescription: nil) {
                    let config = NSImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
                    if let cfg = imgWeather.withSymbolConfiguration(config) {
                        let iconColor: NSColor
                        if DuckState.shared.isRaining {
                            iconColor = NSColor(red: 0.38, green: 0.78, blue: 1.0, alpha: 1.0)
                        } else if DuckState.shared.isNight {
                            iconColor = NSColor(red: 0.75, green: 0.82, blue: 1.0, alpha: 1.0)
                        } else {
                            iconColor = NSColor(red: 1.0, green: 0.82, blue: 0.22, alpha: 1.0)
                        }
                        let tinted = tintImage(cfg, color: iconColor)
                        tinted.draw(in: NSRect(x: centerAreaX, y: 38, width: 20, height: 18))
                    }
                }

                let pStyle = NSMutableParagraphStyle()
                pStyle.alignment = .center
                let titleAttrs: [NSAttributedString.Key: Any] = [
                    .font: NSFont.systemFont(ofSize: 12.5, weight: .heavy),
                    .foregroundColor: NSColor.white,
                    .paragraphStyle: pStyle
                ]
                let tempStr = String(format: "%.0f°C • %@", DuckState.shared.weatherTemp, DuckState.shared.weatherCity)
                NSAttributedString(string: tempStr, attributes: titleAttrs).draw(in: NSRect(x: textX, y: 20, width: textW, height: 16))

                let subAttrs: [NSAttributedString.Key: Any] = [
                    .font: NSFont.systemFont(ofSize: 10, weight: .medium),
                    .foregroundColor: NSColor(white: 0.65, alpha: 1.0),
                    .paragraphStyle: pStyle
                ]
                let condStr = DuckState.shared.weatherCondition.isEmpty ? "Partly Cloudy" : DuckState.shared.weatherCondition
                NSAttributedString(string: condStr, attributes: subAttrs).draw(in: NSRect(x: textX, y: 6, width: textW, height: 14))
            }
        }
    }

    private func tintImage(_ image: NSImage, color: NSColor) -> NSImage {
        let tinted = image.copy() as! NSImage
        tinted.lockFocus()
        color.set()
        let imageRect = NSRect(origin: .zero, size: tinted.size)
        imageRect.fill(using: .sourceAtop)
        tinted.unlockFocus()
        return tinted
    }
}

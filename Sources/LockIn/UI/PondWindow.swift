import AppKit

public class PondView: NSView {
    public weak var windowController: PondWindow?
    private var tick = 0

    // Palette
    private let grassDark    = NSColor(red: 0.28, green: 0.55, blue: 0.22, alpha: 0.90)
    private let grassLight   = NSColor(red: 0.42, green: 0.72, blue: 0.28, alpha: 0.95)
    private let waterDeep    = NSColor(red: 0.12, green: 0.42, blue: 0.72, alpha: 0.85)
    private let waterMid     = NSColor(red: 0.20, green: 0.62, blue: 0.90, alpha: 0.88)
    private let waterShine   = NSColor(red: 0.60, green: 0.90, blue: 1.00, alpha: 0.75)
    private let lilyGreen    = NSColor(red: 0.15, green: 0.68, blue: 0.35, alpha: 1.00)
    private let lilyDark     = NSColor(red: 0.10, green: 0.50, blue: 0.25, alpha: 1.00)
    private let flowerPink   = NSColor(red: 1.00, green: 0.45, blue: 0.65, alpha: 1.00)
    private let flowerCenter = NSColor(red: 1.00, green: 0.90, blue: 0.20, alpha: 1.00)

    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        tick += 1

        let w = bounds.width
        let h = bounds.height

        // 1. Soft Bank Shadow
        let shadowPath = NSBezierPath(ovalIn: NSRect(x: 4, y: 2, width: w - 8, height: h - 14))
        NSColor(calibratedWhite: 0.0, alpha: 0.18).setFill()
        shadowPath.fill()

        // 2. Grassy Shore Edge (Outer & Inner)
        let shorePath = NSBezierPath(ovalIn: NSRect(x: 6, y: 5, width: w - 12, height: h - 15))
        grassDark.setFill()
        shorePath.fill()

        let shoreInner = NSBezierPath(ovalIn: NSRect(x: 10, y: 7, width: w - 20, height: h - 19))
        grassLight.setFill()
        shoreInner.fill()

        // 3. Deep Water Pool (Day / Night Twilight)
        let isNight = DuckState.shared.isNightTime
        let curWaterDeep = isNight ? NSColor(red: 0.04, green: 0.12, blue: 0.28, alpha: 0.96) : waterDeep
        let curWaterMid  = isNight ? NSColor(red: 0.07, green: 0.20, blue: 0.40, alpha: 0.90) : waterMid
        let curWaterShine = isNight ? NSColor(red: 0.45, green: 0.78, blue: 0.98, alpha: 0.45) : waterShine

        let waterRect = NSRect(x: 15, y: 9, width: w - 30, height: h - 23)
        let waterPath = NSBezierPath(ovalIn: waterRect)
        curWaterDeep.setFill()
        waterPath.fill()

        // Water Gradient / Mid Pool
        let waterInnerRect = NSRect(x: 19, y: 12, width: w - 38, height: h - 29)
        let waterInnerPath = NSBezierPath(ovalIn: waterInnerRect)
        curWaterMid.setFill()
        waterInnerPath.fill()

        // 4. Animated Water Waves & Ripples
        let wavePhase = CGFloat(tick % 120) / 120.0
        let waveOff1 = sin(wavePhase * .pi * 2.0) * 4.0
        let waveOff2 = cos(wavePhase * .pi * 2.0) * 3.5

        ctx.setFillColor(curWaterShine.cgColor)
        // Shimmer wave 1 (left pool)
        ctx.fill(CGRect(x: 35 + waveOff1, y: 20, width: 34, height: 2.0))
        // Shimmer wave 2 (center-right pool)
        ctx.fill(CGRect(x: 125 + waveOff2, y: 16, width: 40, height: 2.0))
        // Shimmer wave 3 (center pool)
        ctx.fill(CGRect(x: 80 - waveOff1, y: 13, width: 28, height: 1.8))

        // 5. Lilypad #1 with Lotus Flower (Left side)
        let pad1Rect = NSRect(x: 25, y: 15, width: 25, height: 14)
        lilyDark.setFill()
        NSBezierPath(ovalIn: pad1Rect).fill()
        lilyGreen.setFill()
        NSBezierPath(ovalIn: NSRect(x: 27, y: 16, width: 21, height: 11)).fill()

        // Tiny Lotus Flower on Lilypad #1
        let flX: CGFloat = 36
        let flY: CGFloat = 20
        ctx.setFillColor(flowerPink.cgColor)
        ctx.fill(CGRect(x: flX - 3, y: flY, width: 3, height: 4))
        ctx.fill(CGRect(x: flX + 2, y: flY, width: 3, height: 4))
        ctx.fill(CGRect(x: flX - 1, y: flY + 2, width: 4, height: 3))
        ctx.setFillColor(flowerCenter.cgColor)
        ctx.fill(CGRect(x: flX, y: flY + 1, width: 2, height: 2))

        // Lilypad #2 (Right side)
        let pad2Rect = NSRect(x: w - 50, y: 16, width: 22, height: 12)
        lilyDark.setFill()
        NSBezierPath(ovalIn: pad2Rect).fill()
        lilyGreen.setFill()
        NSBezierPath(ovalIn: NSRect(x: w - 48, y: 17, width: 18, height: 10)).fill()

        // 6. Grass blades on pond edge
        ctx.setFillColor(grassLight.cgColor)
        ctx.fill(CGRect(x: 18, y: 26, width: 2, height: 6))
        ctx.fill(CGRect(x: 21, y: 28, width: 2, height: 5))
        ctx.fill(CGRect(x: w - 24, y: 26, width: 2, height: 6))
        ctx.fill(CGRect(x: w - 21, y: 28, width: 2, height: 5))

        // 7. Night Fireflies over the Pond
        if isNight {
            ctx.saveGState()
            ctx.setShouldAntialias(false)
            let phase1 = CGFloat((tick + 10) % 120) / 120.0
            let p1 = 0.4 + 0.6 * sin(phase1 * .pi * 2.0)
            let p1X = 65.0 + sin(CGFloat(tick) * 0.03) * 20.0
            let p1Y = 26.0 + cos(CGFloat(tick) * 0.04) * 8.0
            DuckSpriteRenderer.shared.drawPixelFirefly(ctx: ctx, at: CGPoint(x: p1X, y: p1Y), pulse: p1)

            let phase2 = CGFloat((tick + 70) % 140) / 140.0
            let p2 = 0.4 + 0.6 * sin(phase2 * .pi * 2.0)
            let p2X = 175.0 + cos(CGFloat(tick) * 0.025) * 22.0
            let p2Y = 22.0 + sin(CGFloat(tick) * 0.035) * 9.0
            DuckSpriteRenderer.shared.drawPixelFirefly(ctx: ctx, at: CGPoint(x: p2X, y: p2Y), pulse: p2)

            let phase3 = CGFloat((tick + 40) % 100) / 100.0
            let p3 = 0.4 + 0.6 * sin(phase3 * .pi * 2.0)
            let p3X = 120.0 + sin(CGFloat(tick) * 0.035) * 16.0
            let p3Y = 32.0 + cos(CGFloat(tick) * 0.025) * 7.0
            DuckSpriteRenderer.shared.drawPixelFirefly(ctx: ctx, at: CGPoint(x: p3X, y: p3Y), pulse: p3)
            ctx.restoreGState()
        }

        // 8. Cozy Rain Ripples on the Pond
        if DuckState.shared.isRainMode {
            ctx.saveGState()
            ctx.setShouldAntialias(false)

            // Falling raindrops
            for i in 0..<5 {
                let rx = CGFloat((tick * 5 + i * 46) % Int(w - 30)) + 15
                let ry = h - CGFloat((tick * 6 + i * 36) % Int(h))
                DuckSpriteRenderer.shared.drawPixelRaindrop(ctx: ctx, at: CGPoint(x: rx, y: ry), length: 6.0)
            }

            // Expanding water ripple rings
            let rPhase1 = CGFloat(tick % 45) / 45.0
            let rRadius1 = rPhase1 * 16.0
            let rAlpha1 = max(0.0, 1.0 - rPhase1) * 0.60
            let ripPath1 = NSBezierPath(ovalIn: NSRect(x: 95 - rRadius1, y: 20 - rRadius1 * 0.4, width: rRadius1 * 2, height: rRadius1 * 0.8))
            NSColor(red: 0.65, green: 0.88, blue: 1.0, alpha: rAlpha1).setStroke()
            ripPath1.lineWidth = 1.0
            ripPath1.stroke()

            let rPhase2 = CGFloat((tick + 22) % 45) / 45.0
            let rRadius2 = rPhase2 * 14.0
            let rAlpha2 = max(0.0, 1.0 - rPhase2) * 0.55
            let ripPath2 = NSBezierPath(ovalIn: NSRect(x: 160 - rRadius2, y: 17 - rRadius2 * 0.4, width: rRadius2 * 2, height: rRadius2 * 0.8))
            NSColor(red: 0.65, green: 0.88, blue: 1.0, alpha: rAlpha2).setStroke()
            ripPath2.lineWidth = 1.0
            ripPath2.stroke()

            ctx.restoreGState()
        }
    }

    public func tickPond() {
        self.needsDisplay = true
    }

    // Interactive Dragging Handlers
    public override func mouseDown(with e: NSEvent) {
        windowController?.handleMouseDown(with: e)
    }

    public override func mouseDragged(with e: NSEvent) {
        windowController?.handleMouseDragged(with: e)
    }

    public override func mouseUp(with e: NSEvent) {
        windowController?.handleMouseUp(with: e)
    }

    public override func rightMouseDown(with e: NSEvent) {
        windowController?.showContextMenu(with: e)
    }
}

public class PondWindow: NSPanel {
    public static var shared: PondWindow?

    private var pondView: PondView!
    private var timer: Timer?

    private var isDragging = false
    private var dragStartMouse = NSPoint.zero
    private var dragStartWin = NSPoint.zero

    public init() {
        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let pondW: CGFloat = 240
        let pondH: CGFloat = 65
        let pondX: CGFloat = screen.maxX - pondW - 16
        let pondY: CGFloat = screen.minY + 2

        let frame = NSRect(x: pondX, y: pondY, width: pondW, height: pondH)

        super.init(
            contentRect: frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        self.level = NSWindow.Level(rawValue: NSWindow.Level.floating.rawValue - 1)
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.ignoresMouseEvents = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        self.pondView = PondView(frame: NSRect(x: 0, y: 0, width: pondW, height: pondH))
        self.pondView.windowController = self
        self.contentView = pondView

        DuckState.shared.pondRect = frame
        PondWindow.shared = self

        startLoop()
    }

    private func startLoop() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.pondView.tickPond()
        }
    }

    // MARK: – Dragging Support
    public func handleMouseDown(with e: NSEvent) {
        isDragging = true
        dragStartMouse = NSEvent.mouseLocation
        dragStartWin = frame.origin
    }

    public func handleMouseDragged(with e: NSEvent) {
        guard isDragging else { return }
        let m = NSEvent.mouseLocation
        let newX = dragStartWin.x + m.x - dragStartMouse.x
        let newY = dragStartWin.y + m.y - dragStartMouse.y
        let oldOrigin = frame.origin
        let newOrigin = NSPoint(x: newX, y: newY)
        setFrameOrigin(newOrigin)

        DuckState.shared.pondRect = frame

        // If the duck is currently swimming in this pond, smoothly carry the duck along!
        if DuckState.shared.isPondLocked {
            let dx = newOrigin.x - oldOrigin.x
            let dy = newOrigin.y - oldOrigin.y
            DuckWindow.shared?.shiftPosition(dx: dx, dy: dy)
        }
    }

    public func handleMouseUp(with e: NSEvent) {
        guard isDragging else { return }
        isDragging = false
        DuckState.shared.pondRect = frame
    }

    public func resetPosition() {
        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let pondW: CGFloat = 240
        let pondX: CGFloat = screen.maxX - pondW - 16
        let pondY: CGFloat = screen.minY + 2
        let oldOrigin = frame.origin
        let newOrigin = NSPoint(x: pondX, y: pondY)

        setFrameOrigin(newOrigin)
        DuckState.shared.pondRect = frame

        if DuckState.shared.isPondLocked {
            let dx = newOrigin.x - oldOrigin.x
            let dy = newOrigin.y - oldOrigin.y
            DuckWindow.shared?.shiftPosition(dx: dx, dy: dy)
        }
    }

    public func showContextMenu(with e: NSEvent) {
        let menu = NSMenu()
        let t = NSMenuItem(title: "Cozy Pond", action: nil, keyEquivalent: "")
        t.isEnabled = false
        menu.addItem(t)
        menu.addItem(.separator())

        let atmosSub = NSMenu()
        let autoItem = NSMenuItem(title: "Auto Day/Night (by Clock)", action: #selector(toggleAutoDayNight), keyEquivalent: "")
        autoItem.target = self
        autoItem.state = DuckState.shared.isAutoDayNight ? .on : .off
        atmosSub.addItem(autoItem)

        let nightItem = NSMenuItem(title: "Night Mode (Fireflies)", action: #selector(toggleNightMode), keyEquivalent: "")
        nightItem.target = self
        nightItem.state = (!DuckState.shared.isAutoDayNight && DuckState.shared.isNightMode) ? .on : .off
        atmosSub.addItem(nightItem)

        atmosSub.addItem(.separator())
        let rainItem = NSMenuItem(title: "Cozy Rain Mode", action: #selector(toggleRainMode), keyEquivalent: "")
        rainItem.target = self
        rainItem.state = DuckState.shared.isRainMode ? .on : .off
        atmosSub.addItem(rainItem)

        let atmosParent = NSMenuItem(title: "Cozy Atmosphere", action: nil, keyEquivalent: "")
        atmosParent.submenu = atmosSub
        menu.addItem(atmosParent)

        menu.addItem(.separator())

        let resetItem = NSMenuItem(title: "Reset Pond to Bottom Right", action: #selector(menuResetPond), keyEquivalent: "")
        resetItem.target = self
        menu.addItem(resetItem)

        NSMenu.popUpContextMenu(menu, with: e, for: pondView)
    }

    @objc private func toggleAutoDayNight() {
        DuckState.shared.isAutoDayNight.toggle()
        pondView.needsDisplay = true
        DuckWindow.shared?.contentView?.needsDisplay = true
    }

    @objc private func toggleNightMode() {
        DuckState.shared.isAutoDayNight = false
        DuckState.shared.isNightMode.toggle()
        pondView.needsDisplay = true
        DuckWindow.shared?.contentView?.needsDisplay = true
    }

    @objc private func toggleRainMode() {
        DuckState.shared.isRainMode.toggle()
        pondView.needsDisplay = true
        DuckWindow.shared?.contentView?.needsDisplay = true
    }

    @objc private func menuResetPond() {
        resetPosition()
    }
}

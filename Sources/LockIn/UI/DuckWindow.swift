import AppKit

// MARK: – DuckView

public class DuckView: NSView {
    public weak var windowController: DuckWindow?
    private var currentScale: CGFloat = 1.0

    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let ctrl = windowController else { return }

        let isPomodoro = DuckState.shared.isPomodoroActive
        let isMusic = DuckState.shared.isPlayingMusic

        // 1. Water status & smooth scale transition
        let inWater = !isPomodoro && (DuckState.shared.currentAction == .swimming ||
                       DuckState.shared.currentAction == .swimLeft  ||
                       DuckState.shared.currentAction == .swimRight ||
                       DuckState.shared.isPondLocked)

        // Reminder: Scale up to giant duck in center screen!
        let isReminding = ReminderManager.shared.isReminding
        let targetScale: CGFloat = isReminding ? 1.65 : (inWater ? (60.0 / 96.0) : 1.0)
        currentScale += (targetScale - currentScale) * 0.22
        let drawW = 96.0 * currentScale
        let drawH = 128.0 * currentScale
        let drawSize = drawW

        // 2. Ground shadow (only on land and not giant reminder)
        if !inWater && currentScale > 0.8 && !isReminding {
            let shadowW = 56.0 * currentScale
            let shadowX = isPomodoro ? 28.0 : (bounds.width - shadowW) / 2
            let sh = NSBezierPath(ovalIn: NSRect(x: shadowX, y: 4, width: shadowW, height: 8))
            NSColor(calibratedWhite: 0.0, alpha: 0.18).setFill()
            sh.fill()
        }

        // 3. Duck sprite
        let sprite = DuckSpriteRenderer.shared.getFrame(
            action:         DuckState.shared.currentAction,
            tick:           ctrl.tick,
            facingLeft:     DuckState.shared.facingLeft,
            isPlayingMusic: isMusic,
            eyeOffsetX:     DuckState.shared.eyeOffsetX,
            eyeOffsetY:     DuckState.shared.eyeOffsetY,
            isTyping:       DuckState.shared.isTyping
        )
        let drawX = (isPomodoro && !isReminding) ? 8.0 : (bounds.width - drawW) / 2
        let drawY = isReminding ? 24.0 : (inWater ? 6.0 : 8.0)
        sprite.draw(in: NSRect(x: drawX, y: drawY, width: drawW, height: drawH))

        // 3.5. Overheat Typing Smoke Puffs
        if DuckState.shared.isOverheating && DuckState.shared.isTyping {
            if let ctx = NSGraphicsContext.current?.cgContext {
                ctx.saveGState()
                ctx.setShouldAntialias(false)
                let duckMidX = drawX + drawSize / 2
                DuckSpriteRenderer.shared.drawPixelSmoke(ctx: ctx, at: CGPoint(x: duckMidX, y: drawY + 12.0), tick: ctrl.tick)
                ctx.restoreGState()
            }
        }

        // 3.6. Night Fireflies around Duck
        if DuckState.shared.isNightTime {
            if let ctx = NSGraphicsContext.current?.cgContext {
                ctx.saveGState()
                ctx.setShouldAntialias(false)
                let phase1 = CGFloat((ctrl.tick + 20) % 90) / 90.0
                let pulse1 = 0.5 + 0.5 * sin(phase1 * .pi * 2.0)
                let fx1 = drawX - 10.0 + sin(CGFloat(ctrl.tick) * 0.04) * 8.0
                let fy1 = drawY + 20.0 + cos(CGFloat(ctrl.tick) * 0.05) * 6.0
                DuckSpriteRenderer.shared.drawPixelFirefly(ctx: ctx, at: CGPoint(x: fx1, y: fy1), pulse: pulse1)

                let phase2 = CGFloat((ctrl.tick + 65) % 110) / 110.0
                let pulse2 = 0.5 + 0.5 * sin(phase2 * .pi * 2.0)
                let fx2 = drawX + drawSize + 6.0 + cos(CGFloat(ctrl.tick) * 0.035) * 7.0
                let fy2 = drawY + 36.0 + sin(CGFloat(ctrl.tick) * 0.045) * 8.0
                DuckSpriteRenderer.shared.drawPixelFirefly(ctx: ctx, at: CGPoint(x: fx2, y: fy2), pulse: pulse2)
                ctx.restoreGState()
            }
        }

        // 3.7. Cozy Rain Drops
        if DuckState.shared.isRainMode {
            if let ctx = NSGraphicsContext.current?.cgContext {
                ctx.saveGState()
                ctx.setShouldAntialias(false)
                for i in 0..<3 {
                    let rx = CGFloat((ctrl.tick * 5 + i * 45) % Int(max(bounds.width, 100)))
                    let ry = bounds.height - CGFloat((ctrl.tick * 6 + i * 35) % Int(max(bounds.height, 80)))
                    DuckSpriteRenderer.shared.drawPixelRaindrop(ctx: ctx, at: CGPoint(x: rx, y: ry), length: 6.0)
                }
                ctx.restoreGState()
            }
        }

        // 4. Pomodoro Signboard (Papan Timer)
        if isPomodoro && !isReminding {
            let boardRect = NSRect(x: 104, y: 8, width: 96, height: 96)
            DuckSpriteRenderer.shared.drawPomodoroBoard(
                in: boardRect,
                mode: PomodoroManager.shared.mode,
                timeString: PomodoroManager.shared.timeString,
                progress: PomodoroManager.shared.progress,
                isPaused: PomodoroManager.shared.status == .paused
            )
        }

        // 5. Floating Pixel Heart particle on click (authentic sprite)
        if ctrl.heartProgress > 0 {
            let alpha = 1.0 - ctrl.heartProgress
            if let ctx = NSGraphicsContext.current?.cgContext {
                ctx.saveGState()
                ctx.setShouldAntialias(false)
                let heartX = drawX + drawSize / 2 + 8
                let heartY = 78 + ctrl.heartProgress * 24
                DuckSpriteRenderer.shared.drawPixelHeart(ctx: ctx, at: CGPoint(x: heartX, y: heartY), scale: 2.0, alpha: alpha)
                ctx.restoreGState()
            }
        }

        // 5.5. Focus Task Speech Bubble on Duck (shown during Pomodoro with authentic target sprite, centered)
        if isPomodoro && !DuckState.shared.focusTask.isEmpty && !ReminderManager.shared.isReminding {
            let displayText = DuckState.shared.focusTask
            let font = NSFont.systemFont(ofSize: 10.5, weight: .bold)
            let padH: CGFloat = 8.0
            let padV: CGFloat = 5.0
            let iconW: CGFloat = 10.0
            let iconGap: CGFloat = 5.0

            let pStyle = NSMutableParagraphStyle()
            pStyle.alignment = .center
            pStyle.lineBreakMode = .byTruncatingTail
            let textAttrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: NSColor(white: 0.98, alpha: 1.0),
                .paragraphStyle: pStyle
            ]

            let str = NSAttributedString(string: displayText, attributes: textAttrs)
            let strSize = str.size()
            let maxBubbleW: CGFloat = 135.0
            let contentW = iconW + iconGap + strSize.width
            let bubbleW = min(max(contentW + padH * 2, 60.0), maxBubbleW)
            let bubbleH = strSize.height + padV * 2

            let duckMidX = drawX + drawSize / 2
            let bubbleX = max(4.0, min(bounds.width - bubbleW - 4.0, duckMidX - bubbleW / 2))
            let bubbleY = bounds.height - bubbleH - 5.0
            let bubbleRect = NSRect(x: bubbleX, y: bubbleY, width: bubbleW, height: bubbleH)

            let bubblePath = NSBezierPath(roundedRect: bubbleRect, xRadius: 8, yRadius: 8)
            let bgColor = NSColor(red: 0.08, green: 0.10, blue: 0.16, alpha: 0.94)
            bgColor.setFill()
            bubblePath.fill()

            let borderColor = NSColor(red: 1.0, green: 0.82, blue: 0.28, alpha: 0.90) // Golden border
            borderColor.setStroke()
            bubblePath.lineWidth = 1.3
            bubblePath.stroke()

            let pointer = NSBezierPath()
            let ptrX = min(max(duckMidX, bubbleX + 12), bubbleX + bubbleW - 12)
            pointer.move(to: NSPoint(x: ptrX - 4.5, y: bubbleY))
            pointer.line(to: NSPoint(x: ptrX + 4.5, y: bubbleY))
            pointer.line(to: NSPoint(x: ptrX, y: bubbleY - 4.5))
            pointer.close()
            bgColor.setFill()
            pointer.fill()

            let totalContentW = min(contentW, bubbleW - padH * 2)
            let groupStartX = bubbleRect.midX - totalContentW / 2.0

            if let ctx = NSGraphicsContext.current?.cgContext {
                ctx.saveGState()
                ctx.setShouldAntialias(false)
                let iconX = groupStartX
                let iconY = bubbleY + (bubbleH - 9.0) / 2.0
                DuckSpriteRenderer.shared.drawPixelTarget(ctx: ctx, at: CGPoint(x: iconX, y: iconY), s: 1.2)
                ctx.restoreGState()
            }

            let textX = groupStartX + iconW + iconGap
            let textW = max(0, totalContentW - (iconW + iconGap))
            let textRect = NSRect(
                x: textX,
                y: bubbleY + padV - 0.5,
                width: textW,
                height: strSize.height
            )
            displayText.draw(in: textRect, withAttributes: textAttrs)
        }

        // 6. Hydration Reminder Banner (with authentic pixel water drop sprite)
        if ReminderManager.shared.isReminding {
            let msg = ReminderManager.shared.reminderMessage
            let font = NSFont.systemFont(ofSize: 13.5, weight: .heavy)
            let pStyle = NSMutableParagraphStyle()
            pStyle.alignment = .center
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: NSColor.white,
                .paragraphStyle: pStyle
            ]
            let str = NSAttributedString(string: msg, attributes: attrs)
            let strSize = str.size()
            let iconW: CGFloat = 13.0
            let iconGap: CGFloat = 6.0
            let totalContentW = iconW + iconGap + strSize.width

            let bubbleW = min(totalContentW + 28, bounds.width - 16)
            let bubbleH = strSize.height + 10
            let bubbleX = (bounds.width - bubbleW) / 2
            let bubbleY = bounds.height - bubbleH - 14.0
            let bubbleRect = NSRect(x: bubbleX, y: bubbleY, width: bubbleW, height: bubbleH)

            let bubblePath = NSBezierPath(roundedRect: bubbleRect, xRadius: bubbleH / 2, yRadius: bubbleH / 2)
            NSColor(red: 0.10, green: 0.48, blue: 0.88, alpha: 0.96).setFill()
            bubblePath.fill()
            NSColor(red: 0.45, green: 0.82, blue: 1.0, alpha: 0.98).setStroke()
            bubblePath.lineWidth = 1.4
            bubblePath.stroke()

            let startX = bubbleRect.midX - totalContentW / 2.0
            if let ctx = NSGraphicsContext.current?.cgContext {
                ctx.saveGState()
                ctx.setShouldAntialias(false)
                DuckSpriteRenderer.shared.drawPixelWaterDrop(ctx: ctx, at: CGPoint(x: startX, y: bubbleRect.midY - 6.5), scale: 1.6)
                ctx.restoreGState()
            }

            let textPoint = NSPoint(x: startX + iconW + iconGap, y: bubbleRect.midY - strSize.height / 2)
            str.draw(at: textPoint)
        }

    }

    public override func mouseDown(with e: NSEvent) {
        if ReminderManager.shared.isReminding {
            ReminderManager.shared.dismissReminder()
        }
        windowController?.handleMouseDown(with: e)
    }
    public override func mouseDragged(with e: NSEvent)   { windowController?.handleMouseDragged(with: e) }
    public override func mouseUp(with e: NSEvent)        { windowController?.handleMouseUp(with: e) }
    public override func rightMouseDown(with e: NSEvent) { windowController?.showContextMenu(with: e) }
}

// MARK: – DuckWindow

public class DuckWindow: NSPanel {
    public static weak var shared: DuckWindow?

    public var tick = 0
    public var heartProgress: CGFloat = 0
    public var activePerchWindow: WindowBounds? = nil

    private var duckView: DuckView!
    private var timer: Timer?

    // Physics
    private var posX: CGFloat = 400
    private var posY: CGFloat = 100
    private var velX: CGFloat = 0
    private var velY: CGFloat = 0
    private var currentFloorY: CGFloat = 100
    private let gravity: CGFloat = 1.2

    private var isDragging     = false
    private var dragStartMouse = NSPoint.zero
    private var dragStartWin   = NSPoint.zero

    private var lastActionChange: TimeInterval = 0
    private var actionDuration:  TimeInterval  = 4.0

    public init() {
        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let winW: CGFloat = 120
        let winH: CGFloat = 144
        let rect = NSRect(x: screen.midX - winW / 2, y: screen.minY + 14,
                          width: winW, height: winH)

        super.init(contentRect: rect,
                   styleMask: [.borderless, .nonactivatingPanel],
                   backing: .buffered,
                   defer: false)

        level              = .floating
        isOpaque           = false
        backgroundColor    = .clear
        hasShadow          = false
        isMovableByWindowBackground = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        duckView = DuckView(frame: NSRect(x: 0, y: 0, width: winW, height: winH))
        duckView.windowController = self
        contentView = duckView

        posX = rect.origin.x
        posY = rect.origin.y
        currentFloorY = screen.minY + 10

        DuckWindow.shared = self

        setupSpotify()
        setupPomodoro()
        setupReminders()
        startLoop()
    }

    // MARK: – Global Actions & Shortcuts
    public func summonToCursor() {
        let mouse = NSEvent.mouseLocation
        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let targetX = max(screen.minX, min(screen.maxX - frame.width, mouse.x - frame.width / 2))
        let targetY = max(screen.minY, min(screen.maxY - frame.height, mouse.y - 10))

        if !isVisible {
            makeKeyAndOrderFront(nil)
        }

        DuckState.shared.isPondLocked = false
        activePerchWindow = nil
        velX = 0
        velY = -8.0
        posX = targetX
        posY = targetY
        currentFloorY = targetY
        setFrameOrigin(NSPoint(x: posX, y: posY))
        heartProgress = 0.01
        duckView?.needsDisplay = true
    }

    public func toggleVisibility() {
        if isVisible {
            orderOut(nil)
        } else {
            makeKeyAndOrderFront(nil)
            heartProgress = 0.01
            duckView?.needsDisplay = true
        }
    }

    public func perchOnActiveWindow() {
        guard let win = WindowObserver.shared.getFrontmostWindow() else {
            velY = -8.0
            heartProgress = 0.01
            return
        }

        if !isVisible {
            makeKeyAndOrderFront(nil)
        }

        let screenH = NSScreen.main?.frame.height ?? 900
        let targetFloorY = max(screenH - win.top - 8.0, 50)
        let targetX = max(win.left + 25, min(win.right - frame.width - 25, posX))

        DuckState.shared.isPondLocked = false
        DuckState.shared.stayWherePut = false
        activePerchWindow = win

        posX = targetX
        posY = targetFloorY + 15
        velX = 0
        velY = -5.0
        currentFloorY = targetFloorY
        setFrameOrigin(NSPoint(x: posX, y: posY))
        heartProgress = 0.01
        duckView?.needsDisplay = true
    }

    public func petDuck() {
        heartProgress = 0.01
        DuckState.shared.currentAction = .quack
        DuckState.shared.happiness = min(100.0, DuckState.shared.happiness + 15.0)
        DuckState.shared.energy = min(100.0, DuckState.shared.energy + 10.0)
        duckView?.needsDisplay = true
    }

    public func feedBread() {
        heartProgress = 0.01
        DuckState.shared.currentAction = .peck
        DuckState.shared.hunger = 100.0
        DuckState.shared.energy = min(100.0, DuckState.shared.energy + 25.0)
        duckView?.needsDisplay = true
    }

    public func jump() {
        DuckState.shared.isPondLocked = false
        DuckState.shared.currentAction = .jump
        velY = -10.0
        actionDuration = 1.5
        duckView?.needsDisplay = true
    }

    public func shiftPosition(dx: CGFloat, dy: CGFloat) {
        posX += dx
        posY += dy
        currentFloorY += dy
        setFrameOrigin(NSPoint(x: posX, y: posY))
        duckView.needsDisplay = true
    }

    public func applyJoystick(dx: CGFloat, dy: CGFloat) {
        if !isVisible {
            makeKeyAndOrderFront(nil)
        }
        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let speed: CGFloat = 24.0

        if abs(dx) > 0.05 || abs(dy) > 0.05 {
            DuckState.shared.isPondLocked = false
            DuckState.shared.stayWherePut = true
            activePerchWindow = nil
            actionDuration = 3.0
            lastActionChange = ProcessInfo.processInfo.systemUptime

            if dx < -0.15 {
                DuckState.shared.facingLeft = true
            } else if dx > 0.15 {
                DuckState.shared.facingLeft = false
            }

            if dy > 0.15 {
                DuckState.shared.currentAction = .climbing
            } else if dx < -0.15 {
                DuckState.shared.currentAction = .waddleLeft
            } else if dx > 0.15 {
                DuckState.shared.currentAction = .waddleRight
            } else if dy < -0.2 {
                DuckState.shared.currentAction = .climbing
            }

            posX = max(screen.minX, min(screen.maxX - frame.width, posX + dx * speed))
            posY = max(screen.minY, min(screen.maxY - frame.height, posY + dy * speed))
            currentFloorY = posY
            velX = 0
            velY = 0
            setFrameOrigin(NSPoint(x: posX, y: posY))
            duckView?.needsDisplay = true
        } else {
            if DuckState.shared.currentAction == .waddleLeft || DuckState.shared.currentAction == .waddleRight || DuckState.shared.currentAction == .jump || DuckState.shared.currentAction == .climbing {
                DuckState.shared.currentAction = .idle
            }
            DuckState.shared.stayWherePut = false
            duckView?.needsDisplay = true
        }
    }

    private func setupSpotify() {
        SpotifyTracker.shared.addObserver { [weak self] track, artist, isPlaying in
            DispatchQueue.main.async {
                DuckState.shared.isPlayingMusic = isPlaying
                DuckState.shared.currentTrack   = track
                DuckState.shared.currentArtist  = artist
                if isPlaying && !DuckState.shared.isPomodoroActive && DuckState.shared.currentAction != .drinking {
                    DuckState.shared.currentAction = .vibeMusic
                }
                self?.duckView.needsDisplay = true
            }
        }
    }

    private func setupPomodoro() {
        PomodoroManager.shared.onStateChange = { [weak self] in
            DispatchQueue.main.async {
                self?.updatePomodoroWindowSize()
                self?.duckView.needsDisplay = true
                MenuBarController.shared.updateMenu()
            }
        }
        PomodoroManager.shared.onTick = { [weak self] in
            DispatchQueue.main.async {
                self?.duckView.needsDisplay = true
            }
        }
    }

    private var preReminderOrigin: NSPoint = .zero

    private func setupReminders() {
        ReminderManager.shared.onStateChange = { [weak self] in
            DispatchQueue.main.async {
                self?.handleReminderStateChange()
                self?.duckView.needsDisplay = true
                MenuBarController.shared.updateMenu()
            }
        }
        ReminderManager.shared.start()
    }

    private func handleReminderStateChange() {
        let isReminding = ReminderManager.shared.isReminding
        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)

        if isReminding {
            // Save position before moving to center
            if preReminderOrigin == .zero {
                preReminderOrigin = frame.origin
            }
            let remW: CGFloat = 240
            let remH: CGFloat = 240
            let remX = screen.midX - remW / 2
            let remY = screen.midY - remH / 2 + 30

            setFrame(NSRect(x: remX, y: remY, width: remW, height: remH), display: true)
            duckView.frame = NSRect(x: 0, y: 0, width: remW, height: remH)
            posX = remX
            posY = remY
        } else {
            // Restore window size and position
            let isPomo = DuckState.shared.isPomodoroActive
            let targetW: CGFloat = isPomo ? 210 : 120
            let targetH: CGFloat = 144

            let restoreX = (preReminderOrigin != .zero) ? preReminderOrigin.x : (screen.midX - targetW / 2)
            let restoreY = (preReminderOrigin != .zero) ? preReminderOrigin.y : (screen.minY + 14)

            setFrame(NSRect(x: restoreX, y: restoreY, width: targetW, height: targetH), display: true)
            duckView.frame = NSRect(x: 0, y: 0, width: targetW, height: targetH)
            posX = restoreX
            posY = restoreY
            preReminderOrigin = .zero
        }
    }

    public func updatePomodoroWindowSize() {
        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let isPomo = DuckState.shared.isPomodoroActive
        let targetW: CGFloat = isPomo ? 210 : 120
        let targetH: CGFloat = 144

        var curOrigin = frame.origin
        if curOrigin.x + targetW > screen.maxX {
            curOrigin.x = max(screen.minX, screen.maxX - targetW)
            posX = curOrigin.x
        }

        setFrame(NSRect(x: curOrigin.x, y: curOrigin.y, width: targetW, height: targetH), display: true)
        duckView.frame = NSRect(x: 0, y: 0, width: targetW, height: targetH)
        duckView.needsDisplay = true
    }

    private func startLoop() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { [weak self] _ in
            self?.tickPhysics()
        }
    }

    private func tickPhysics() {
        tick += 1
        let now = ProcessInfo.processInfo.systemUptime

        // Keyboard typing check (hardware poll via CGEventSource)
        TypingTracker.shared.pollKeyStates()

        if heartProgress > 0 {
            heartProgress += 0.05
            if heartProgress >= 1.0 { heartProgress = 0 }
        }

        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let dock   = screen.minY + 10
        let mouse  = NSEvent.mouseLocation

        // ── Eye tracking ──
        let duckCX = posX + (DuckState.shared.isPomodoroActive ? 56 : frame.width / 2)
        let duckCY = posY + 50
        let dxM = mouse.x - duckCX
        let dyM = mouse.y - duckCY
        DuckState.shared.eyeOffsetX = (dxM < -40) ? -1 : ((dxM > 40) ? 1 : 0)
        DuckState.shared.eyeOffsetY = (dyM >  50) ? -1 : ((dyM < -50) ? 1 : 0)

        // Duck turns head to watch cursor when idle/swimming
        if !isDragging && !DuckState.shared.isPomodoroActive && DuckState.shared.currentAction != .drinking {
            switch DuckState.shared.currentAction {
            case .idle, .swimming:
                if dxM < -80 { DuckState.shared.facingLeft = true }
                else if dxM > 80 { DuckState.shared.facingLeft = false }
            default: break
            }
        }

        if isDragging {
            setFrameOrigin(NSPoint(x: posX, y: posY))
            duckView.needsDisplay = true
            return
        }

        let pond    = DuckState.shared.pondRect
        let inPondX = !pond.isEmpty && duckCX >= pond.minX + 25 && duckCX <= pond.maxX - 25
        let inPondY = !pond.isEmpty && posY >= pond.minY - 20 && posY <= pond.maxY + 25
        let inPond  = DuckState.shared.isPondLocked

        // ── Periodic tracking for active perch window ──
        if let currentPW = activePerchWindow {
            if tick % 15 == 0 {
                let currentWindows = WindowObserver.shared.getWindows()
                if let updated = currentWindows.first(where: { $0.owner == currentPW.owner }) {
                    activePerchWindow = updated
                }
            }
        }

        // ── Floor detection ──
        if DuckState.shared.stayWherePut {
            currentFloorY = posY
        } else if inPond {
            currentFloorY = pond.minY + 6
        } else if inPondX && inPondY {
            currentFloorY = pond.minY + 6
            DuckState.shared.isPondLocked = true
            DuckState.shared.currentAction = .swimming
        } else if let pWin = activePerchWindow {
            let screenH = NSScreen.main?.frame.height ?? 900
            currentFloorY = max(screenH - pWin.top - 8, dock)
        } else if DuckState.shared.perchOnWindows {
            let topY = screen.height - (posY + 10)
            if let p = WindowObserver.shared.findPerchSurface(centerX: duckCX, bottomY: topY) {
                currentFloorY = max(screen.height - p.surfaceY - 8, dock)
            } else { currentFloorY = dock }
        } else { currentFloorY = dock }

        // ── If Pomodoro is active: duck stays calm with timer board, or types if user is typing! ──
        if DuckState.shared.isPomodoroActive {
            velX = 0
            if posY > currentFloorY + 2 {
                velY -= gravity
                posY += velY
                if posY <= currentFloorY {
                    posY = currentFloorY
                    velY = 0
                }
                setFrameOrigin(NSPoint(x: posX, y: posY))
            }
            if DuckState.shared.isTyping {
                DuckState.shared.currentAction = .typing
            } else {
                DuckState.shared.currentAction = .pomodoro
            }
            duckView.needsDisplay = true
            return
        }

        // ── If Duck is in Giant Water Reminder mode: freeze in center of screen ──
        if ReminderManager.shared.isReminding {
            velX = 0
            velY = 0
            duckView.needsDisplay = true
            return
        }

        // ── If Duck is drinking water reminder ──
        if DuckState.shared.currentAction == .drinking {
            velX = 0
            duckView.needsDisplay = true
            return
        }

        // ── If user is typing and duck is not in pond, duck stops to type! ──
        if DuckState.shared.isTyping && !inPond {
            velX = 0
            duckView.needsDisplay = true
        } else {
            // ── AI Decision Tree ──
            if now - lastActionChange > actionDuration && !DuckState.shared.stayWherePut {
                lastActionChange = now

                if inPond {
                    // Swimming across pond
                    let r = Double.random(in: 0...1)
                    if r < 0.40 {
                        DuckState.shared.currentAction = .swimming; velX = 0
                        actionDuration = Double.random(in: 4...8)
                    } else if r < 0.70 {
                        DuckState.shared.currentAction = .swimLeft
                        DuckState.shared.facingLeft    = true; velX = -0.5
                        actionDuration = Double.random(in: 4...8)
                    } else {
                        DuckState.shared.currentAction = .swimRight
                        DuckState.shared.facingLeft    = false; velX = 0.5
                        actionDuration = Double.random(in: 4...8)
                    }

                } else if DuckState.shared.isPlayingMusic {
                    // Music: groove
                    let r = Double.random(in: 0...1)
                    if r < 0.70 {
                        DuckState.shared.currentAction = .vibeMusic; velX = 0
                        actionDuration = Double.random(in: 4...7.5)
                    } else if r < 0.88 {
                        if Bool.random() {
                            DuckState.shared.currentAction = .waddleLeft
                            DuckState.shared.facingLeft    = true; velX = -1.2
                        } else {
                            DuckState.shared.currentAction = .waddleRight
                            DuckState.shared.facingLeft    = false; velX = 1.2
                        }
                        actionDuration = Double.random(in: 3...5)
                    } else {
                        if posY <= currentFloorY + 2 { DuckState.shared.currentAction = .jump; velY = -10 }
                        actionDuration = Double.random(in: 2...3.5)
                    }

                } else {
                    // Idle life
                    let r = Double.random(in: 0...1)
                    if r < 0.35 {
                        DuckState.shared.currentAction = .idle; velX = 0
                        actionDuration = Double.random(in: 4.5...8)
                    } else if r < 0.55 {
                        if Bool.random() {
                            DuckState.shared.currentAction = .waddleLeft
                            DuckState.shared.facingLeft    = true; velX = -1.2
                        } else {
                            DuckState.shared.currentAction = .waddleRight
                            DuckState.shared.facingLeft    = false; velX = 1.2
                        }
                        actionDuration = Double.random(in: 3.5...6.5)
                    } else if r < 0.70 {
                        DuckState.shared.currentAction = .peck; velX = 0
                        actionDuration = Double.random(in: 3...5)
                    } else if r < 0.82 {
                        DuckState.shared.currentAction = .preen; velX = 0
                        actionDuration = Double.random(in: 3...5.5)
                    } else if r < 0.92 {
                        DuckState.shared.currentAction = .stretch; velX = 0
                        actionDuration = Double.random(in: 2.5...4)
                    } else {
                        DuckState.shared.currentAction = .sleep; velX = 0
                        actionDuration = Double.random(in: 6...12)
                    }
                }
            }

            // ── Movement ──
            posX += velX
        }

        if inPond && !pond.isEmpty {
            let lo = pond.minX - frame.width / 2 + 35
            let hi = pond.maxX - frame.width / 2 - 35
            if posX < lo { posX = lo; velX = abs(velX); DuckState.shared.facingLeft = false }
            if posX > hi { posX = hi; velX = -abs(velX); DuckState.shared.facingLeft = true }
        } else if let pWin = activePerchWindow {
            let lo = max(pWin.left + 15, screen.minX + 10)
            let hi = min(pWin.right - frame.width - 15, screen.maxX - frame.width - 10)
            if posX < lo {
                posX = lo; velX = abs(velX); DuckState.shared.facingLeft = false
                DuckState.shared.currentAction = .waddleRight
            } else if posX > hi {
                posX = hi; velX = -abs(velX); DuckState.shared.facingLeft = true
                DuckState.shared.currentAction = .waddleLeft
            }
        } else {
            if posX < screen.minX + 10 {
                posX = screen.minX + 10; velX = abs(velX)
                DuckState.shared.facingLeft = false
                DuckState.shared.currentAction = .waddleRight
            } else if posX > screen.maxX - frame.width - 10 {
                posX = screen.maxX - frame.width - 10; velX = -abs(velX)
                DuckState.shared.facingLeft = true
                DuckState.shared.currentAction = .waddleLeft
            }
        }

        // ── Gravity ──
        if !DuckState.shared.stayWherePut {
            if posY > currentFloorY || velY < 0 {
                velY += gravity; posY -= velY
                if posY <= currentFloorY {
                    posY = currentFloorY; velY = 0
                    if DuckState.shared.currentAction == .jump || DuckState.shared.currentAction == .fall {
                        DuckState.shared.currentAction = inPond ? .swimming
                            : (DuckState.shared.isPlayingMusic ? .vibeMusic : .idle)
                    }
                }
            } else if posY < currentFloorY { posY = currentFloorY; velY = 0 }
        }

        setFrameOrigin(NSPoint(x: posX, y: posY))
        duckView.needsDisplay = true
    }

    // MARK: – Mouse handlers
    public func handleMouseDown(with e: NSEvent) {
        if e.clickCount == 1 {
            heartProgress = 0.01
        }
        isDragging = true; dragStartMouse = NSEvent.mouseLocation; dragStartWin = frame.origin
        DuckState.shared.currentAction = .dragged; velX = 0; velY = 0
    }

    public func handleMouseDragged(with e: NSEvent) {
        guard isDragging else { return }
        let m = NSEvent.mouseLocation
        posX = dragStartWin.x + m.x - dragStartMouse.x
        posY = dragStartWin.y + m.y - dragStartMouse.y
        setFrameOrigin(NSPoint(x: posX, y: posY))
    }

    public func handleMouseUp(with e: NSEvent) {
        guard isDragging else { return }
        isDragging = false

        if DuckState.shared.isPomodoroActive {
            velX = 0; velY = 0
            DuckState.shared.currentAction = .pomodoro
            return
        }

        if posY <= currentFloorY + 25 {
            // Dragged down, release perch window if any
            if posY <= (NSScreen.main?.visibleFrame.minY ?? 0) + 30 {
                activePerchWindow = nil
            }
        }
        let cx   = posX + frame.width / 2
        let pond = DuckState.shared.pondRect
        let inP  = !pond.isEmpty && cx >= pond.minX + 25 && cx <= pond.maxX - 25
                   && posY >= pond.minY - 20 && posY <= pond.maxY + 35

        if inP {
            DuckState.shared.isPondLocked = true
            DuckState.shared.currentAction = .swimming
            velX = 0; velY = 0
            currentFloorY = pond.minY + 6
            posY = currentFloorY
            setFrameOrigin(NSPoint(x: posX, y: posY))
            lastActionChange = ProcessInfo.processInfo.systemUptime
            actionDuration   = 10
        } else {
            DuckState.shared.isPondLocked = false
            if DuckState.shared.stayWherePut { currentFloorY = posY }
            velY = -8; DuckState.shared.currentAction = .jump
        }
    }

    // MARK: – Context menu
    public func showContextMenu(with e: NSEvent) {
        let menu = NSMenu()
        let t = NSMenuItem(title: "Yellow Duck Companion", action: nil, keyEquivalent: "")
        t.isEnabled = false; menu.addItem(t)
        menu.addItem(.separator())

        // 🍅 Pomodoro Section
        if PomodoroManager.shared.isActive {
            let pomoTitle = PomodoroManager.shared.isRunning
                ? "\(PomodoroManager.shared.mode.title): \(PomodoroManager.shared.timeString)"
                : "Paused: \(PomodoroManager.shared.timeString)"
            let pItem = NSMenuItem(title: pomoTitle, action: nil, keyEquivalent: "")
            pItem.isEnabled = false
            menu.addItem(pItem)

            if PomodoroManager.shared.isRunning {
                addAction(menu: menu, title: "Pause Pomodoro", action: #selector(pausePomodoro))
            } else {
                addAction(menu: menu, title: "Resume Pomodoro", action: #selector(resumePomodoro))
            }
            addAction(menu: menu, title: "Stop Pomodoro", action: #selector(stopPomodoro))
            menu.addItem(.separator())
        } else {
            let pomoSub = NSMenu()
            let p25 = NSMenuItem(title: "Focus (25 min)", action: #selector(startPomo25), keyEquivalent: "")
            p25.target = self; pomoSub.addItem(p25)
            let p10 = NSMenuItem(title: "Quick Focus (10 min)", action: #selector(startPomo10), keyEquivalent: "")
            p10.target = self; pomoSub.addItem(p10)
            let b5 = NSMenuItem(title: "Short Break (5 min)", action: #selector(startBreak5), keyEquivalent: "")
            b5.target = self; pomoSub.addItem(b5)
            let b15 = NSMenuItem(title: "Long Break (15 min)", action: #selector(startBreak15), keyEquivalent: "")
            b15.target = self; pomoSub.addItem(b15)

            let pItem = NSMenuItem(title: "Pomodoro Timer", action: nil, keyEquivalent: "")
            pItem.submenu = pomoSub
            menu.addItem(pItem)
            menu.addItem(.separator())
        }

        // 🎯 Focus Task Section
        if !DuckState.shared.focusTask.isEmpty {
            let taskItem = NSMenuItem(title: "Focus: \(DuckState.shared.focusTask)", action: nil, keyEquivalent: "")
            taskItem.isEnabled = false; menu.addItem(taskItem)
            addAction(menu: menu, title: "Edit Focus Task...", action: #selector(promptForFocusTask))
            addAction(menu: menu, title: "Clear Focus Task",   action: #selector(clearFocusTask))
        } else {
            addAction(menu: menu, title: "Set Focus Task...",  action: #selector(promptForFocusTask))
        }
        menu.addItem(.separator())

        // Hydration Reminder Submenu
        let remindSub = NSMenu()
        let r10 = NSMenuItem(title: "Every 10 min", action: #selector(setReminder10), keyEquivalent: "")
        r10.target = self; r10.state = (ReminderManager.shared.intervalMinutes == 10) ? .on : .off
        remindSub.addItem(r10)

        let r20 = NSMenuItem(title: "Every 20 min", action: #selector(setReminder20), keyEquivalent: "")
        r20.target = self; r20.state = (ReminderManager.shared.intervalMinutes == 20) ? .on : .off
        remindSub.addItem(r20)

        let r30 = NSMenuItem(title: "Every 30 min", action: #selector(setReminder30), keyEquivalent: "")
        r30.target = self; r30.state = (ReminderManager.shared.intervalMinutes == 30) ? .on : .off
        remindSub.addItem(r30)

        let rOff = NSMenuItem(title: "Off", action: #selector(setReminderOff), keyEquivalent: "")
        rOff.target = self; rOff.state = (ReminderManager.shared.intervalMinutes == 0) ? .on : .off
        remindSub.addItem(rOff)

        remindSub.addItem(.separator())
        let soundItem = NSMenuItem(title: "Play Sound on Reminder", action: #selector(toggleReminderSound), keyEquivalent: "")
        soundItem.target = self
        soundItem.state = ReminderManager.shared.soundEnabled ? .on : .off
        remindSub.addItem(soundItem)

        remindSub.addItem(.separator())
        let rTest = NSMenuItem(title: "Remind Me Now (Test)", action: #selector(triggerReminderNow), keyEquivalent: "")
        rTest.target = self
        remindSub.addItem(rTest)

        let remindParent = NSMenuItem(title: "Hydration Reminder", action: nil, keyEquivalent: "")
        remindParent.submenu = remindSub
        menu.addItem(remindParent)

        menu.addItem(.separator())

        // Atmosphere Submenu
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

        // 🎩 Wardrobe Submenu
        let wardrobeSub = NSMenu()
        for hat in DuckHat.allCases {
            let item = NSMenuItem(title: hat.displayName, action: #selector(selectHatAction), keyEquivalent: "")
            item.target = self
            item.representedObject = hat.rawValue
            item.state = (DuckState.shared.currentHat == hat) ? .on : .off
            wardrobeSub.addItem(item)
        }
        let wardrobeParent = NSMenuItem(title: "Wardrobe", action: nil, keyEquivalent: "")
        wardrobeParent.submenu = wardrobeSub
        menu.addItem(wardrobeParent)

        menu.addItem(.separator())

        // 💻 Mac Companion Submenu
        let macSub = NSMenu()
        let batLevel = DuckState.shared.batteryPercent
        let batTitle: String
        if !DuckState.shared.hasBattery {
            batTitle = "Power: AC Connected 🔌"
        } else if DuckState.shared.isCharging {
            batTitle = "Battery: \(batLevel)% (Charging ⚡)"
        } else if batLevel <= 20 {
            batTitle = "Battery: \(batLevel)% (Low 🪫)"
        } else {
            batTitle = "Battery: \(batLevel)%"
        }
        let batItem = NSMenuItem(title: batTitle, action: nil, keyEquivalent: "")
        batItem.isEnabled = false
        macSub.addItem(batItem)

        let cpuStr = String(format: "%.1f", DuckState.shared.cpuUsage)
        let cpuItem = NSMenuItem(title: "CPU Load: \(cpuStr)%", action: nil, keyEquivalent: "")
        cpuItem.isEnabled = false
        macSub.addItem(cpuItem)

        macSub.addItem(.separator())
        let reactItem = NSMenuItem(title: "Enable Battery & CPU Reactions", action: #selector(toggleSystemReactions), keyEquivalent: "")
        reactItem.target = self
        reactItem.state = DuckState.shared.enableSystemReactions ? .on : .off
        macSub.addItem(reactItem)

        let macParent = NSMenuItem(title: "Mac Companion", action: nil, keyEquivalent: "")
        macParent.submenu = macSub
        menu.addItem(macParent)

        menu.addItem(.separator())

        addAction(menu: menu, title: "Perch on Active Window (⌥W)", action: #selector(actionPerchActive))
        addAction(menu: menu, title: "Summon to Mouse Cursor (⌥D)", action: #selector(actionSummonCursor))
        addAction(menu: menu, title: "Hide / Show Duck (⌥H)",       action: #selector(actionToggleVis))
        menu.addItem(.separator())

        addToggle(menu: menu, title: "Auto Perch on Window Edges", action: #selector(togglePerch), state: DuckState.shared.perchOnWindows)
        addToggle(menu: menu, title: "Stay Where I Put It", action: #selector(toggleStay),  state: DuckState.shared.stayWherePut)
        menu.addItem(.separator())
        addAction(menu: menu, title: "Swim in Pond",        action: #selector(sendToPond))
        addAction(menu: menu, title: "Take Out of Pond",    action: #selector(leavePool))
        addAction(menu: menu, title: "Reset Position",      action: #selector(reset))
        menu.addItem(.separator())
        addAction(menu: menu, title: "Quit LockIn",        action: #selector(quit), key: "q")
        NSMenu.popUpContextMenu(menu, with: e, for: duckView)
    }

    private func addToggle(menu: NSMenu, title: String, action: Selector, state: Bool) {
        let i = NSMenuItem(title: title, action: action, keyEquivalent: "")
        i.target = self; i.state = state ? .on : .off; menu.addItem(i)
    }
    private func addAction(menu: NSMenu, title: String, action: Selector, key: String = "") {
        let i = NSMenuItem(title: title, action: action, keyEquivalent: key)
        i.target = self; menu.addItem(i)
    }

    // Pomodoro selectors
    @objc private func startPomo25() { PomodoroManager.shared.start(durationMinutes: 25, mode: .focus) }
    @objc private func startPomo10() { PomodoroManager.shared.start(durationMinutes: 10, mode: .focus) }
    @objc private func startBreak5() { PomodoroManager.shared.start(durationMinutes: 5, mode: .shortBreak) }
    @objc private func startBreak15() { PomodoroManager.shared.start(durationMinutes: 15, mode: .longBreak) }
    @objc private func pausePomodoro() { PomodoroManager.shared.pause() }
    @objc private func resumePomodoro() { PomodoroManager.shared.resume() }
    @objc private func stopPomodoro() { PomodoroManager.shared.stop() }

    @objc private func actionPerchActive() { perchOnActiveWindow() }
    @objc private func actionSummonCursor() { summonToCursor() }
    @objc private func actionToggleVis() { toggleVisibility() }

    // Focus Task selectors
    @objc public func promptForFocusTask() {
        let alert = NSAlert()
        alert.messageText = "Set Daily Focus Task"
        alert.informativeText = "Enter what you want to focus on today (shows on the chalkboard & menu bar):"
        alert.alertStyle = .informational

        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 240, height: 24))
        input.stringValue = DuckState.shared.focusTask
        input.placeholderString = "e.g. Selesaikan Fitur UI"
        alert.accessoryView = input

        alert.addButton(withTitle: "Save Task")
        alert.addButton(withTitle: "Cancel")
        alert.window.initialFirstResponder = input

        NSApp.activate(ignoringOtherApps: true)
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            let text = input.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            DuckState.shared.setFocusTask(text)
            duckView.needsDisplay = true
            MenuBarController.shared.updateMenu()
        }
    }

    @objc private func clearFocusTask() {
        DuckState.shared.setFocusTask("")
        duckView.needsDisplay = true
        MenuBarController.shared.updateMenu()
    }

    // Hydration Reminder selectors
    @objc private func setReminder10() { ReminderManager.shared.intervalMinutes = 10; MenuBarController.shared.updateMenu() }
    @objc private func setReminder20() { ReminderManager.shared.intervalMinutes = 20; MenuBarController.shared.updateMenu() }
    @objc private func setReminder30() { ReminderManager.shared.intervalMinutes = 30; MenuBarController.shared.updateMenu() }
    @objc private func setReminderOff() { ReminderManager.shared.intervalMinutes = 0; MenuBarController.shared.updateMenu() }
    @objc private func triggerReminderNow() { ReminderManager.shared.triggerReminder() }

    @objc private func toggleReminderSound() {
        ReminderManager.shared.soundEnabled.toggle()
        MenuBarController.shared.updateMenu()
    }

    @objc private func togglePerch() { DuckState.shared.perchOnWindows.toggle() }
    @objc private func toggleSystemReactions() {
        DuckState.shared.enableSystemReactions.toggle()
        SystemStatsTracker.shared.poll()
        duckView?.needsDisplay = true
        MenuBarController.shared.updateMenu()
    }

    @objc private func toggleStay() {
        DuckState.shared.stayWherePut.toggle()
        if DuckState.shared.stayWherePut { currentFloorY = posY }
    }
    @objc public func sendToPond() {
        let pond = DuckState.shared.pondRect; guard !pond.isEmpty else { return }
        posX = pond.midX - frame.width / 2
        posY = pond.minY + 6
        currentFloorY = pond.minY + 6
        velX = 0; velY = 0
        DuckState.shared.isPondLocked  = true
        DuckState.shared.currentAction = .swimming
        duckView.needsDisplay = true
    }
    @objc private func leavePool() {
        DuckState.shared.isPondLocked = false
        let scr = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let pond = DuckState.shared.pondRect
        posX = max(scr.minX + 50, pond.minX - 120)
        posY = max(scr.minY + 20, pond.minY + 20); velY = -8
        DuckState.shared.currentAction = .jump
        duckView.needsDisplay = true
    }
    @objc private func reset() {
        DuckState.shared.isPondLocked = false
        let scr = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        posX = scr.midX - frame.width / 2; posY = scr.minY + 20
        currentFloorY = scr.minY + 10
        DuckState.shared.currentAction = .idle
    }
    // Atmosphere selectors
    @objc private func toggleAutoDayNight() {
        DuckState.shared.isAutoDayNight.toggle()
        duckView.needsDisplay = true
        PondWindow.shared?.contentView?.needsDisplay = true
    }
    @objc private func toggleNightMode() {
        DuckState.shared.isAutoDayNight = false
        DuckState.shared.isNightMode.toggle()
        duckView.needsDisplay = true
        PondWindow.shared?.contentView?.needsDisplay = true
    }
    @objc private func selectHatAction(_ sender: NSMenuItem) {
        if let raw = sender.representedObject as? String, let hat = DuckHat(rawValue: raw) {
            DuckState.shared.currentHat = hat
            DuckSpriteRenderer.shared.clearCache()
            duckView.needsDisplay = true
            MenuBarController.shared.updateMenu()
        }
    }

    @objc private func toggleRainMode() {
        DuckState.shared.isRainMode.toggle()
        duckView.needsDisplay = true
        PondWindow.shared?.contentView?.needsDisplay = true
    }
    @objc private func quit() { NSApplication.shared.terminate(nil) }
}

import AppKit

public class MenuBarController {
    public static let shared = MenuBarController()
    
    private var statusItem: NSStatusItem?
    private weak var duckWindow: DuckWindow?

    private init() {}

    // Generates a native, crisp macOS duck webbed foot (kaki bebek) template icon
    private func createDuckFootIcon() -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let img = NSImage(size: size, flipped: false) { rect in
            NSColor.black.setFill()
            
            let path = NSBezierPath()
            let s: CGFloat = 1.0
            
            // Heel bottom center (9, 2)
            path.move(to: NSPoint(x: 9.0 * s, y: 2.2 * s))
            
            // Left contour to left toe tip
            path.curve(to: NSPoint(x: 2.5 * s, y: 12.0 * s),
                       controlPoint1: NSPoint(x: 7.5 * s, y: 5.0 * s),
                       controlPoint2: NSPoint(x: 4.5 * s, y: 8.0 * s))
            
            // Scalloped webbing from left toe to middle toe
            path.curve(to: NSPoint(x: 9.0 * s, y: 15.5 * s),
                       controlPoint1: NSPoint(x: 5.5 * s, y: 9.5 * s),
                       controlPoint2: NSPoint(x: 7.5 * s, y: 11.0 * s))
            
            // Scalloped webbing from middle toe to right toe
            path.curve(to: NSPoint(x: 15.5 * s, y: 12.0 * s),
                       controlPoint1: NSPoint(x: 10.5 * s, y: 11.0 * s),
                       controlPoint2: NSPoint(x: 12.5 * s, y: 9.5 * s))
            
            // Right contour down to heel
            path.curve(to: NSPoint(x: 9.0 * s, y: 2.2 * s),
                       controlPoint1: NSPoint(x: 13.5 * s, y: 8.0 * s),
                       controlPoint2: NSPoint(x: 10.5 * s, y: 5.0 * s))
            path.close()
            path.fill()
            
            // Rounded toe pads and heel
            NSBezierPath(ovalIn: NSRect(x: 1.5 * s, y: 11.0 * s, width: 2.5 * s, height: 2.5 * s)).fill()
            NSBezierPath(ovalIn: NSRect(x: 7.75 * s, y: 14.5 * s, width: 2.5 * s, height: 2.5 * s)).fill()
            NSBezierPath(ovalIn: NSRect(x: 13.75 * s, y: 11.0 * s, width: 2.5 * s, height: 2.5 * s)).fill()
            NSBezierPath(ovalIn: NSRect(x: 7.5 * s, y: 1.0 * s, width: 3.0 * s, height: 2.8 * s)).fill()
            
            return true
        }
        img.isTemplate = true // Adapts to macOS Light and Dark menu bar automatically
        return img
    }

    public func setup(duckWindow: DuckWindow) {
        self.duckWindow = duckWindow
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = createDuckFootIcon()
            button.title = ""
            button.imagePosition = .imageOnly
        }
        
        updateMenu()
    }

    public func showSettingsMenu(at point: NSPoint, in view: NSView) {
        updateMenu()
        let menuToPop = statusItem?.menu ?? NSMenu()
        menuToPop.popUp(positioning: nil, at: point, in: view)
    }

    public func updateMenu() {
        let menu = NSMenu()

        let titleItem = NSMenuItem(title: "Yellow Duck Desktop Companion", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)

        let islandItem = NSMenuItem(title: "Toggle Mac Dynamic Island", action: #selector(toggleIsland), keyEquivalent: "i")
        islandItem.keyEquivalentModifierMask = [.option, .command]
        islandItem.target = self
        menu.addItem(islandItem)

        let mirrorItem = NSMenuItem(title: "Quick Mirror", action: #selector(toggleMirrorAction), keyEquivalent: "m")
        mirrorItem.keyEquivalentModifierMask = [.option, .command]
        mirrorItem.target = self
        menu.addItem(mirrorItem)

        menu.addItem(NSMenuItem.separator())

        // 🎯 Focus Task Section
        if !DuckState.shared.focusTask.isEmpty {
            let taskItem = NSMenuItem(title: "Focus: \(DuckState.shared.focusTask)", action: nil, keyEquivalent: "")
            taskItem.isEnabled = false
            menu.addItem(taskItem)

            let editTask = NSMenuItem(title: "Edit Focus Task...", action: #selector(editTaskAction), keyEquivalent: "")
            editTask.target = self
            menu.addItem(editTask)

            let clearTask = NSMenuItem(title: "Clear Focus Task", action: #selector(clearTaskAction), keyEquivalent: "")
            clearTask.target = self
            menu.addItem(clearTask)

            menu.addItem(NSMenuItem.separator())
        } else {
            let setTask = NSMenuItem(title: "Set Focus Task...", action: #selector(editTaskAction), keyEquivalent: "")
            setTask.target = self
            menu.addItem(setTask)

            menu.addItem(NSMenuItem.separator())
        }

        // 🍅 Pomodoro Section
        if PomodoroManager.shared.isActive {
            let statusStr = PomodoroManager.shared.isRunning
                ? "\(PomodoroManager.shared.mode.title): \(PomodoroManager.shared.timeString)"
                : "Paused: \(PomodoroManager.shared.timeString)"
            let pomoItem = NSMenuItem(title: statusStr, action: nil, keyEquivalent: "")
            pomoItem.isEnabled = false
            menu.addItem(pomoItem)

            if PomodoroManager.shared.isRunning {
                let pauseItem = NSMenuItem(title: "Pause Pomodoro", action: #selector(pausePomo), keyEquivalent: "")
                pauseItem.target = self
                menu.addItem(pauseItem)
            } else {
                let resumeItem = NSMenuItem(title: "Resume Pomodoro", action: #selector(resumePomo), keyEquivalent: "")
                resumeItem.target = self
                menu.addItem(resumeItem)
            }

            let stopItem = NSMenuItem(title: "Stop Pomodoro", action: #selector(stopPomo), keyEquivalent: "")
            stopItem.target = self
            menu.addItem(stopItem)

            menu.addItem(NSMenuItem.separator())
        } else {
            let pomoSub = NSMenu()
            let p25 = NSMenuItem(title: "Focus (25 min)", action: #selector(startFocus25), keyEquivalent: "")
            p25.target = self; pomoSub.addItem(p25)
            let p10 = NSMenuItem(title: "Quick Focus (10 min)", action: #selector(startFocus10), keyEquivalent: "")
            p10.target = self; pomoSub.addItem(p10)
            let b5 = NSMenuItem(title: "Short Break (5 min)", action: #selector(startBreak5), keyEquivalent: "")
            b5.target = self; pomoSub.addItem(b5)
            let b15 = NSMenuItem(title: "Long Break (15 min)", action: #selector(startBreak15), keyEquivalent: "")
            b15.target = self; pomoSub.addItem(b15)

            let pomoParent = NSMenuItem(title: "Pomodoro Timer (⌥P)", action: nil, keyEquivalent: "")
            pomoParent.submenu = pomoSub
            menu.addItem(pomoParent)

            menu.addItem(NSMenuItem.separator())
        }

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

        remindSub.addItem(NSMenuItem.separator())
        let soundItem = NSMenuItem(title: "Play Sound on Reminder", action: #selector(toggleReminderSound), keyEquivalent: "")
        soundItem.target = self
        soundItem.state = ReminderManager.shared.soundEnabled ? .on : .off
        remindSub.addItem(soundItem)

        remindSub.addItem(NSMenuItem.separator())
        let rTest = NSMenuItem(title: "Remind Me Now (Test)", action: #selector(triggerReminderNow), keyEquivalent: "")
        rTest.target = self
        remindSub.addItem(rTest)

        let remindParent = NSMenuItem(title: "Hydration Reminder", action: nil, keyEquivalent: "")
        remindParent.submenu = remindSub
        menu.addItem(remindParent)

        menu.addItem(NSMenuItem.separator())

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

        atmosSub.addItem(NSMenuItem.separator())
        let rainItem = NSMenuItem(title: "Cozy Rain Mode", action: #selector(toggleRainMode), keyEquivalent: "")
        rainItem.target = self
        rainItem.state = DuckState.shared.isRainMode ? .on : .off
        atmosSub.addItem(rainItem)

        let atmosParent = NSMenuItem(title: "Cozy Atmosphere", action: nil, keyEquivalent: "")
        atmosParent.submenu = atmosSub
        menu.addItem(atmosParent)

        menu.addItem(NSMenuItem.separator())

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

        menu.addItem(NSMenuItem.separator())

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

        macSub.addItem(NSMenuItem.separator())
        let reactItem = NSMenuItem(title: "Enable Battery & CPU Reactions", action: #selector(toggleSystemReactions), keyEquivalent: "")
        reactItem.target = self
        reactItem.state = DuckState.shared.enableSystemReactions ? .on : .off
        macSub.addItem(reactItem)

        let macParent = NSMenuItem(title: "Mac Companion", action: nil, keyEquivalent: "")
        macParent.submenu = macSub
        menu.addItem(macParent)

        menu.addItem(NSMenuItem.separator())

        let itemPerchActive = NSMenuItem(title: "Perch on Active Window (⌥W)", action: #selector(actionPerchActive), keyEquivalent: "")
        itemPerchActive.target = self
        menu.addItem(itemPerchActive)

        let itemSummon = NSMenuItem(title: "Summon to Mouse Cursor (⌥D)", action: #selector(actionSummonCursor), keyEquivalent: "")
        itemSummon.target = self
        menu.addItem(itemSummon)

        let itemToggleVis = NSMenuItem(title: "Hide / Show Duck (⌥H)", action: #selector(actionToggleVis), keyEquivalent: "")
        itemToggleVis.target = self
        menu.addItem(itemToggleVis)

        menu.addItem(NSMenuItem.separator())

        let itemPerch = NSMenuItem(title: "Auto Perch on Window Edges", action: #selector(togglePerch), keyEquivalent: "")
        itemPerch.target = self
        itemPerch.state = DuckState.shared.perchOnWindows ? .on : .off
        menu.addItem(itemPerch)

        let itemStay = NSMenuItem(title: "Stay Where I Put It", action: #selector(toggleStay), keyEquivalent: "")
        itemStay.target = self
        itemStay.state = DuckState.shared.stayWherePut ? .on : .off
        menu.addItem(itemStay)

        menu.addItem(NSMenuItem.separator())

        let itemSwim = NSMenuItem(title: "Take a Swim in the Pond", action: #selector(sendToPond), keyEquivalent: "")
        itemSwim.target = self
        menu.addItem(itemSwim)

        let itemReset = NSMenuItem(title: "Reset Duck Position", action: #selector(resetDuck), keyEquivalent: "")
        itemReset.target = self
        menu.addItem(itemReset)

        let itemResetPond = NSMenuItem(title: "Reset Pond to Bottom Right", action: #selector(resetPond), keyEquivalent: "")
        itemResetPond.target = self
        menu.addItem(itemResetPond)

        menu.addItem(NSMenuItem.separator())

        let itemQuit = NSMenuItem(title: "Quit LockIn", action: #selector(quitApp), keyEquivalent: "q")
        itemQuit.target = self
        menu.addItem(itemQuit)

        statusItem?.menu = menu
    }

    // Focus Task selectors
    @objc private func editTaskAction() {
        duckWindow?.promptForFocusTask()
    }

    @objc private func clearTaskAction() {
        DuckState.shared.setFocusTask("")
        duckWindow?.contentView?.needsDisplay = true
        updateMenu()
    }

    // Pomodoro selectors
    @objc private func startFocus25() { PomodoroManager.shared.start(durationMinutes: 25, mode: .focus) }
    @objc private func startFocus10() { PomodoroManager.shared.start(durationMinutes: 10, mode: .focus) }
    @objc private func startBreak5()  { PomodoroManager.shared.start(durationMinutes: 5, mode: .shortBreak) }
    @objc private func startBreak15() { PomodoroManager.shared.start(durationMinutes: 15, mode: .longBreak) }
    @objc private func pausePomo()     { PomodoroManager.shared.pause() }
    @objc private func resumePomo()    { PomodoroManager.shared.resume() }
    @objc private func stopPomo()      { PomodoroManager.shared.stop() }

    // Hydration Reminder selectors
    @objc private func setReminder10() { ReminderManager.shared.intervalMinutes = 10; updateMenu() }
    @objc private func setReminder20() { ReminderManager.shared.intervalMinutes = 20; updateMenu() }
    @objc private func setReminder30() { ReminderManager.shared.intervalMinutes = 30; updateMenu() }
    @objc private func setReminderOff() { ReminderManager.shared.intervalMinutes = 0; updateMenu() }
    @objc private func triggerReminderNow() { ReminderManager.shared.triggerReminder() }

    @objc private func toggleReminderSound() {
        ReminderManager.shared.soundEnabled.toggle()
        updateMenu()
    }

    @objc private func togglePerch() {
        DuckState.shared.perchOnWindows.toggle()
        updateMenu()
    }

    @objc private func toggleSystemReactions() {
        DuckState.shared.enableSystemReactions.toggle()
        SystemStatsTracker.shared.poll()
        updateMenu()
        duckWindow?.contentView?.needsDisplay = true
    }

    @objc private func actionPerchActive() { duckWindow?.perchOnActiveWindow() }
    @objc private func actionSummonCursor() { duckWindow?.summonToCursor() }
    @objc private func actionToggleVis() { duckWindow?.toggleVisibility() }

    @objc private func toggleStay() {
        DuckState.shared.stayWherePut.toggle()
        updateMenu()
    }

    // Atmosphere selectors
    @objc private func toggleAutoDayNight() {
        DuckState.shared.isAutoDayNight.toggle()
        updateMenu()
        duckWindow?.contentView?.needsDisplay = true
        PondWindow.shared?.contentView?.needsDisplay = true
    }

    @objc private func toggleNightMode() {
        DuckState.shared.isAutoDayNight = false
        DuckState.shared.isNightMode.toggle()
        updateMenu()
        duckWindow?.contentView?.needsDisplay = true
        PondWindow.shared?.contentView?.needsDisplay = true
    }

    @objc private func selectHatAction(_ sender: NSMenuItem) {
        if let raw = sender.representedObject as? String, let hat = DuckHat(rawValue: raw) {
            DuckState.shared.currentHat = hat
            DuckSpriteRenderer.shared.clearCache()
            duckWindow?.contentView?.needsDisplay = true
            updateMenu()
        }
    }

    @objc private func toggleRainMode() {
        DuckState.shared.isRainMode.toggle()
        updateMenu()
        duckWindow?.contentView?.needsDisplay = true
        PondWindow.shared?.contentView?.needsDisplay = true
    }

    @objc private func sendToPond() {
        let pond = DuckState.shared.pondRect
        if !pond.isEmpty {
            duckWindow?.setFrameOrigin(NSPoint(x: pond.midX - 60, y: pond.minY + 6))
            DuckState.shared.isPondLocked = true
            DuckState.shared.currentAction = .swimming
        }
    }

    @objc private func resetDuck() {
        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        duckWindow?.setFrameOrigin(NSPoint(x: screen.midX - 60, y: screen.minY + 20))
        DuckState.shared.isPondLocked = false
        DuckState.shared.currentAction = .idle
    }

    @objc private func resetPond() {
        PondWindow.shared?.resetPosition()
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    @objc private func toggleIsland() {
        DynamicIslandWindow.shared?.toggleExpansion()
    }

    @objc private func toggleMirrorAction() {
        DynamicIslandWindow.shared?.toggleMirror()
    }
}

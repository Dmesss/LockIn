import AppKit
import Foundation

public class ReminderManager {
    public static let shared = ReminderManager()

    // 0 = Off, 10 = 10m, 20 = 20m, 30 = 30m
    public var intervalMinutes: Int = 30 {
        didSet {
            UserDefaults.standard.set(intervalMinutes, forKey: "DuckPet_ReminderInterval")
            restartTimer()
        }
    }

    public var soundEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(soundEnabled, forKey: "DuckPet_ReminderSoundEnabled")
        }
    }

    public var isReminding: Bool = false
    public var reminderMessage: String = "Drink Water!"
    
    private var reminderTimer: Timer?
    private var autoDismissTimer: Timer?
    public var onStateChange: (() -> Void)?

    private init() {
        let saved = UserDefaults.standard.object(forKey: "DuckPet_ReminderInterval")
        if let val = saved as? Int {
            if val == 45 {
                intervalMinutes = 30
                UserDefaults.standard.set(30, forKey: "DuckPet_ReminderInterval")
            } else {
                intervalMinutes = val
            }
        } else {
            intervalMinutes = 30
            UserDefaults.standard.set(30, forKey: "DuckPet_ReminderInterval")
        }

        if let savedSound = UserDefaults.standard.object(forKey: "DuckPet_ReminderSoundEnabled") as? Bool {
            soundEnabled = savedSound
        }
    }

    public func start() {
        restartTimer()
    }

    public func restartTimer() {
        reminderTimer?.invalidate()
        reminderTimer = nil

        guard intervalMinutes > 0 else { return }

        let interval = TimeInterval(intervalMinutes * 60)
        reminderTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.triggerReminder()
        }
    }

    public func triggerReminder() {
        isReminding = true
        reminderMessage = "Drink Water!"

        // Play audible water bottle pop notification sound
        if soundEnabled {
            playReminderSound()
        }

        // Set duck action to drinking
        DuckState.shared.currentAction = .drinking

        onStateChange?()

        // Auto dismiss after 10 seconds
        autoDismissTimer?.invalidate()
        autoDismissTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            self?.dismissReminder()
        }
    }

    public func playReminderSound() {
        if let sound = NSSound(named: "Bottle") ?? NSSound(named: "Glass") {
            sound.volume = 1.0
            sound.play()
        }
    }

    public func dismissReminder() {
        guard isReminding else { return }
        isReminding = false
        autoDismissTimer?.invalidate()
        autoDismissTimer = nil

        if DuckState.shared.currentAction == .drinking {
            DuckState.shared.currentAction = DuckState.shared.isPomodoroActive ? .pomodoro : (DuckState.shared.isPondLocked ? .swimming : .idle)
        }

        onStateChange?()
    }
}

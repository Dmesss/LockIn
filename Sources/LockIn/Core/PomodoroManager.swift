import AppKit
import Foundation

public enum PomodoroMode: String {
    case focus = "Focus"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"

    public var title: String {
        switch self {
        case .focus: return "FOCUS"
        case .shortBreak: return "BREAK"
        case .longBreak: return "LONG BREAK"
        }
    }

    public var badgeColor: NSColor {
        switch self {
        case .focus: return NSColor(red: 0.95, green: 0.28, blue: 0.22, alpha: 1.0) // Tomato red
        case .shortBreak: return NSColor(red: 0.22, green: 0.78, blue: 0.65, alpha: 1.0) // Mint green
        case .longBreak: return NSColor(red: 0.30, green: 0.65, blue: 1.0, alpha: 1.0) // Sky blue
        }
    }
}

public enum PomodoroStatus {
    case idle
    case running
    case paused
    case completed
}

public class PomodoroManager {
    public static let shared = PomodoroManager()

    public var mode: PomodoroMode = .focus
    public var status: PomodoroStatus = .idle
    public var totalSeconds: Int = 25 * 60
    public var remainingSeconds: Int = 25 * 60

    private var timer: Timer?
    public var onTick: (() -> Void)?
    public var onStateChange: (() -> Void)?

    private init() {}

    public var isActive: Bool {
        return status == .running || status == .paused
    }

    public var isRunning: Bool {
        return status == .running
    }

    public var timeString: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    public var progress: CGFloat {
        guard totalSeconds > 0 else { return 0 }
        let elapsed = totalSeconds - remainingSeconds
        return CGFloat(elapsed) / CGFloat(totalSeconds)
    }

    public func toggle() {
        if !isActive {
            start(durationMinutes: 25, mode: .focus)
        } else if isRunning {
            pause()
        } else {
            resume()
        }
    }

    public func start(durationMinutes: Int = 25, mode: PomodoroMode = .focus) {
        self.mode = mode
        self.totalSeconds = max(1, durationMinutes * 60)
        self.remainingSeconds = totalSeconds
        self.status = .running

        DuckState.shared.isPomodoroActive = true
        DuckState.shared.currentAction = .pomodoro

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }

        onStateChange?()
    }

    public func pause() {
        guard status == .running else { return }
        status = .paused
        timer?.invalidate()
        timer = nil
        onStateChange?()
    }

    public func resume() {
        guard status == .paused else { return }
        status = .running
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        onStateChange?()
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
        status = .idle
        remainingSeconds = totalSeconds

        DuckState.shared.isPomodoroActive = false
        if DuckState.shared.currentAction == .pomodoro {
            DuckState.shared.currentAction = .idle
        }

        onStateChange?()
    }

    private func tick() {
        guard status == .running else { return }

        if remainingSeconds > 0 {
            remainingSeconds -= 1
            if remainingSeconds % 60 == 0 && mode == .focus {
                DuckState.shared.addFocusCoins(2)
                DuckState.shared.totalFocusMinutes += 1
            }
            onTick?()
            SyncServer.shared.broadcastState()
        } else {
            complete()
        }
    }

    private func complete() {
        status = .completed
        timer?.invalidate()
        timer = nil

        // Gentle notification chime
        NSSound(named: "Glass")?.play()

        // Gamification Reward: +100 Focus Coins for completed Focus session
        if mode == .focus {
            DuckState.shared.completedSessionsCount += 1
            DuckState.shared.addFocusCoins(100)
        }

        // Celebrate
        DuckState.shared.currentAction = .quack
        SyncServer.shared.broadcastState()

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
            guard let self = self else { return }
            if self.status == .completed {
                // If it was focus, prompt for break or stop
                self.stop()
            }
        }

        onStateChange?()
    }
}

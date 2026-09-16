import AppKit
import ApplicationServices

public class TypingTracker {
    public static let shared = TypingTracker()

    public var lastTypingTime: TimeInterval = 0
    private var lastRecordedKeystroke: TimeInterval = 0
    private var recentKeyTimes: [TimeInterval] = []

    private var prevKeyDownComb: Double = 999.0
    private var prevKeyDownHid:  Double = 999.0

    private var globalMonitor: Any?
    private var localMonitor: Any?

    private init() {}

    public func start() {
        // Global monitor for typing when accessible
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] _ in
            self?.recordKeyPress()
        }

        // Local monitor for typing when DuckPet has focus
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
            self?.recordKeyPress()
            return event
        }
    }

    public func stop() {
        if let gm = globalMonitor {
            NSEvent.removeMonitor(gm)
            globalMonitor = nil
        }
        if let lm = localMonitor {
            NSEvent.removeMonitor(lm)
            localMonitor = nil
        }
    }

    public func recordKeyPress() {
        let now = ProcessInfo.processInfo.systemUptime
        lastTypingTime = now
        DuckState.shared.isTyping = true
        registerKeystroke(now: now)
    }

    private func registerKeystroke(now: TimeInterval) {
        // Debounce: ensure at least 60ms between distinct keystroke counts
        if (now - lastRecordedKeystroke) >= 0.060 {
            lastRecordedKeystroke = now
            recentKeyTimes.append(now)
        }
    }

    // Called on every frame from the DuckWindow timer loop (25fps)
    public func pollKeyStates() {
        let now = ProcessInfo.processInfo.systemUptime

        // High-precision global system query: checks seconds since last keyDown/keyUp anywhere in macOS
        let sinceKeyDownComb = CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: .keyDown)
        let sinceKeyDownHid  = CGEventSource.secondsSinceLastEventType(.hidSystemState, eventType: .keyDown)
        let sinceKeyUpComb   = CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: .keyUp)
        let sinceKeyUpHid    = CGEventSource.secondsSinceLastEventType(.hidSystemState, eventType: .keyUp)
        let sinceFlagsComb   = CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: .flagsChanged)
        let sinceFlagsHid    = CGEventSource.secondsSinceLastEventType(.hidSystemState, eventType: .flagsChanged)

        let recent = min(sinceKeyDownComb, sinceKeyDownHid, sinceKeyUpComb, sinceKeyUpHid, sinceFlagsComb, sinceFlagsHid)

        if recent < 0.85 {
            lastTypingTime = now
            DuckState.shared.isTyping = true

            // A new real keystroke occurred if keyDown counter dropped
            let isNewStroke = (sinceKeyDownComb < prevKeyDownComb - 0.02) ||
                              (sinceKeyDownHid  < prevKeyDownHid  - 0.02)
            if isNewStroke {
                registerKeystroke(now: now)
            }
        } else {
            if (now - lastTypingTime) > 0.85 {
                DuckState.shared.isTyping = false
                DuckState.shared.isOverheating = false
                recentKeyTimes.removeAll()
            }
        }

        prevKeyDownComb = sinceKeyDownComb
        prevKeyDownHid  = sinceKeyDownHid

        // Calculate keystroke rate in the last 1.6 seconds
        recentKeyTimes.removeAll { now - $0 > 1.6 }
        let count = recentKeyTimes.count

        // Higher overheat threshold: requires rapid burst of >= 12 real keystrokes in 1.6s (~7.5+ keys/sec)
        if count >= 12 && DuckState.shared.isTyping {
            DuckState.shared.isOverheating = true
        } else if count <= 6 || !DuckState.shared.isTyping {
            DuckState.shared.isOverheating = false
        }
    }

    public var currentWPM: Int {
        guard DuckState.shared.isTyping else { return 0 }
        let now = ProcessInfo.processInfo.systemUptime
        let valid = recentKeyTimes.filter { time in (now - time) <= 3.0 }
        let strokesPerSec = Double(valid.count) / 3.0
        let wpm = Int((strokesPerSec / 5.0) * 60.0)
        return max(15, min(180, wpm))
    }
}

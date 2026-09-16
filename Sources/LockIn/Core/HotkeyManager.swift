import AppKit
import Carbon

public class HotkeyManager {
    public static let shared = HotkeyManager()

    private var hotKeyRefs: [EventHotKeyRef?] = []
    private var eventHandler: EventHandlerRef?
    private var isStarted = false

    private init() {}

    public func start() {
        guard !isStarted else { return }
        isStarted = true

        installCarbonHandler()

        // 1. Option + D -> Summon Duck to Cursor
        register(keyCode: UInt32(kVK_ANSI_D), modifiers: UInt32(optionKey), id: 1)

        // 2. Option + H -> Toggle Duck Visibility (Hide/Show)
        register(keyCode: UInt32(kVK_ANSI_H), modifiers: UInt32(optionKey), id: 2)

        // 3. Option + W -> Perch on Active Window Title Bar
        register(keyCode: UInt32(kVK_ANSI_W), modifiers: UInt32(optionKey), id: 3)

        // 4. Option + P -> Toggle Pomodoro Focus Timer
        register(keyCode: UInt32(kVK_ANSI_P), modifiers: UInt32(optionKey), id: 4)
    }

    private func register(keyCode: UInt32, modifiers: UInt32, id: UInt32) {
        var hotKeyRef: EventHotKeyRef?
        let hotKeyID = EventHotKeyID(signature: OSType(0x4455434B), id: id) // 'DUCK'
        let err = RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetEventDispatcherTarget(), 0, &hotKeyRef)
        if err == noErr {
            hotKeyRefs.append(hotKeyRef)
        }
    }

    private func installCarbonHandler() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        let handler: EventHandlerUPP = { (_, eventRef, _) -> OSStatus in
            var hotKeyID = EventHotKeyID()
            let status = GetEventParameter(
                eventRef,
                EventParamName(kEventParamDirectObject),
                EventParamType(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &hotKeyID
            )
            if status == noErr {
                DispatchQueue.main.async {
                    switch hotKeyID.id {
                    case 1:
                        DuckWindow.shared?.summonToCursor()
                    case 2:
                        DuckWindow.shared?.toggleVisibility()
                    case 3:
                        DuckWindow.shared?.perchOnActiveWindow()
                    case 4:
                        PomodoroManager.shared.toggle()
                    default:
                        break
                    }
                }
            }
            return noErr
        }

        InstallEventHandler(GetEventDispatcherTarget(), handler, 1, &eventType, nil, &eventHandler)
    }

    public func stop() {
        for ref in hotKeyRefs {
            if let r = ref {
                UnregisterEventHotKey(r)
            }
        }
        hotKeyRefs.removeAll()
        if let h = eventHandler {
            RemoveEventHandler(h)
            eventHandler = nil
        }
        isStarted = false
    }
}

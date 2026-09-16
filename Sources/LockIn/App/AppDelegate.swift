import AppKit

public class AppDelegate: NSObject, NSApplicationDelegate {
    private var duckWindow: DuckWindow?
    private var pondWindow: PondWindow?
    private var dynamicIslandWindow: DynamicIslandWindow?

    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Run purely as an accessory agent (Zero Dock Icon, Zero Cmd+Tab)
        NSApp.setActivationPolicy(.accessory)

        // 1. Create and show the cozy bottom-right pond
        let pond = PondWindow()
        pond.makeKeyAndOrderFront(nil)
        self.pondWindow = pond

        // 2. Create and show the yellow duck companion
        let window = DuckWindow()
        window.makeKeyAndOrderFront(nil)
        self.duckWindow = window

        // 2.5. Create and show Mac Dynamic Island (Notch Island)
        let island = DynamicIslandWindow()
        self.dynamicIslandWindow = island

        // 3. Setup menu bar controls
        MenuBarController.shared.setup(duckWindow: window)

        // 4. Start Keyboard Typing Tracker
        SpotifyTracker.shared.startPolling()
        TypingTracker.shared.start()

        // 5. Start Mac Companion System Tracker (Battery & CPU)
        SystemStatsTracker.shared.start()

        // 6. Start Global Keyboard Hotkeys (Option+D, Option+H, Option+W, Option+P)
        HotkeyManager.shared.start()

        // 7. Start Local Wi-Fi Sync Server for iPhone / Mobile App (Port 8765, Bonjour: _duckpet._tcp)
        SyncServer.shared.start()
        WeatherService.shared.start()
    }

    public func applicationWillTerminate(_ notification: Notification) {
        SyncServer.shared.stop()
        SpotifyTracker.shared.stopPolling()
        TypingTracker.shared.stop()
        SystemStatsTracker.shared.stop()
        HotkeyManager.shared.stop()
    }
}

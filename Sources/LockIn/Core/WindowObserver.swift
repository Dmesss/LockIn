import Foundation
import CoreGraphics

public struct WindowBounds {
    public let x: CGFloat
    public let y: CGFloat
    public let width: CGFloat
    public let height: CGFloat
    public let owner: String
    
    public var top: CGFloat { y }
    public var left: CGFloat { x }
    public var right: CGFloat { x + width }
    public var bottom: CGFloat { y + height }
    public var rect: CGRect { CGRect(x: x, y: y, width: width, height: height) }
}

public class WindowObserver {
    public static let shared = WindowObserver()
    
    private var cachedWindows: [WindowBounds] = []
    private var lastScan: TimeInterval = 0
    private let scanInterval: TimeInterval = 0.2 // Low CPU impact

    private init() {}

    public func getWindows(force: Bool = false) -> [WindowBounds] {
        let now = ProcessInfo.processInfo.systemUptime
        if !force && (now - lastScan) < scanInterval {
            return cachedWindows
        }
        lastScan = now

        var results: [WindowBounds] = []
        let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
        guard let list = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
            return []
        }

        for info in list {
            guard let layer = info[kCGWindowLayer as String] as? Int, layer == 0 else { continue }
            guard let boundsDict = info[kCGWindowBounds as String] as? [String: Any],
                  let x = boundsDict["X"] as? Double,
                  let y = boundsDict["Y"] as? Double,
                  let w = boundsDict["Width"] as? Double,
                  let h = boundsDict["Height"] as? Double else { continue }

            if w < 200 || h < 120 { continue }
            let owner = (info[kCGWindowOwnerName as String] as? String) ?? ""
            let lowerOwner = owner.lowercased()
            if lowerOwner == "duckpet" || lowerOwner == "miniu" || lowerOwner == "window server" || lowerOwner == "dock" {
                continue
            }

            results.append(WindowBounds(x: CGFloat(x), y: CGFloat(y), width: CGFloat(w), height: CGFloat(h), owner: owner))
        }

        cachedWindows = results
        return results
    }

    public func getFrontmostWindow() -> WindowBounds? {
        let windows = getWindows(force: true)
        return windows.first
    }

    public func findPerchSurface(centerX: CGFloat, bottomY: CGFloat) -> (surfaceY: CGFloat, window: WindowBounds)? {
        let windows = getWindows()
        var bestY: CGFloat? = nil
        var bestWindow: WindowBounds? = nil

        for win in windows {
            if centerX >= win.left && centerX <= win.right {
                if bottomY <= win.top + 30 {
                    if bestY == nil || win.top < bestY! {
                        bestY = win.top
                        bestWindow = win
                    }
                }
            }
        }

        if let surfaceY = bestY, let win = bestWindow {
            return (surfaceY, win)
        }
        return nil
    }
}

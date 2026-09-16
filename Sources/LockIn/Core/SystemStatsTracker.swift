import Foundation
import IOKit.ps
import Darwin.Mach

public class SystemStatsTracker {
    public static let shared = SystemStatsTracker()

    private var timer: Timer?
    private var prevCpuInfo = host_cpu_load_info()
    private var prevCpuValid = false

    private init() {}

    public func start() {
        poll()
        DispatchQueue.main.async {
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
                self?.poll()
            }
        }
    }

    public func stop() {
        timer?.invalidate()
        timer = nil
    }

    public func poll() {
        // 1. Read Battery
        let bat = readBattery()

        // 2. Read CPU
        let cpu = readCpu()

        DispatchQueue.main.async {
            let state = DuckState.shared
            state.hasBattery = bat.hasBattery
            state.batteryPercent = bat.level
            state.isCharging = bat.isCharging
            state.cpuUsage = cpu

            if state.enableSystemReactions {
                state.isLowBattery = bat.hasBattery && (bat.level <= 20) && !bat.isCharging
                state.isHighCpu = (cpu >= 65.0)
            } else {
                state.isLowBattery = false
                state.isHighCpu = false
            }
        }
    }

    private func readBattery() -> (level: Int, isCharging: Bool, hasBattery: Bool) {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef],
              !sources.isEmpty else {
            return (100, false, false)
        }

        for source in sources {
            guard let desc = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: Any] else { continue }
            let currentCap = desc[kIOPSCurrentCapacityKey as String] as? Int ?? 0
            let maxCap = desc[kIOPSMaxCapacityKey as String] as? Int ?? 100
            let isCharging = desc[kIOPSIsChargingKey as String] as? Bool ?? false
            let powerState = desc[kIOPSPowerSourceStateKey as String] as? String ?? ""
            let percent = maxCap > 0 ? Int((Double(currentCap) / Double(maxCap)) * 100.0) : 0
            let charging = isCharging || (powerState == (kIOPSACPowerValue as String))
            return (percent, charging, true)
        }
        return (100, false, false)
    }

    private func readCpu() -> Double {
        var cpuInfo = host_cpu_load_info()
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)
        let kerr = withUnsafeMutablePointer(to: &cpuInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }

        guard kerr == KERN_SUCCESS else { return 0.0 }

        if !prevCpuValid {
            prevCpuInfo = cpuInfo
            prevCpuValid = true
            return 0.0
        }

        let userDiff = Double(cpuInfo.cpu_ticks.0 - prevCpuInfo.cpu_ticks.0)
        let sysDiff  = Double(cpuInfo.cpu_ticks.1 - prevCpuInfo.cpu_ticks.1)
        let idleDiff = Double(cpuInfo.cpu_ticks.2 - prevCpuInfo.cpu_ticks.2)
        let niceDiff = Double(cpuInfo.cpu_ticks.3 - prevCpuInfo.cpu_ticks.3)

        let total = userDiff + sysDiff + idleDiff + niceDiff
        prevCpuInfo = cpuInfo

        guard total > 0 else { return 0.0 }
        let used = userDiff + sysDiff + niceDiff
        return max(0.0, min(100.0, (used / total) * 100.0))
    }
}

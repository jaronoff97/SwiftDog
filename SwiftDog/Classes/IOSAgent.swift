//
//  IOSAgent.swift
//  SwiftDog
//
//  CREDIT TO: https://github.com/shogo4405/Usage/blob/master/Sources/HostCPULoadInfo.swift
//

import Foundation

internal struct DataUsageInfo {
    var wifiReceived: UInt32 = 0
    var wifiSent: UInt32 = 0
    var wirelessWanDataReceived: UInt32 = 0
    var wirelessWanDataSent: UInt32 = 0
    
    mutating func updateInfoByAdding(info: DataUsageInfo) {
        wifiSent += info.wifiSent
        wifiReceived += info.wifiReceived
        wirelessWanDataSent += info.wirelessWanDataSent
        wirelessWanDataReceived += info.wirelessWanDataReceived
    }
}

public struct IOSAgent {
    static let count:natural_t = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size)
    static let machHost:mach_port_t = mach_host_self()
    
    private static var previous_info: host_cpu_load_info = host_cpu_load_info()
    private static let wwanInterfacePrefix = "pdp_ip"
    private static let wifiInterfacePrefix = "en"
    
    private static var previous_wifi_sent: UInt32 = 0
    private static var previous_wifi_received: UInt32 = 0
    
    internal static func send_agent_metrics() {
        if let cpu_usage = IOSAgent.current_CPU() {
            Datadog.dd.metric.send(metric: "system.cpu.user", points: Float(cpu_usage["user"]!), host: Datadog.dd.host, tags: [], type: .gauge)
            Datadog.dd.metric.send(metric: "system.cpu.idle", points: Float(cpu_usage["idle"]!), host: Datadog.dd.host, tags: [], type: .gauge)
            Datadog.dd.metric.send(metric: "system.cpu.system", points: Float(cpu_usage["system"]!), host: Datadog.dd.host, tags: [], type: .gauge)
        }
        if let mem_usage = IOSAgent.current_MEM() {
            Datadog.dd.metric.send(metric: "system.mem.used", points: mem_usage, host: Datadog.dd.host, tags: [], type: .gauge)
        }
        let data_usage_info = IOSAgent.getDataUsage()
        if IOSAgent.previous_wifi_received != 0 || IOSAgent.previous_wifi_sent != 0 {
            Datadog.dd.metric.send(metric: "system.net.bytes_sent", points: Float(data_usage_info.wifiReceived - self.previous_wifi_received), host: Datadog.dd.host, tags: [], type: Metric.MetricData.MetricType.rate(Float(Datadog.dd.interval_seconds)))
            Datadog.dd.metric.send(metric: "system.net.bytes_rcvd", points: Float(data_usage_info.wifiSent - self.previous_wifi_sent), host: Datadog.dd.host, tags: [], type: Metric.MetricData.MetricType.rate(Float(Datadog.dd.interval_seconds)))
        }
        Datadog.dd.metric.send(metric: "ios.device.battery.level", points: IOSAgent.get_battery_level())
        IOSAgent.previous_wifi_sent = data_usage_info.wifiSent
        IOSAgent.previous_wifi_received = data_usage_info.wifiReceived
    }
    
    internal static func modelIdentifier() -> String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
    internal static func getDataUsage() -> DataUsageInfo {
        var interfaceAddresses: UnsafeMutablePointer<ifaddrs>? = nil
        
        var dataUsageInfo = DataUsageInfo()
        
        guard getifaddrs(&interfaceAddresses) == 0 else { return dataUsageInfo }
        
        var pointer = interfaceAddresses
        while pointer != nil {
            guard let info = IOSAgent.getDataUsageInfo(from: pointer!) else {
                pointer = pointer!.pointee.ifa_next
                continue
            }
            dataUsageInfo.updateInfoByAdding(info: info)
            pointer = pointer!.pointee.ifa_next
        }
        
        freeifaddrs(interfaceAddresses)
        
        return dataUsageInfo
    }
    
    private static func getDataUsageInfo(from infoPointer: UnsafeMutablePointer<ifaddrs>) -> DataUsageInfo? {
        let pointer = infoPointer
        
        let name: String! = String(cString: infoPointer.pointee.ifa_name)
        let addr = pointer.pointee.ifa_addr.pointee
        guard addr.sa_family == UInt8(AF_LINK) else { return nil }
        
        return dataUsageInfo(from: pointer, name: name)
    }
    
    private static func dataUsageInfo(from pointer: UnsafeMutablePointer<ifaddrs>, name: String) -> DataUsageInfo {
        var networkData: UnsafeMutablePointer<if_data>? = nil
        var dataUsageInfo = DataUsageInfo()
        
        if name.hasPrefix(IOSAgent.wifiInterfacePrefix) {
            networkData = unsafeBitCast(pointer.pointee.ifa_data, to: UnsafeMutablePointer<if_data>.self)
            dataUsageInfo.wifiSent += networkData?.pointee.ifi_obytes ?? 0
            dataUsageInfo.wifiReceived += networkData?.pointee.ifi_ibytes ?? 0
        } else if name.hasPrefix(IOSAgent.wwanInterfacePrefix) {
            networkData = unsafeBitCast(pointer.pointee.ifa_data, to: UnsafeMutablePointer<if_data>.self)
            dataUsageInfo.wirelessWanDataSent += networkData?.pointee.ifi_obytes ?? 0
            dataUsageInfo.wirelessWanDataReceived += networkData?.pointee.ifi_ibytes ?? 0
        }
        
        return dataUsageInfo
    }
    
    internal static func get_battery_level() -> Float {
        if !UIDevice.current.isBatteryMonitoringEnabled {
            UIDevice.current.isBatteryMonitoringEnabled = true
        }
        return UIDevice.current.batteryLevel
    }

    
    internal static func current_MEM() -> Float? {
        
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        if kerr == KERN_SUCCESS {
            let used_bytes = taskInfo.resident_size
            print("bytes used: \(used_bytes)")
            return Float(used_bytes)
        } else {
            print("Error with task_info(): " +
                (String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error"))
            return nil
        }
        
    }
    
    internal static func current_CPU() -> [String: Double]? {
        var count:natural_t = IOSAgent.count
        var info:host_cpu_load_info = host_cpu_load_info()
        let result:kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(machHost, HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else {
            return nil
        }
        
        let userDiff = Double(info.cpu_ticks.0 - previous_info.cpu_ticks.0)
        let sysDiff  = Double(info.cpu_ticks.1 - previous_info.cpu_ticks.1)
        let idleDiff = Double(info.cpu_ticks.2 - previous_info.cpu_ticks.2)
        let niceDiff = Double(info.cpu_ticks.3 - previous_info.cpu_ticks.3)
        
        previous_info = info
        
        let totalTicks = sysDiff + userDiff + niceDiff + idleDiff
        
        let sys  = sysDiff  / totalTicks * 100.0
        let user = userDiff / totalTicks * 100.0
        let idle = idleDiff / totalTicks * 100.0
        let nice = niceDiff / totalTicks * 100.0
        
        return ["user": user,
                "system": sys,
                "idle": idle,
                "nice": nice]
        
    }
}

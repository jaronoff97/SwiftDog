//
//  IOSAgent.swift
//  SwiftDog
//
//  CREDIT TO: https://github.com/shogo4405/Usage/blob/master/Sources/HostCPULoadInfo.swift
//

import Foundation

public struct IOSAgent {
    static let count:natural_t = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size)
    static let machHost:mach_port_t = mach_host_self()
    
    public static func current_MEM() -> Int? {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                          task_flavor_t(MACH_TASK_BASIC_INFO),
                          $0,
                          &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            print("Memory in use (in bytes): \(info.resident_size)")
            return Int(info.resident_size)
        }
        else {
            print("Error with task_info(): " +
                (String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error"))
            return nil
        }
    }
    
    public static func current_CPU() -> [String: Double]? {
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
        return ["user": Double(info.cpu_ticks.0),
                "system": Double(info.cpu_ticks.1),
                "idle": Double(info.cpu_ticks.2),
                "nice": Double(info.cpu_ticks.3)]
        
    }
}

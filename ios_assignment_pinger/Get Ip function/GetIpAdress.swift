//
//  GetIpAdress.swift
//  ios_assignment_pinger
//
//  Created by Cem Sezeroglu on 15.11.2020.
//

import Foundation

//MARK: This is the function which I can get my IP adress as String
//Found from here https://stackoverflow.com/questions/30748480/swift-get-devices-wifi-ip-address



public func getIPAddress() -> String? {
    
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6),
                    let cString = interface?.ifa_name,
                    String(cString: cString) == "en0",
                    let saLen = (interface?.ifa_addr.pointee.sa_len) {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    let ifaAddr = interface?.ifa_addr
                    getnameinfo(ifaAddr,
                                socklen_t(saLen),
                                &hostname,
                                socklen_t(hostname.count),
                                nil,
                                socklen_t(0),
                                NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }


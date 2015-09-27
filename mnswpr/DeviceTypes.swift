//
//  DeviceTypes.swift
//  SpriteMine
//
//  Created by Jonathon Toon on 9/5/15.
//  Copyright (c) 2015 Jonathon Toon. All rights reserved.
//

// Usage example:
//    let deviceType : DeviceTypes = UIDevice().deviceType
//    let deviceName : String = deviceType.rawValue
//    You have to import UIKit

import UIKit

public enum DeviceTypes : String {
    case simulator      = "Simulator",
    iPad2          = "iPad 2",
    iPad3          = "iPad 3",
    iPhone4        = "iPhone 4",
    iPhone4S       = "iPhone 4S",
    iPhone5        = "iPhone 5",
    iPhone5S       = "iPhone 5S",
    iPhone5c       = "iPhone 5c",
    iPad4          = "iPad 4",
    iPadMini1      = "iPad Mini 1",
    iPadMini2      = "iPad Mini 2",
    iPadAir1       = "iPad Air 1",
    iPadAir2       = "iPad Air 2",
    iPhone6        = "iPhone 6",
    iPhone6plus    = "iPhone 6 Plus",
    unrecognized   = "?unrecognized?"
}

public extension UIDevice {
    public var deviceType: DeviceTypes {
        var sysinfo : [CChar] = Array(count: sizeof(utsname), repeatedValue: 0)
        let modelCode = sysinfo.withUnsafeMutableBufferPointer {
            (inout ptr: UnsafeMutableBufferPointer<CChar>) -> DeviceTypes in
            uname(UnsafeMutablePointer<utsname>(ptr.baseAddress))
            // skip 1st 4 256 byte sysinfo result fields to get "machine" field
            let machinePtr = ptr.baseAddress.advancedBy(Int(_SYS_NAMELEN * 4))
            var modelMap : [ String : DeviceTypes ] = [
                "i386"      : .simulator,
                "x86_64"    : .simulator,
                "iPad2,1"   : .iPad2,          //
                "iPad3,1"   : .iPad3,          // (3rd Generation)
                "iPhone3,1" : .iPhone4,        //
                "iPhone3,2" : .iPhone4,        //
                "iPhone4,1" : .iPhone4S,       //
                "iPhone5,1" : .iPhone5,        // (model A1428, AT&T/Canada)
                "iPhone5,2" : .iPhone5,        // (model A1429, everything else)
                "iPad3,4"   : .iPad4,          // (4th Generation)
                "iPad2,5"   : .iPadMini1,      // (Original)
                "iPhone5,3" : .iPhone5c,       // (model A1456, A1532 | GSM)
                "iPhone5,4" : .iPhone5c,       // (model A1507, A1516, A1526 (China), A1529 | Global)
                "iPhone6,1" : .iPhone5S,       // (model A1433, A1533 | GSM)
                "iPhone6,2" : .iPhone5S,       // (model A1457, A1518, A1528 (China), A1530 | Global)
                "iPad4,1"   : .iPadAir1,       // 5th Generation iPad (iPad Air) - Wifi
                "iPad4,2"   : .iPadAir2,       // 5th Generation iPad (iPad Air) - Cellular
                "iPad4,4"   : .iPadMini2,      // (2nd Generation iPad Mini - Wifi)
                "iPad4,5"   : .iPadMini2,      // (2nd Generation iPad Mini - Cellular)
                "iPhone7,1" : .iPhone6plus,    // All iPhone 6 Plus's
                "iPhone7,2" : .iPhone6         // All iPhone 6's
            ]
            if let model = modelMap[String.fromCString(machinePtr)!] {
                return model
            }
            return DeviceTypes.unrecognized
        }
        return modelCode
    }
}
//
//  Characteristic.swift
//  testBTH
//
//  Created by OT Chen on 2020/2/26.
//  Copyright © 2020 OTChen. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol ServiceProtocol {
    static func utid() -> String
    static func uuid() -> CBUUID
}

struct HeartRateService: ServiceProtocol {
    static func utid() -> String { "org.bluetooth.service.heart_rate" }
    static func uuid() -> CBUUID { CBUUID(string: "0x180D") }
}
    

protocol CharacteristicProtocol {
    static func utid() -> String
    static func uuid() -> CBUUID
    
    associatedtype Result
    static func read(bytes: [UInt8]) -> Result
}

extension CharacteristicProtocol {
    static func read(cbCharacteristic: CBCharacteristic) -> Result? {
        guard let value: Data = cbCharacteristic.value else { return nil }
        return read(bytes: [UInt8](value))
    }
}

struct HeartRateMeasurementCharacteristic: CharacteristicProtocol {
    static func utid() -> String { "org.bluetooth.characteristic.heart_rate_measurement" }
    static func uuid() -> CBUUID { CBUUID(string: "0x2A37") }
    
    struct Result {
        var bpm: Int = -1
        var sensorContactStatus: SensorContactStatus = .none
        var energyExpendedStatus: EnergyExpendedStatus = .none
        var energyExpendedValue: Int = -1
        var rrInterval: RRInterval = .none
        var rrIntervalValues: [Int] = []
    }
    
    enum ValueFormat : CustomStringConvertible  {
        case none
        case uint8
        case uint16
        
        init(flags: UInt8) {
            switch (flags >> 0) & 0x01 {
            case 0:
                self = .uint8
            case 1:
                self = .uint16
            default:
                self = .none
            }
        }
        var description: String {
            switch self {
            case .uint8: return "uint8"
            case .uint16: return "uint16"
            default: return "n/a"
            }
        }
    }
    
    static func read(bytes: [UInt8]) -> Result {
        var cur = 0
        guard cur < bytes.count else { assert(false) }
        
        let valueFormat = ValueFormat(flags: bytes[cur])
        let sensorContactStatus = SensorContactStatus(flags: bytes[cur])
        let energyExpendedStatus = EnergyExpendedStatus(flags: bytes[cur])
        let rrInterval = RRInterval(flags: bytes[cur])
        
        var bpm = 0
        if case .uint8 = valueFormat {
            cur += 1
            guard cur < bytes.count else { assert(false) }
            bpm = Int(bytes[cur])
        }
        else if case .uint16 = valueFormat {
            cur += 2
            guard cur < bytes.count else { assert(false) }
            bpm =  256 * Int(bytes[cur]) + Int(bytes[cur-1])
        }
        
        var energyExpendedValue = 0
        if case EnergyExpendedStatus.present = energyExpendedStatus {
            cur += 2
            guard cur < bytes.count else { assert(false) }
            energyExpendedValue = 256 * Int(bytes[cur]) + Int(bytes[cur-1])
        }
        
        var rrIntervalValues: [Int] = []
        if case RRInterval.oneOrMorePresent = rrInterval {
            cur += 2
            while cur < bytes.count {
                let rrIntervalValue = 256 * Int(bytes[cur]) + Int(bytes[cur-1])
                rrIntervalValues.append(rrIntervalValue)
                cur += 2
            }
        }
        
        let result = Result(bpm: bpm,
                            sensorContactStatus: sensorContactStatus,
                            energyExpendedStatus: energyExpendedStatus,
                            energyExpendedValue: energyExpendedValue,
                            rrInterval: rrInterval,
                            rrIntervalValues: rrIntervalValues
        )

        print("bytes width: \(bytes.count)")
        print(result)
        return result
    }
}

enum SensorContactStatus : CustomStringConvertible  {
    case none
    case unsupported
    case supportedButNotContacted
    case supportedAndContacted
    
    init(flags: UInt8) {
        switch (flags >> 1) & 0x3 {
        case 0: fallthrough
        case 1:
            self = .unsupported
        case 2:
            self = .supportedButNotContacted
        case 3:
            self = .supportedAndContacted
        default:
            self = .none
        }
    }
    
    var description: String {
        switch self {
        case .supportedAndContacted: return "Contacted"
        default: return "Not contacted"
        }
    }
}

enum EnergyExpendedStatus : CustomStringConvertible {
    case none
    case notPresent
    case present

    init(flags: UInt8) {
        switch (flags >> 3) & 0x1 {
        case 0:
            self = .notPresent
        case 1:
            self = .present
        default:
            self = .none
        }
    }

    var description: String {
        switch self {
        case .none: return "none"
        case .notPresent: return "not present"
        case .present: return "present"
        }
    }
}

enum RRInterval : CustomStringConvertible {
    case none
    case notPresent
    case oneOrMorePresent
    
    init(flags: UInt8) {
    switch (flags >> 4) & 0x1 {
        case 0:
            self = .notPresent
        case 1:
            self = .oneOrMorePresent
        default:
            self = .none
        }
    }
    
    var description: String {
        switch self {
        case .none: return "none"
        case .notPresent: return "not present"
        case .oneOrMorePresent: return "one or more present"
        }
    }
}

struct HeartRateBodySensorLocationCharacteristic: CharacteristicProtocol {
    static func utid() -> String { "org.bluetooth.characteristic.body_sensor_location" }
    static func uuid() -> CBUUID { CBUUID(string: "0x2A38") }
    
    typealias Result = BodySensorLocation
    static func read(bytes: [UInt8]) -> BodySensorLocation {
        return BodySensorLocation(flags: bytes[0])
    }
}

// used by HeartRateBodySensorLocationCharacteristic
enum BodySensorLocation : String {
    case none
    case other
    case chest
    case wrist
    case finger
    case hand
    case earLobe
    case foot
    
    init(flags: UInt8) {
        switch flags {
        case 0:
            self = .other
        case 1:
            self = .chest
        case 2:
            self = .wrist
        case 3:
            self = .finger
        case 4:
            self = .hand
        case 5:
            self = .earLobe
        case 6:
            self = .foot
        default:
            self = .none
        }
    }
}


//
//  BTHConnection.swift
//  testBTH
//
//  Created by OT Chen on 2020/2/25.
//  Copyright © 2020 OTChen. All rights reserved.
//

import Foundation

import CoreBluetooth


enum ConnectionState : String {
    case disconnected
    case scanning
    case connecting
    case connecting_and_checking_characteristic
    case connected
    case disconnecting
    
    var ready : Bool {
        return self == .connected
    }
}

class HeartRateDetector: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var connectionState = ConnectionState.disconnected
    @Published var result = HeartRateMeasurementCharacteristic.Result()
    @Published var bodySensorLocation = BodySensorLocation.none
    
    var centralManager: CBCentralManager? = nil
    func createCBCentralManager() -> CBCentralManager {
        let queue = DispatchQueue(label: "idv.otchen.testBTH.centralManager", qos: .default, attributes: .concurrent)
        return CBCentralManager(delegate: self, queue: queue)
    }
    
    var peripheral: CBPeripheral? = nil
    
    func start() {
        stop()
        centralManager = createCBCentralManager()
    }
    
    func stop() {
        self.centralManager?.delegate = nil
        self.centralManager?.stopScan()
        if self.peripheral != nil {
            self.peripheral!.delegate = nil
            self.centralManager?.cancelPeripheralConnection(self.peripheral!)
            self.peripheral = nil
        }
        self.centralManager = nil
    }
  
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(#function, "isScanning: \(central.isScanning)")
        switch central.state {
        case .unknown:
            print("unknown")
        case .resetting:
            print("resetting")
        case .unsupported:
            print("unsupported")
        case .unauthorized:
            print("unauthorized")
        case .poweredOff:
            print("poweredOff")
        case .poweredOn:
            print("poweredOn")
            central.scanForPeripherals(withServices: [HeartRateService.uuid()], options: nil)
            DispatchQueue.main.async {
                self.connectionState = .scanning
            }
        @unknown default:
            print("unknown")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
        print("centralManager didDiscover \(String(describing: peripheral.name)) advertisementData: \(advertisementData.keys.joined(separator: "|")), rssi: \(RSSI)")
        
        central.stopScan()
        peripheral.delegate = self
        central.connect(peripheral)
        self.peripheral = peripheral
        
        DispatchQueue.main.async {
            self.connectionState = .connecting
        }
    }

    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?){
        print(#function)
        DispatchQueue.main.async {
            self.connectionState = .disconnected
            self.result = HeartRateMeasurementCharacteristic.Result()
            self.bodySensorLocation = .none
        }
        
        central.scanForPeripherals(withServices: [HeartRateService.uuid()], options: nil)
        DispatchQueue.main.async {
            self.connectionState = .scanning
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral){
        print(#function)
        peripheral.discoverServices([HeartRateService.uuid()])
        DispatchQueue.main.async {
            self.connectionState = .connecting
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?){
        print(#function, "error: \(String(describing: error))")
        guard error == nil else {
            centralManager?.cancelPeripheralConnection(peripheral)
            return
        }
        guard let service = peripheral.services?.filter({$0.uuid == HeartRateService.uuid()}).first else {
            centralManager?.cancelPeripheralConnection(peripheral)
            return
        }
        // let filtered = [Characteristic.HeartRateMeasurement.uuid, Characteristic.HeartRateBodySensorLocation.uuid]
        peripheral.discoverCharacteristics(nil, for: service)
        
        DispatchQueue.main.async {
            self.connectionState = .connecting_and_checking_characteristic
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?){
        print(#function, "error: \(String(describing: error))")
        dumpPeripheral(peripheral: peripheral)
        guard error == nil else {
            centralManager?.cancelPeripheralConnection(peripheral)
            return
        }
        guard let characteristics = service.characteristics else {
            return
        }
        
        for characteristic in characteristics {
            if characteristic.uuid == HeartRateMeasurementCharacteristic.uuid() {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            else if characteristic.uuid == HeartRateBodySensorLocationCharacteristic.uuid() {
                peripheral.readValue(for: characteristic)
            }
        }
        
        DispatchQueue.main.async {
            self.connectionState = .connected
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?){
        guard let value = characteristic.value else {
            assert(false, "characteristic (\(characteristic.uuid.uuidString)) value returned is nil")
            return
        }
        let bytes = [UInt8](value)
        
        if characteristic.uuid == HeartRateMeasurementCharacteristic.uuid() {
            let result = HeartRateMeasurementCharacteristic.read(bytes: bytes)
            DispatchQueue.main.async {
                self.result = result
            }
        }
        else if characteristic.uuid == HeartRateBodySensorLocationCharacteristic.uuid() {
            let result = HeartRateBodySensorLocationCharacteristic.read(bytes: bytes)
            DispatchQueue.main.async {
                self.bodySensorLocation = result
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?){
        print(#function)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?){
        var name = ""
        if characteristic.uuid == HeartRateMeasurementCharacteristic.uuid() {
            name = "heart rate mesurement"
        }
        else {
            name = "other (\(characteristic.uuid.uuidString))"
        }
        print("\(name) characteristic notification state, isNotifying: \(characteristic.isNotifying)")
    }
}


// optional functions
extension HeartRateDetector {
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]){
        print(#function)
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?){
        print(#function)
    }
    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral){ print(#function)
    }
    func centralManager(_ central: CBCentralManager, didUpdateANCSAuthorizationFor peripheral: CBPeripheral){
        print(#function)
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?){
        print(#function)
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?){
        print(#function)
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?){
        print(#function)
    }
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?){
        print(#function)
    }
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral){
        print(#function)
    }
    func peripheral(_ peripheral: CBPeripheral, didOpen channel: CBL2CAPChannel?, error: Error?){
        print(#function)
    }
    func peripheralDidUpdateName(_ peripheral: CBPeripheral){
        print(#function)
    }
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]){
        print(#function)
    }
    func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?){
        print(#function)
    }
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?){
        print(#function)
    }
}

func dumpPeripheral(peripheral: CBPeripheral) {
    if let services = peripheral.services {
        for service in services {
            guard service.uuid == HeartRateService.uuid() else { continue }
            print("found heart_rate_service")

            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    if characteristic.uuid == HeartRateBodySensorLocationCharacteristic.uuid() {
                        print("found characteristic body sensor location")
                    }
                    else if characteristic.uuid == HeartRateMeasurementCharacteristic.uuid() {
                        print("found characteristic measurement")
                    }
                    else {
                        print("another characteristic \(characteristic.uuid.uuidString)")
                    }
                }
            }
            else {
                print("null characteristics")
            }
        }
    }
    else {
        print("null services")
    }
}

//
//  HealthKitService.swift
//  testBTH
//
//  Created by OT Chen on 2020/3/2.
//  Copyright © 2020 OTChen. All rights reserved.
//

import Foundation
import HealthKit

struct HKStore {
    
    let store: HKHealthStore?
    let read: Set<HKQuantityType>?
    let write: Set<HKQuantityType>?
    
    init(){
        guard HKHealthStore.isHealthDataAvailable() else {
            self.store = nil
            self.read = nil
            self.write = nil
            return
        }
        self.store = HKHealthStore()
        self.read = [HKQuantityType.quantityType(forIdentifier: .heartRate)!]
        self.write = [HKQuantityType.quantityType(forIdentifier: .heartRate)!]
        
        store?.requestAuthorization(toShare: Set(write!), read: Set(read!)) { (success: Bool, error: Error?) in
            if success {
                print("OK")
            }
            else {
                print("NG, error: \(String(describing: error))")
            }
        }
    }
    
    func update(_ bpm: Double) {
        let type = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let bpm_unit = HKUnit.count().unitDivided(by: .minute())
        let quantity = HKQuantity(unit: bpm_unit, doubleValue: bpm)
        let sample = HKQuantitySample(type: type, quantity: quantity, start: Date(), end: Date())
        
        store?.save(sample) { (success: Bool, error: Error?) in
            if success {
                print("save ok")
            }
            else {
                print("save ng, error: \(String(describing: error))")
            }
        }
    }
    
    func query(completeHandler: @escaping ([HKSample]?) -> Void )  {
        let type = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let typePredict = HKQuery.predicateForSamples(withStart: Date() - 86400, end: Date(), options: [])
        let query = HKAnchoredObjectQuery(type: type, predicate: typePredict, anchor: nil, limit: 5) { (query: HKAnchoredObjectQuery, samples: [HKSample]?, deleteObjects: [HKDeletedObject]?, anchor: HKQueryAnchor?, error: Error?) in
            completeHandler(samples)
//            if let samples = samples {
//                for sample in samples {
//                    print(sample)
//                }
//            }
        }
        store?.execute(query)
    }
}

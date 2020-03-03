//
//  HealthKitService.swift
//  testBTH
//
//  Created by OT Chen on 2020/3/2.
//  Copyright © 2020 OTChen. All rights reserved.
//

import Foundation
import HealthKit

struct MyHealthKitService {
    
    let store: HKHealthStore
    init(){
        guard HKHealthStore.isHealthDataAvailable() else {
            fatalError()
        }
        store = HKHealthStore()
        
        let read: Set<HKQuantityType> = [HKQuantityType.quantityType(forIdentifier: .heartRate)!]
        let write: Set<HKQuantityType> = [HKQuantityType.quantityType(forIdentifier: .heartRate)!]
        
        store.requestAuthorization(toShare: Set(write), read: Set(read)) { (success: Bool, error: Error?) in
            if success {
                print("OK")
            }
            else {
                print("NG, error: \(String(describing: error))")
            }
        }
    }
}

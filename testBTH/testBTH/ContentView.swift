//
//  ContentView.swift
//  testBTH
//
//  Created by OT Chen on 2020/2/25.
//  Copyright © 2020 OTChen. All rights reserved.
//

import SwiftUI

import HealthKit

struct ContentView: View {
    @ObservedObject var detector = HeartRateDetector()
    
    var body: some View {
        HeartRateView(connectionState: $detector.connectionState,
                      result: $detector.result,
                      bodySensorLocation: $detector.bodySensorLocation)
        .onAppear{
            self.detector.start()
            self.detector.readBpm { (samples: [HKSample]?) in
                guard let samples = samples else { return }
                
                for sample in samples {
                    guard let qSample = sample as? HKQuantitySample else {
                        print("usual")
                        continue
                    }
                    let q = qSample.quantity
                    let unit = HKUnit.count().unitDivided(by: .minute())
                    print(q.doubleValue(for: unit))
                }
                
            }
        }
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  ContentView.swift
//  testBTH
//
//  Created by OT Chen on 2020/2/25.
//  Copyright © 2020 OTChen. All rights reserved.
//

import SwiftUI

import Combine
import HealthKit

struct ContentView: View {
    let hkStore = HKStore()
    @ObservedObject var detector = HeartRateDetector()
    var cancellable: Cancellable? = nil
    
    var body: some View {
        HeartRateView(connectionState: $detector.connectionState,
                      result: $detector.result,
                      bodySensorLocation: $detector.bodySensorLocation)
        .onAppear{
            self.detector.start()
            self.detector.$result
                .receive(on: RunLoop.main)
                .sink(receiveValue: { (result: HeartRateMeasurementCharacteristic.Result) in
                    self.hkStore.update(Double(result.bpm))
                })
        }
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

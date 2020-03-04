//
//  RunningView.swift
//  testBTH
//
//  Created by OT Chen on 2020/3/4.
//  Copyright © 2020 OTChen. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct RunningView : View {
    let hkStore = HKStore()
    @EnvironmentObject var detector: HeartRateDetector
    var cancellable: Cancellable? = nil
    
    var body: some View {
        HeartRateView()
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


struct RunningView_Previews: PreviewProvider {
    static var detector = HeartRateDetector()
    
    static var previews: some View {
        RunningView()
            .environmentObject(detector)
    }
}

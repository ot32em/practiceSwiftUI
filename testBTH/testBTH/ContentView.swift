//
//  ContentView.swift
//  testBTH
//
//  Created by OT Chen on 2020/2/25.
//  Copyright © 2020 OTChen. All rights reserved.
//

import SwiftUI


struct ContentView: View {
    @ObservedObject var detector = HeartRateDetector()
    
    var body: some View {
        ZStack {
            Color.white
            HeartRateView(connectionState: $detector.connectionState,
                          result: $detector.result,
                          bodySensorLocation: $detector.bodySensorLocation)
                .foregroundColor(.black)
        }
        .onAppear{
            self.detector.start()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

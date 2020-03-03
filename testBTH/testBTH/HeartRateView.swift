//
//  HeartRateView.swift
//  testBTH
//
//  Created by OT Chen on 2020/2/27.
//  Copyright © 2020 OTChen. All rights reserved.
//

import Foundation
import SwiftUI


struct HeartRateView: View {
    @Binding var connectionState: ConnectionState
    @Binding var result: HeartRateMeasurementCharacteristic.Result
    @Binding var bodySensorLocation: BodySensorLocation
    
    @State var isActive: Bool = true
    
    var body: some View {
        ZStack {
            Color.accentColor
            List {
                // Heart Rate BPM
                HStack{
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .frame(width: 40)
                        .font(.system(size: 40))
                    HStack(alignment: .center) {
                        Spacer()
                        Text("\(connectionState.ready ? String(result.bpm) : "N/A")")
                            .font(.system(size: 150))
                        Spacer()
                    }
                }
                
                // RRInterval(s) in millieseconds
                HStack {
                    if result.rrInterval == .oneOrMorePresent  {
                        Image(systemName: "waveform.path.ecg")
                            .foregroundColor(.red)
                            .frame(width: 40)
                        Text("RRInterval: \(result.rrIntervalValues.map({"\($0*1000/1024)ms "}).joined(separator: ","))")
                    }
                    else {
                        Image(systemName: "waveform.path.ecg")
                            .frame(width: 40)
                        Text("RRInterval: N/A")
                    }
                }
                
                // Sensor whether contacted or not, and sensor supported body location
                HStack {
                    Image(systemName: result.sensorContactStatus == .supportedAndContacted ? "eye" : "eye.slash")
                        .frame(width: 40)
                    Text("Sensor: \(result.sensorContactStatus.description) \(bodySensorLocation == .none ? "" : "at \(bodySensorLocation.rawValue)")")
                }
                
                // Device connection status
                HStack{
                    Image(systemName: connectionState == .connected ? "hand.thumbsup" : "ear")
                        .frame(width: 40)
                    Text("Device: \(connectionState.rawValue) ")
                }
            }
            .foregroundColor(.primary)
        }
        .navigationBarTitle("HeartRate")
    }
    
}


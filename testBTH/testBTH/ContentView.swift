//
//  ContentView.swift
//  testBTH
//
//  Created by OT Chen on 2020/2/25.
//  Copyright © 2020 OTChen. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var heartRateDetector = BTHRDetector()
    
    private var hr_bpm_str: String {
        guard heartRateDetector.connectionState.ready else {
            return "N/A"
        }
        return String(heartRateDetector.heartRateResult.bpm)
    }
    
    var body: some View {
        ZStack {
            Color.white
            VStack {
                Spacer()
                HStack{
                    Image(systemName: "heart.fill")
                        .font(.system(size: 200, weight: .thin))
                        .foregroundColor(.red)
                    Text("\(hr_bpm_str)")
                        .font(.system(size: 300))
                        .foregroundColor(.black)
                }
                
                List {
                    HStack {
                        if heartRateDetector.heartRateResult.rrIntervalValues.isEmpty {
                            Image(systemName: "waveform.path.ecg")
                                .font(.system(size: 20, weight: .thin))
                                .foregroundColor(.black)
                            Text("RRInterval: N/A")
                                .foregroundColor(.black)
                        }
                        else {
                            Image(systemName: "waveform.path.ecg")
                                .font(.system(size: 20, weight: .thin))
                                .foregroundColor(.red)
                            
                            Text("RRInterval: \(heartRateDetector.heartRateResult.rrIntervalValues.map({"\($0*1000/1024)ms "}).joined(separator: ","))")
                                .foregroundColor(.black)
                        }
                    }
                    HStack {
                        Image(systemName: contactSymbolName(status: heartRateDetector.heartRateResult.sensorContactStatus))
                            .font(.system(size: 20, weight: .thin))
                            .foregroundColor(.black)
                        Text("Sensor: \(heartRateDetector.heartRateResult.sensorContactStatus.description) \(sensorStr(location: heartRateDetector.bodySensorLocation))")
                                .foregroundColor(.black)
                    }
                    
                    HStack{
                        Image(systemName: connectionSymbolName(state: heartRateDetector.connectionState))
                            .font(.system(size: 20, weight: .thin))
                            .foregroundColor(.black)
                        Text("Device: \(heartRateDetector.connectionState.rawValue) ")
                                .foregroundColor(.black)
                    }
                }
                Spacer()
            }
        }
        .onAppear{
            self.heartRateDetector.start()
        }
    }
}
func connectionSymbolName(state: ConnectionState) -> String {
    if case ConnectionState.connected = state {
        return "hand.thumbsup"
    }
    else {
        return "ear"
    }
}

func contactSymbolName(status: Characteristic.HeartRateMeasurement.SensorContactStatus) -> String {
    if status == .supportedAndContacted {
        return "eye"
    }
    else {
        return "eye.slash"
    }
}

func sensorStr(location: Characteristic.HeartRateBodySensorLocation.BodySensorLocation) -> String {
    if location == .none {
        return ""
    }
    else {
        return "at \(location.rawValue)"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

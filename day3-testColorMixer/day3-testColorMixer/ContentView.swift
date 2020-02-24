//
//  ContentView.swift
//  day3-testColorMixer
//
//  Created by OT Chen on 2020/2/24.
//  Copyright © 2020 OTChen. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var red: Double = 1
    @State var green: Double = 1
    @State var blue: Double = 1
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(red: red, green: green, blue: blue))
                .edgesIgnoringSafeArea(.all)
            VStack{
                RGBStatus(red: $red, green: $green, blue: $blue)
                    .padding(.all, 32)
                    .padding(.top, 50)
                Rectangle().hidden()
                RGBPicker(red: $red, green: $green, blue: $blue)
                Text("Credits: https://github.com/FradSer/30-days-of-swiftui/tree/master/03-🌈-color-mixer")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(Color(.sRGB, white: 1.25 - max(red, max(green, blue)), opacity: 1.0))
                    .italic()
                    .padding(.vertical, 16)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ColorChannelSlider: View {
    @Binding var value: Double
    let char: String
    let iconColor: Color
    var body: some View {
        HStack{
            Image(systemName: "\(char).circle")
                .foregroundColor(iconColor)
                .font(.system(size: 25))
            Slider(value: $value, in: 0.0...1.0)
            Image(systemName: "\(char).circle.fill")
                .foregroundColor(iconColor)
                .font(.system(size: 25))
        }
        .padding()
    }
}

struct RGBPicker: View {
    @Binding var red: Double
    @Binding var green: Double
    @Binding var blue: Double
    
    private func contrastToMax(initialValue: Double) -> Double {
        initialValue - max(red, max(green, blue))
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(16.0)
                .shadow(
                    color: Color(.sRGB, white: contrastToMax(initialValue: 1.0), opacity: 0.5),
                    radius: 32)
            VStack(alignment: .leading) {
                ColorChannelSlider(value: $red, char: "r", iconColor: .red)
                ColorChannelSlider(value: $green, char: "g", iconColor: .green)
                ColorChannelSlider(value: $blue, char: "b", iconColor: .blue)
            }
        }
        .padding(.all, 32)
        .frame(height: 300)
    }
}

struct RGBStatus: View {
    @Binding var red: Double
    @Binding var green: Double
    @Binding var blue: Double
    
    private func contrastToWeighted(initialValue: Double, weight: (red: Double, green: Double, blue: Double)) -> Double {
        initialValue - (red * weight.red + green * weight.green + weight.blue) / 3.0
    }
    
    var body: some View {
        ZStack{
            Rectangle()
                .cornerRadius(16)
                .frame(height: 100)
                .foregroundColor(Color(.sRGB,
                                       white: contrastToWeighted(initialValue: 1.25, weight: (1,2,1)), opacity: 0.5))
            HStack{
                Text("R: \(Int(red*255.0))")
                Text("G: \(Int(green*255.0))")
                Text("B: \(Int(blue*255.0))")
            }
            .font(.custom("Futura", size: 28))
            .foregroundColor(Color(red: red, green: green, blue: blue, opacity: 1.0))
        }
    }
}

//
//  ContentView.swift
//  day4-testTypefaceComparsion
//
//  Created by OT Chen on 2020/2/24.
//  Copyright © 2020 OTChen. All rights reserved.
//

import SwiftUI

enum DragState {
    case inactive
    case active(t: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .active(let t):
            return t
        }
    }
}

struct ContentView: View {
    @State private var rotationX: CGFloat = 23.0
    @GestureState private var dragState: DragState = .inactive
    
    var body: some View {
        let gesture = DragGesture()
            .updating($dragState) { (v: DragGesture.Value, state: inout DragState, _) in
                state = .active(t: v.translation)
            }
        return ZStack{
            Color.white.edgesIgnoringSafeArea(.all)
            VStack{
                Spacer()
                ZStack {
                    Text("A")
                        .font(.system(size: 300))
                        .foregroundColor(Color.red.opacity(0.5))
                        .fixedSize()
                        .offset(x: -rotationX, y: 0)
                        
                    Text("A")
                        .font(.custom("Futura", size: 300))
                        .foregroundColor(Color.blue.opacity(0.5))
                        .padding(.leading)
                        .fixedSize()
                        .offset(x: dragState.translation.width,
                                y: 0)
                        .gesture(gesture)
                        .animation(.spring())
                }
                .shadow(color: Color.black.opacity(0.5), radius: 8, x: 8, y: 8)
                .rotation3DEffect(Angle.degrees(Double(rotationX)), axis: (x: 0.0, y: 1.0, z: 0.0))
                
                HStack{
                    Image(systemName: "0.circle")
                        .font(.system(size: 20.0))
                        .foregroundColor(.black)
                    Slider(value: $rotationX, in: 0.0...45.0, step: 1.0)
                        .foregroundColor(.white)
                        .accentColor(.black)
                    Image(systemName: "45.circle")
                        .font(.system(size: 24.0))
                        .foregroundColor(.black)
                }
                .padding(.all, 32)
                
                Text("https://github.com/FradSer/30-days-of-swiftui/tree/master/04-🔠-typeface-comparison")
                    .italic()
                    .font(.system(size: 12))
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

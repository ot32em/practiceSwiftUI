//
//  ContentView.swift
//  testDarkMode
//
//  Created by OT Chen on 2020/2/24.
//  Copyright © 2020 OTChen. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorSchema
    var backgroundColor: UIColor {
        UIColor(named: "Background") ?? .red
    }
    var labelColor: UIColor {
        UIColor(named: "Label") ?? .red
    }
    var currentModeText: String {
        colorSchema == .dark ? "Dark       " : "Light       "
    }
    var demoTextFont: Font? {
        colorSchema == .dark ?
            Font.custom("Superclarendon", size: 78) :
            Font.custom("Condiment-Regular", size: 98)
    }
    var body: some View {
        ZStack{
            Color(backgroundColor)
                .edgesIgnoringSafeArea(.all)
            
            VStack (alignment: .leading) {
                Spacer()
                Text("Now, is")
                    .font(.system(size: 32, weight: .black))
                    .multilineTextAlignment(.leading)
                    //.padding(.top)
                Text(currentModeText)
                    .font(demoTextFont)
                    .foregroundColor(Color(labelColor).opacity(0.75))
                    .multilineTextAlignment(.leading)
                    .padding(.top, 20)
                    .frame(width: 250)
                
                Spacer()
            Text("Learning resource: FradSer@github-30-days-of-swiftui\nCourse: 02-🔛-dark-mode-test\nSelf Learning Student: OT Chen")
                .font(.system(size: 12, weight: .thin, design: .monospaced))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

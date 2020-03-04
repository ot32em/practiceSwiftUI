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
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Dashboard", destination: DashboardView())
                NavigationLink("Start a workout", destination: StartView())
                NavigationLink("Activities", destination: ActivitiesView())
                NavigationLink("Settings", destination: SettingsView())
            }
                .foregroundColor(.primary)
                .background(Color.accentColor)
                .navigationBarTitle("Main")
        }
    }
}

struct DashboardView : View {
    var body: some View {
        Text("DashboardView")
            .navigationBarTitle("DashboardView")
    }
}

struct StartView : View {
    var body: some View {
        Text("StartView")
            .navigationBarTitle("StartView")
    }
}

struct ActivitiesView : View {
    var body: some View {
        Text("ActivitiesView")
            .navigationBarTitle("ActivitiesView")
    }
}
struct SettingsView : View {
    var body: some View {
        Text("SettingsView")
            .navigationBarTitle("SettingsView")
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

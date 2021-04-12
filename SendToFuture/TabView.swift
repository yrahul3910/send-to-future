//
//  TabView.swift
//  SendToFuture
//
//  Created by Rahul Yedida on 4/12/21.
//

import SwiftUI

struct MainTabView: View {
    // What tab are we currently in?
    @State private var tabSelection = "History"
    
    var body: some View {
        TabView(selection: $tabSelection) {
            ContentView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                }
                .tag("History")
            AboutView()
                .tabItem {
                    Image(systemName: "info.circle")
                    Text("About")
                }
                .tag("About")
        }
    }
}


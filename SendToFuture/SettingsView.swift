//
//  SettingsView.swift
//  SendToFuture
//
//  Created by Rahul Yedida on 4/12/21.
//

import SwiftUI

struct SettingsView: View {
    // How far is the future, in seconds?
    @State var futureDistance = UserDefaults(suiteName: "group.com.ryedida")!.integer(forKey: "futureDistance")
    
    func save() {
        print("Attempting to save.")
        print(self.futureDistance)
        
        let userDefaults = UserDefaults(suiteName: "group.com.ryedida")!
        
        userDefaults.set(self.futureDistance, forKey: "futureDistance")
        
        print(userDefaults.integer(forKey: "futureDistance"))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("DELAY (MINUTES)")) {
                        NumberTextField(value: $futureDistance)
                    }
                }
                Spacer()
                Button(action: { self.save() }) {
                    Text("Save")
                }
            }.navigationBarTitle(Text("Settings"))
        }
        .gesture(TapGesture().onEnded({ _ in
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }))
    }
}

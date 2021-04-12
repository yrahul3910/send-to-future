//
//  SettingsView.swift
//  SendToFuture
//
//  Created by Rahul Yedida on 4/12/21.
//

import SwiftUI
import ToastUI

struct SettingsView: View {
    // How far is the future, in seconds?
    @State var futureDistance = UserDefaults(suiteName: "group.com.ryedida")!.integer(forKey: "futureDistance")
    @State var popup = false
    @State var popupText = "Saved successfully."
    
    func save() {
        print("Saving..")
        let userDefaults = UserDefaults(suiteName: "group.com.ryedida")!
        userDefaults.set(self.futureDistance, forKey: "futureDistance")
        
        self.popup = true
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("DELAY (MINUTES)")) {
                        NumberTextField(value: $futureDistance)
                    }
                }
                Button(action: { self.save() }) {
                    Text("Save")
                }.padding()
                Spacer()
            }.navigationBarTitle(Text("Settings"))
        }
        .gesture(TapGesture().onEnded({ _ in
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }))
        .toast(isPresented: $popup, dismissAfter: 2.0, content: {
            ToastView(self.popupText)
                .toastViewStyle(SuccessToastViewStyle())
        })
    }
}

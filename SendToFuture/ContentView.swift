//
//  ContentView.swift
//  SendToFuture
//
//  Created by Rahul Yedida on 2/26/21.
//

import SwiftUI
import UserNotifications
import Foundation
import CoreData

struct ContentView: View {
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: LinkEntity.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \LinkEntity.title, ascending: true)
    ])
    var links: FetchedResults<LinkEntity>
    
    @StateObject var notificationManager = NotificationManager()
    
    var body: some View {
        VStack {
            HStack {
                Text("Saved Links")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                Spacer()
            }
            ScrollView {
                ForEach(self.links, id: \.self, content: { link in
                    HStack {
                        VStack {
                            HStack {
                                Text(link.title!)
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                    .bold()
                                Spacer()
                            }
                            HStack {
                                Text("Added: " + link.added!.description)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            HStack {
                                Text(link.url!)
                                    .foregroundColor(.green)
                                Spacer()
                            }
                        }
                        Spacer()
                    }.padding()
                })
            }.padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

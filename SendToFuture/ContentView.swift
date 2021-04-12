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
    
    func deleteItems(index: IndexSet) {
        for i in index {
            let currentLink = self.links[i]
            self.moc.delete(currentLink)
        }
        
        do {
            try self.moc.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(self.links.indices, id: \.self) { i in
                        HStack {
                            VStack {
                                HStack {
                                    Text(self.links[i].title!)
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                        .bold()
                                    Spacer()
                                }
                                HStack {
                                    Text("Added: " + self.links[i].added!.description)
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                                HStack {
                                    Text(self.links[i].url!)
                                        .foregroundColor(.green)
                                    Spacer()
                                }
                            }
                            Spacer()
                        }.padding()
                    }.onDelete(perform: self.deleteItems)
                }
            }.navigationBarTitle(Text("Saved Links"))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

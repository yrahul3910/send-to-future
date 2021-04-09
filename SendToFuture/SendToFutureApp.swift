//
//  SendToFutureApp.swift
//  SendToFuture
//
//  Created by Rahul Yedida on 2/26/21.
//

import SwiftUI
import CoreData

@main
struct SendToFutureApp: App {
    var userPersistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        let storeURL = URL.storeURL(for: "group.com.ryedida", databaseName: "SendToFuture")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, userPersistentContainer.viewContext)
        }
    }
}

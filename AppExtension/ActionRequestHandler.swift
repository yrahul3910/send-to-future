//
//  ActionRequestHandler.swift
//  AppExtension
//
//  Created by Rahul Yedida on 3/22/21.
//

import UIKit
import SwiftUI
import CoreData
import MobileCoreServices

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {

    var extensionContext: NSExtensionContext?
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
    
    @FetchRequest(entity: LinkEntity.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \LinkEntity.title, ascending: true)
    ])
    var links: FetchedResults<LinkEntity>
    
    var pageTitle = ""
    var pageURL = ""
    
    func beginRequest(with context: NSExtensionContext) {
        // Do not call super in an Action extension with no user interface
        self.extensionContext = context
        
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [weak self] (dict, error) in
                    
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""
                    
                    // Save it to Core Data
                    //let timeInterval = 60 * 60 * 1  // 1 hour
                    let timeInterval = 30
                    let contextLink = LinkEntity(context: self!.userPersistentContainer.viewContext)
                    contextLink.title = self?.pageTitle
                    contextLink.url = self?.pageURL
                    contextLink.added = Date.init()
                    contextLink.future = Date.init().addingTimeInterval(TimeInterval.init(timeInterval))
                    
                    do {
                        try self?.userPersistentContainer.viewContext.save()
                    } catch {
                        print("[Extension] Could not save context: " + error.localizedDescription)
                    }
                    
                    // Define the custom actions.
                    let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION",
                                                            title: "Open",
                                                            options: UNNotificationActionOptions(rawValue: 0))
                    let deferAction = UNNotificationAction(identifier: "DEFER_1HOUR_ACTION",
                                                           title: "Remind me in 1 hour",
                                                           options: UNNotificationActionOptions(rawValue: 0))
                    
                    // Define the notification type
                    let notifCategory =
                        UNNotificationCategory(identifier: "FUTURE_NOTIFICATION",
                                               actions: [acceptAction, deferAction],
                                               intentIdentifiers: [],
                                               hiddenPreviewsBodyPlaceholder: "",
                                               options: .customDismissAction)
                    
                    // And now schedule the notification
                    let content = UNMutableNotificationContent()
                    content.title = "The future is now!"
                    content.body = "Tap to open the link you sent to future you."
                    content.userInfo = ["TITLE": self!.pageTitle,
                                        "URL": self!.pageURL]
                    content.categoryIdentifier = "FUTURE_NOTIFICATION"
                    
                    // Create notification trigger
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval.init(timeInterval), repeats: false)
                    
                    // Create notification request
                    let uuidString = UUID().uuidString
                    let request = UNNotificationRequest(identifier: uuidString,
                                                        content: content, trigger: trigger)
                    
                    // Schedule the request with the system.
                    let notificationCenter = UNUserNotificationCenter.current()
                    notificationCenter.setNotificationCategories([notifCategory])
                    notificationCenter.add(request) { (error) in
                        if error != nil {
                            print(error!.localizedDescription)
                        } else {
                            print("Notification sent successfully")
                        }
                    }
                }
            }
        }
    }
    
    func itemLoadCompletedWithPreprocessingResults(_ javaScriptPreprocessingResults: [String: Any]) {
        // Here, do something, potentially asynchronously, with the preprocessing
        // results.
        
        // In this very simple example, the JavaScript will have passed us the
        // current background color style, if there is one. We will construct a
        // dictionary to send back with a desired new background color style.
        let bgColor: Any? = javaScriptPreprocessingResults["currentBackgroundColor"]
        if bgColor == nil ||  bgColor! as! String == "" {
            // No specific background color? Request setting the background to red.
            self.doneWithResults(["newBackgroundColor": "red"])
        } else {
            // Specific background color is set? Request replacing it with green.
            self.doneWithResults(["newBackgroundColor": "green"])
        }
    }
    
    func doneWithResults(_ resultsForJavaScriptFinalizeArg: [String: Any]?) {
        if let resultsForJavaScriptFinalize = resultsForJavaScriptFinalizeArg {
            // Construct an NSExtensionItem of the appropriate type to return our
            // results dictionary in.
            
            // These will be used as the arguments to the JavaScript finalize()
            // method.
            
            let resultsDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: resultsForJavaScriptFinalize]
            
            let resultsProvider = NSItemProvider(item: resultsDictionary as NSDictionary, typeIdentifier: String(kUTTypePropertyList))
            
            let resultsItem = NSExtensionItem()
            resultsItem.attachments = [resultsProvider]
            
            // Signal that we're complete, returning our results.
            self.extensionContext!.completeRequest(returningItems: [resultsItem], completionHandler: nil)
        } else {
            // We still need to signal that we're done even if we have nothing to
            // pass back.
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }
        
        // Don't hold on to this after we finished with it.
        self.extensionContext = nil
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
}

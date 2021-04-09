//  from https://www.avanderlee.com/swift/core-data-app-extension-data-sharing/

import Foundation
import CoreData


extension DarwinNotification.Name {
    private static let appIsExtension = Bundle.main.bundlePath.hasSuffix(".appex")

    /// The relevant DarwinNotification name to observe when the managed object context has been saved in an external process.
    static var didSaveManagedObjectContextExternally: DarwinNotification.Name {
        if appIsExtension {
            return appDidSaveManagedObjectContext
        } else {
            return extensionDidSaveManagedObjectContext
        }
    }

    /// The notification to post when a managed object context has been saved and stored to the persistent store.
    static var didSaveManagedObjectContextLocally: DarwinNotification.Name {
        if appIsExtension {
            return extensionDidSaveManagedObjectContext
        } else {
            return appDidSaveManagedObjectContext
        }
    }

    /// Notification to be posted when the shared Core Data database has been saved to disk from an extension. Posting this notification between processes can help us fetching new changes when needed.
    private static var extensionDidSaveManagedObjectContext: DarwinNotification.Name {
        return DarwinNotification.Name("com.wetransfer.app.extension-did-save")
    }

    /// Notification to be posted when the shared Core Data database has been saved to disk from the app. Posting this notification between processes can help us fetching new changes when needed.
    private static var appDidSaveManagedObjectContext: DarwinNotification.Name {
        return DarwinNotification.Name("com.wetransfer.app.app-did-save")
    }
}

extension NSPersistentContainer {
    /// Called when a certain managed object context has been saved from an external process. It should also be called on the context's queue.
        func viewContextDidSaveExternally() {
            // `refreshAllObjects` only refreshes objects from which the cache is invalid. With a staleness intervall of -1 the cache never invalidates.
            // We set the `stalenessInterval` to 0 to make sure that changes in the app extension get processed correctly.
            viewContext.stalenessInterval = 0
            viewContext.refreshAllObjects()
            viewContext.stalenessInterval = -1
        }
    
    // Configure change event handling from external processes.
    func observeAppExtensionDataChanges() {
        DarwinNotificationCenter.shared.addObserver(self, for: .didSaveManagedObjectContextExternally, using: { [weak self] (_) in
            // Since the viewContext is our root context that's directly connected to the persistent store, we need to update our viewContext.
            self?.viewContext.perform {
                self?.viewContextDidSaveExternally()
            }
        })
    }
}

//
//  URLExtension.swift
//  SendToFuture
//  from https://www.avanderlee.com/swift/core-data-app-extension-data-sharing/
//
//  Created by Rahul Yedida on 2/27/21.
//

import Foundation

public extension URL {

    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}

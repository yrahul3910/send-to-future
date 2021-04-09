//
//  LinkEntity+CoreDataProperties.swift
//  SendToFuture
//
//  Created by Rahul Yedida on 3/22/21.
//
//

import Foundation
import CoreData


extension LinkEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LinkEntity> {
        return NSFetchRequest<LinkEntity>(entityName: "LinkEntity")
    }

    @NSManaged public var added: Date?
    @NSManaged public var future: Date?
    @NSManaged public var tags: String?
    @NSManaged public var title: String?
    @NSManaged public var url: String?

}

extension LinkEntity : Identifiable {

}

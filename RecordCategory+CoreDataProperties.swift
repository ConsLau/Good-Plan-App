//
//  RecordCategory+CoreDataProperties.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 1/6/2023.
//
//

import Foundation
import CoreData


extension RecordCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecordCategory> {
        return NSFetchRequest<RecordCategory>(entityName: "RecordCategory")
    }

    @NSManaged public var cateNameR: String?
    @NSManaged public var records: NSSet?

}

// MARK: Generated accessors for records
extension RecordCategory {

    @objc(addRecordsObject:)
    @NSManaged public func addToRecords(_ value: Record)

    @objc(removeRecordsObject:)
    @NSManaged public func removeFromRecords(_ value: Record)

    @objc(addRecords:)
    @NSManaged public func addToRecords(_ values: NSSet)

    @objc(removeRecords:)
    @NSManaged public func removeFromRecords(_ values: NSSet)

}

extension RecordCategory : Identifiable {

}

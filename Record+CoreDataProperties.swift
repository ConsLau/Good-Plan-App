//
//  Record+CoreDataProperties.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 2/6/2023.
//
//

import Foundation
import CoreData

enum recordType: Int32{
    case income = 0
    case expenditure = 1
}

extension Record {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Record> {
        return NSFetchRequest<Record>(entityName: "Record")
    }

    @NSManaged public var recordDate: Date?
    @NSManaged public var recordType: Int32
//    @NSManaged public var recordImage: String?
    @NSManaged public var recordAmount: Float
    @NSManaged public var recordName: String?
    @NSManaged public var categoryR: RecordCategory?

}

extension Record{
    var recRecordType: recordType{
        get{
            return Good_Plan.recordType(rawValue: self.recordType)!
        }
        
        set{
            self.recordType = newValue.rawValue
        }
    }
}

extension Record : Identifiable {

}

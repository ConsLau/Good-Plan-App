//
//  Task+CoreDataProperties.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 24/4/2023.
//
//

import Foundation
import CoreData

enum isComplete: Int32{
    case complete = 0
    case inComplete = 1
}


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var taskName: String?
    @NSManaged public var taskDesc: String?
    @NSManaged public var isComplete: Int32
    @NSManaged public var taskDate: Date?
    @NSManaged public var category: TaskCategory?


}



extension Task{
    var taskIsComplete: isComplete{
        get{
            return Good_Plan.isComplete(rawValue: self.isComplete)!
        }
        
        set{
            self.isComplete = newValue.rawValue
        }
    }
}

extension Task : Identifiable {

}

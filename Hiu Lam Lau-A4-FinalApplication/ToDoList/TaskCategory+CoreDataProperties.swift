//
//  TaskCategory+CoreDataProperties.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 27/5/2023.
//
//

import Foundation
import CoreData


extension TaskCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskCategory> {
        return NSFetchRequest<TaskCategory>(entityName: "TaskCategory")
    }

    @NSManaged public var cateName: String?
    @NSManaged public var tasks: NSSet?

}

// MARK: Generated accessors for tasks
extension TaskCategory {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: Task)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: Task)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}

extension TaskCategory : Identifiable {

}

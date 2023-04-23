//
//  CoreDataController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 24/4/2023.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol {
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    
    override init() {
        persistentContainer = NSPersistentContainer(name: "GoodPlan-DataModel")
        persistentContainer.loadPersistentStores() { (description, error ) in
            if let error = error {
                fatalError("Failed to load Core Data Stack with error: \(error)")
            }
        }
        super.init()
    }
    
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save changes to Core Data with error: \(error)")
            }
        }
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .task{
            listener.onTaskChange(change: .update, tasks: fetchTask())
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func addTask(taskName: String, taskDesc: String, taskDate: Date, isComplete: isComplete) -> Task {
        let task = NSEntityDescription.insertNewObject(forEntityName: "Task", into: persistentContainer.viewContext) as! Tasks
        
        task.taskName = taskName
        task.taskDesc = taskDesc
        task.taskDate = taskDate
        task.isComplete = isComplete
        
        return task
    }
    
    func deleteTask(task: Task) {
        persistentContainer.viewContext.delete(task)
    }
    
    func fetchTask() -> [Task]{
        var task = [Task]()
        
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        
        do{
            try task = persistentContainer.viewContext.fetch(request)
        } catch {
            print("Fetch Request failed with error: \(error)")
        }
        
        return task
    }
    

}

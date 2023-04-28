//
//  CoreDataController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 24/4/2023.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    var TaskFetchedResultsController: NSFetchedResultsController<Task>?
    
    override init() {
        persistentContainer = NSPersistentContainer(name: "ToDoListModel")
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
        let task = NSEntityDescription.insertNewObject(forEntityName: "Task", into: persistentContainer.viewContext) as! Task
        
        task.taskName = taskName
        task.taskDesc = taskDesc
        task.taskDate = taskDate
        task.taskIsComplete = isComplete
        
        return task
    }
    
    func deleteTask(task: Task) {
        persistentContainer.viewContext.delete(task)
    }

    func fetchTask() -> [Task] {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        let nameSortDescriptor = NSSortDescriptor(key: "taskName", ascending: true)
        request.sortDescriptors = [nameSortDescriptor]
            if TaskFetchedResultsController == nil {

                TaskFetchedResultsController =
                NSFetchedResultsController<Task>(fetchRequest: request,
                                                      managedObjectContext: persistentContainer.viewContext,
                                                      sectionNameKeyPath: nil, cacheName: nil)
                // Set this class to be the results delegate
                TaskFetchedResultsController?.delegate = self

                do {
                    try TaskFetchedResultsController?.performFetch()
                } catch {
                    print("Fetch Request Failed: \(error)")
                }
            }
            if let task = TaskFetchedResultsController?.fetchedObjects {
                return task
            }
            return [Task]()
        }
}

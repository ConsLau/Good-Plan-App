//
//  CoreDataController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 24/4/2023.
//

import UIKit
import CoreData
import Firebase
import FirebaseAuth

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    var TaskFetchedResultsController: NSFetchedResultsController<Task>?
    var TaskFetchedResultsControllerUser: String = ""
    
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
    
    func addTask(taskName: String, taskDesc: String, taskDate: Date, isComplete: isComplete, userID: String) -> Task {
        let task = NSEntityDescription.insertNewObject(forEntityName: "Task", into: persistentContainer.viewContext) as! Task
        
        task.taskName = taskName
        task.taskDesc = taskDesc
        task.taskDate = taskDate
        task.taskIsComplete = isComplete
        // user
        task.userID = userID
        print("addTask \(userID)")

        
        return task
    }
    
    func deleteTask(task: Task) {
        persistentContainer.viewContext.delete(task)
    }
    
    func updateTask(task: Task) {
        let context = persistentContainer.viewContext
        
        do {
            try context.save()
        } catch {
            print("Failed to update task: \(error)")
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == .task {
                listener.onTaskChange(change: .update, tasks: fetchTask())
            }
        }
    }
    
    
    
    func fetchTask() -> [Task] {
        let request: NSFetchRequest<Task> = Task.fetchRequest()

        // user
//        // Fetch the current user's ID from Firebase
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is currently logged in.")
            return [Task]()
        }

        // Add a predicate to the fetch request to only fetch tasks with the same userID
        request.predicate = NSPredicate(format: "userID == %@", userID)
        print(userID)


        let nameSortDescriptor = NSSortDescriptor(key: "taskName", ascending: true)
        request.sortDescriptors = [nameSortDescriptor]
        
        TaskFetchedResultsControllerUser = Auth.auth().currentUser!.uid
//        if TaskFetchedResultsController == nil {
        if TaskFetchedResultsControllerUser == userID {

            TaskFetchedResultsController =
            NSFetchedResultsController<Task>(fetchRequest: request,
                                             managedObjectContext: persistentContainer.viewContext,
                                             sectionNameKeyPath: nil, cacheName: nil)
            // Set this class to be the results delegate
            TaskFetchedResultsController?.delegate = self

        }


//        do {
//            try TaskFetchedResultsController?.performFetch()
//        } catch {
//            print("Fetch Request Failed: \(error)")
//        }
//        if let task = TaskFetchedResultsController?.fetchedObjects {
//            return task
//        }

        do {
            try TaskFetchedResultsController?.performFetch()
            let tasks = TaskFetchedResultsController?.fetchedObjects ?? []
            for task in tasks {
                print("Fetched task with userID: \(task.userID)")
            }
            return tasks
        } catch {
            print("Fetch Request Failed: \(error)")
        }
        return [Task]()
        
    }
}

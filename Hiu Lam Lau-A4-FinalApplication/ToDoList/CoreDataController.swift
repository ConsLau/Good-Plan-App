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
                print("Fetched task with userID: \(String(describing: task.userID))")
            }
            return tasks
        } catch {
            print("Fetch Request Failed: \(error)")
        }
        return [Task]()
        
    }
    
    
    // progress check
    func calculateCompletionPercentageForTasks(userID: String) -> (daily: Float, weekly: Float, monthly: Float) {
        // Fetch the tasks
        let tasks = fetchTask()
        var dailyTasks = [Task]()
        var weeklyTasks = [Task]()
        var monthlyTasks = [Task]()
        
        // Get today's date
        let today = Date()
        
        // Create a calendar
        let calendar = Calendar.current
        
        for task in tasks {
            guard let taskDate = task.taskDate else {
                continue
            }
            
            // Get the date components for the task's date
            let taskDateComponents = calendar.dateComponents([.year, .month, .weekOfYear, .day], from: taskDate)
            
            // Get the date components for today's date
            let todayComponents = calendar.dateComponents([.year, .month, .weekOfYear, .day], from: today)
            
            // Compare the components
            if taskDateComponents.day == todayComponents.day && taskDateComponents.month == todayComponents.month && taskDateComponents.year == todayComponents.year {
                dailyTasks.append(task)
            }
            
            if taskDateComponents.weekOfYear == todayComponents.weekOfYear && taskDateComponents.year == todayComponents.year {
                weeklyTasks.append(task)
            }
            
            if taskDateComponents.month == todayComponents.month && taskDateComponents.year == todayComponents.year {
                monthlyTasks.append(task)
            }
        }
        
        // Calculate the completion percentages
        let dailyCompletion = completionPercentage(for: dailyTasks)
        let weeklyCompletion = completionPercentage(for: weeklyTasks)
        let monthlyCompletion = completionPercentage(for: monthlyTasks)
        
        return (dailyCompletion, weeklyCompletion, monthlyCompletion)
    }
    
    func completionPercentage(for tasks: [Task]) -> Float {
        let completedTasks = tasks.filter { $0.taskIsComplete == .complete }.count
        let totalTasks = tasks.count

        guard totalTasks > 0 else {
            return 0.0
        }

        return Float(completedTasks) / Float(totalTasks)
    }
    
    // bar
    func fetchCompletedTasksPerMonth() -> [Int] {
        // Get the current user's ID
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is currently logged in.")
            return [Int]()
        }
        
        // Fetch all tasks for the current user
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "userID == %@", userID)
        
        do {
            let fetchedTasks = try persistentContainer.viewContext.fetch(fetchRequest)
            var tasksPerMonth: [Int] = Array(repeating: 0, count: 12)
            let currentYear = Calendar.current.component(.year, from: Date())
            
            // Count the number of completed tasks per month
            for task in fetchedTasks {
                if task.taskIsComplete == .complete, let date = task.taskDate, Calendar.current.component(.year, from: date) == currentYear {
                    let monthIndex = Calendar.current.component(.month, from: date) - 1
                    tasksPerMonth[monthIndex] += 1
                }
            }
            
            return tasksPerMonth
        } catch {
            print("Fetch request failed: \(error)")
        }
        
        return [Int]()
    }

}


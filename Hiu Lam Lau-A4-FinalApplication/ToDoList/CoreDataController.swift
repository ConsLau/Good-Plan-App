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
    
    // Variable
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    var TaskFetchedResultsController: NSFetchedResultsController<Task>?
    //    var TaskFetchedResultsControllerUser: String = ""
    let DEFAULT_TASKCATE_NAME = "Default Task Category"
    var TaskCategoryFetchedResultsController: NSFetchedResultsController<Task>?
    
    override init() {
        persistentContainer = NSPersistentContainer(name: "ToDoListModel")
        persistentContainer.loadPersistentStores() { (description, error ) in
            if let error = error {
                fatalError("Failed to load Core Data Stack with error: \(error)")
            }
        }
        super.init()
    }
    
    // DatabaseProtocol
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
        
        if listener.listenerType == .taskCategory || listener.listenerType == .all {
            listener.onTaskCategoryChange(change: .update, taskCategory: fetchTaskCateTask())
        }
        
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func addTask(taskName: String, taskDesc: String, taskDate: Date, isComplete: isComplete, taskCategory: String) -> Task {
        let task = NSEntityDescription.insertNewObject(forEntityName: "Task", into: persistentContainer.viewContext) as! Task
        
        task.taskName = taskName
        task.taskDesc = taskDesc
        task.taskDate = taskDate
        task.taskIsComplete = isComplete
        
        assignCategoryToTask(task: task, taskCategory: taskCategory)
        
        return task
    }
    
    func assignCategoryToTask(task: Task, taskCategory: String) {
        let fetchRequest: NSFetchRequest<TaskCategory> = TaskCategory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "cateName == %@", taskCategory)
        
        do {
            let matchingCategories = try persistentContainer.viewContext.fetch(fetchRequest)
            if let existingCategory = matchingCategories.first {
                task.category = existingCategory
            } else {
                let newCategory = NSEntityDescription.insertNewObject(forEntityName: "TaskCategory", into: persistentContainer.viewContext) as! TaskCategory
                newCategory.cateName = taskCategory
                task.category = newCategory
            }
        } catch {
            print("Failed to fetch or create TaskCategory: \(error)")
        }
    }
    
    func fetchTasksAndNotifyListeners() {
        do {
            try TaskFetchedResultsController?.performFetch()
            let tasks = TaskFetchedResultsController?.fetchedObjects ?? []
            
            listeners.invoke { (listener) in
                if listener.listenerType == .task {
                    listener.onTaskChange(change: .update, tasks: tasks)
                }
            }
        } catch {
            print("Fetch Request Failed: \(error)")
        }
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
    
    lazy var defaultTaskCate: TaskCategory = {
        var taskCate = [TaskCategory]()
        let request: NSFetchRequest<TaskCategory> = TaskCategory.fetchRequest()
        let predicate = NSPredicate(format: "cateName = %@", DEFAULT_TASKCATE_NAME)
        request.predicate = predicate
        do {
            try taskCate = persistentContainer.viewContext.fetch(request)} catch {
                print("Fetch Request Failed: \(error)")
            }
        if let firstTaskCate = taskCate.first {
            return firstTaskCate
        }
        return addTaskCategory(cateName: DEFAULT_TASKCATE_NAME)
    }()
    
    func addTaskCategory(cateName: String) -> TaskCategory {
        let taskCate = NSEntityDescription.insertNewObject(forEntityName:
                                                            "TaskCategory", into: persistentContainer.viewContext) as! TaskCategory
        taskCate.cateName = cateName
        return taskCate
    }
    
    func updateTaskCategory(taskCategory: TaskCategory, newName: String) {
        let context = persistentContainer.viewContext
        taskCategory.cateName = newName
        
        do {
            try context.save()
        } catch {
            print("Failed to update task category: \(error)")
        }
        
        NotificationCenter.default.post(name: .taskCategoriesDidChange, object: nil)
    }
    
    func deleteTaskCategory(cateName: TaskCategory) {
        persistentContainer.viewContext.delete(cateName)
    }
    
    //    func addTaskToTaskCate(task: Task, taskCate: TaskCategory) -> Bool {
    //
    //    }
    
    func removeTaskFromTaskCate(task: Task, taskCate: TaskCategory) {
        taskCate.removeFromTasks(task)
    }
    
    
    // Other functions e.g. fetching function
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
            
        }
        
        
        //                do {
        //                    try TaskFetchedResultsController?.performFetch()
        //                } catch {
        //                    print("Fetch Request Failed: \(error)")
        //                }
        //                if let task = TaskFetchedResultsController?.fetchedObjects {
        //                    return task
        //                }
        
        do {
            try TaskFetchedResultsController?.performFetch()
            let tasks = TaskFetchedResultsController?.fetchedObjects ?? []
            
            return tasks
        } catch {
            print("Fetch Request Failed: \(error)")
        }
        return [Task]()
        
    }
    
    func calculateCompletionPercentageForTasks() -> (daily: Float, weekly: Float, monthly: Float) {
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
    
    // For bar chart
    func fetchCompletedTasksPerMonth() -> [Int] {
        
        
        // Fetch all tasks for the current user
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
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
    
    // updated the progress chart after task category is created.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == TaskFetchedResultsController {
            listeners.invoke { listener in
                if listener.listenerType == .task {
                    listener.onTaskChange(change: .update, tasks: fetchTask())
                }
            }
        }else if controller == TaskCategoryFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == .taskCategory || listener.listenerType == .all {
                    listener.onTaskCategoryChange(change: .update, taskCategory: fetchTaskCateTask())
                }
            }
        }
    }
    
    func fetchTaskCateTask() -> [Task] {
        if TaskCategoryFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "cateName", ascending: true)
            let predicate = NSPredicate(format: "ANY category.cateName == %@",
                                        DEFAULT_TASKCATE_NAME)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            fetchRequest.predicate = predicate
            TaskCategoryFetchedResultsController =
            NSFetchedResultsController<Task>(fetchRequest: fetchRequest,
                                             managedObjectContext: persistentContainer.viewContext,
                                             sectionNameKeyPath: nil, cacheName: nil)
            TaskCategoryFetchedResultsController?.delegate = self
            do {
                try TaskCategoryFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        var tasks = [Task]()
        if TaskCategoryFetchedResultsController?.fetchedObjects != nil {
            tasks = (TaskCategoryFetchedResultsController?.fetchedObjects)!
        }
        return tasks
    }
    
    
    // chart for category completion
    func fetchCompletedTasksForCategory(categoryName: String) -> Int {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        let predicateCategory = NSPredicate(format: "category.cateName == %@", categoryName)
        let predicateCompleted = NSPredicate(format: "isCompleted == %@", NSNumber(value: true))
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateCategory, predicateCompleted])
        
        fetchRequest.predicate = compoundPredicate
        
        do {
            let completedTasks = try persistentContainer.viewContext.fetch(fetchRequest)
            return completedTasks.count
        } catch {
            print("Fetch Request Failed: \(error)")
        }
        
        return 0
    }
    
    // progress chart
    func fetchAllTaskCategories() -> [TaskCategory] {
        var categories: [TaskCategory] = []
        let fetchRequest: NSFetchRequest<TaskCategory> = TaskCategory.fetchRequest()
        do {
            categories = try self.persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("Fetching TaskCategories failed: \(error)")
        }
        return categories
    }
    
    func calculateCompletionPercentageForCategory(_ category: TaskCategory) -> Double {
        // Fetch all tasks in the given category
        let tasksFetchRequest: NSFetchRequest<Task> = CoreDataController.fetchRequestForTasks(in: category)
        
        do {
            // Get the tasks in the given category
            let tasks = try self.persistentContainer.viewContext.fetch(tasksFetchRequest)
            
            // Calculate the completion percentage for the tasks in the given category
            let completedTasks = tasks.filter { $0.isComplete == 0 }.count
            let totalTasks = tasks.count
            
            guard totalTasks > 0 else {
                return 0.0
            }
            
            return Double(completedTasks) / Double(totalTasks)
        } catch {
            print("Fetching tasks failed: \(error)")
            return 0.0
        }
    }
    
}

extension CoreDataController {
    static func fetchRequestForTasks(in category: TaskCategory) -> NSFetchRequest<Task> {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(format: "ANY category.cateName == %@", category.cateName ?? "")
        request.sortDescriptors = [NSSortDescriptor(key: "taskDate", ascending: false)]
        return request
    }
}


extension Notification.Name {
    static let taskCategoryAdded = Notification.Name("TaskCategoryAdded")
}



//
//  DatabaseProtocol.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 24/4/2023.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType{
    case task
}

protocol DatabaseListener: AnyObject{
    var listenerType: ListenerType{get set}
    func onTaskChange(change: DatabaseChange, tasks: [Task])
}

protocol DatabaseProtocol: AnyObject{
    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func addTask(taskName: String, taskDesc:String, taskDate: Date, isComplete: isComplete)-> Task
    func deleteTask(task: Task)
    func updateTask(task: Task)
}

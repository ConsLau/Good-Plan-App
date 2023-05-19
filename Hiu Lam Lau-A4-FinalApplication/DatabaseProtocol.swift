//
//  DatabaseProtocol.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 24/4/2023.
//

import Foundation
import FirebaseAuth

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType{
    case task
    case blog
}

protocol DatabaseListener: AnyObject{
    var listenerType: ListenerType{get set}
    func onTaskChange(change: DatabaseChange, tasks: [Task])
    func onBlogChange(change: DatabaseChange, blogs: [Blog])
}

protocol DatabaseProtocol: AnyObject{
    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func addTask(taskName: String, taskDesc:String, taskDate: Date, isComplete: isComplete, userID: String)-> Task
    func deleteTask(task: Task)
    func updateTask(task: Task)
}

protocol DatabaseProtocolBlog: AnyObject{
    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func addBlog(blogTitle: String, blogContent:String, blogImage:String, isLocalImage: Bool, userID: String)-> Blog
    func deleteTask(blog: Blog)
    //func updateTask(blog: Blog)
}

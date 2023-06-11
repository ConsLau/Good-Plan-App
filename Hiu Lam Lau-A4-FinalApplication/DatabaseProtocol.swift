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
    case blog
    case taskCategory
    case record
    case recordCategory
    case all
}

protocol DatabaseListener: AnyObject{
    var listenerType: ListenerType{get set}
    func onTaskChange(change: DatabaseChange, tasks: [Task])
    func onBlogChange(change: DatabaseChange, blogs: [Blog])
    func onTaskCategoryChange(change: DatabaseChange, taskCategory: [Task])
    func onRecordChange(change: DatabaseChange, records: [Record])
    func onRecordCategoryChange(change: DatabaseChange, recordCategory: [Record])
}

protocol DatabaseProtocol: AnyObject{
    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func addTask(taskName: String, taskDesc:String, taskDate: Date, isComplete: isComplete, taskCategory: String)-> Task
    func deleteTask(task: Task)
    func updateTask(task: Task)
    
    // Task category
    var defaultTaskCate: TaskCategory {get}
    func addTaskCategory(cateName: String) -> TaskCategory
    func deleteTaskCategory(cateName: TaskCategory)
    func removeTaskFromTaskCate(task: Task, taskCate: TaskCategory)
}

protocol DatabaseProtocolBlog: AnyObject{
    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func addBlog(blogTitle: String, blogContent:String, blogImage:String, isLocalImage: Bool)-> Blog
    func deleteTask(blog: Blog)
}

protocol DatabaseProtocolRecord: AnyObject{
    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func addRecord(recordName: String, recordAmount:Int16, recordType: recordType, recordDate: Date, recordImage: String, categoryName: String)-> Record
    func deleteRecord(record: Record)
    func updateRecord(record: Record)
    
    var defaultRecordCate: RecordCategory {get}
    func addRecordCategory(cateNameR: String) -> RecordCategory
    func deleteRecordCategory(cateNameR: RecordCategory)
    func removeRecordFromRecordCate(record: Record, recordCate: RecordCategory)
}

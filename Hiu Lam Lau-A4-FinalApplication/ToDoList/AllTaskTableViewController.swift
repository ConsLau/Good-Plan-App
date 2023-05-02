//
//  AllTaskTableViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 25/4/2023.
//

import UIKit

class AllTaskTableViewController: UITableViewController, DatabaseListener {

    
    // variables
    var allTask: [Task] = []
    var listenerType = ListenerType.task
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func onTaskChange(change: DatabaseChange, tasks: [Task]) {
        allTask = tasks
        tableView.reloadData()
    }
    
//    func taskForDate(date: Date) -> [Task]{
//
//        var daysTask = [Task]()
//        for task in allTask{
//            if(Calendar.current.isDate(task.taskDate!, inSameDayAs: date)){
//                daysTask.append(task)
//            }
//        }
//
//        return daysTask
//    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allTask.count
//        return self.taskForDate(date: selectedDate).count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        var content = taskCell.defaultContentConfiguration()
        
        if indexPath.row < allTask.count {
            let task = allTask[indexPath.row]
            content.text = task.taskName
            content.secondaryText = task.taskDesc
        }
        taskCell.contentConfiguration = content
        
        return taskCell
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let task = allTask[indexPath.row]
            databaseController?.deleteTask(task: task)
        } else if editingStyle == .insert {
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

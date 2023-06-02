//
//  RemainderTableViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 30/5/2023.
//

import UIKit

class RemainderTableViewController: UITableViewController, DatabaseListener {

    

    //variables
    var allTask: [Task] = []
    var filteredTask: [Task] = []
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
        inCompleteTask()
        tableView.reloadData()
    }
    
    func onBlogChange(change: DatabaseChange, blogs: [Blog]) {
        
    }
    
    func onTaskCategoryChange(change: DatabaseChange, taskCategory: [Task]) {
        
    }
    
    func onRecordCategoryChange(change: DatabaseChange, recordCategory: [Record]) {
        
    }
    
    func onRecordChange(change: DatabaseChange, records: [Record]) {
        
    }
    
    func inCompleteTask(){
        filteredTask = allTask.filter { task in
            return checkTaskComplete(taskCompletion: task.isComplete)
        }
        tableView.reloadData()
    }
    
    func checkTaskComplete(taskCompletion: Int32) -> Bool {
        return taskCompletion == isComplete.inComplete.rawValue
    }
    
    func updateResults(){
        
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTask.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        var content = taskCell.defaultContentConfiguration()
        
        if indexPath.row < filteredTask.count {
            let task = filteredTask[indexPath.row]
            content.text = task.taskName
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            content.secondaryText = task.taskDate != nil ? dateFormatter.string(from: task.taskDate!) : nil
        }
        
        taskCell.contentConfiguration = content
        taskCell.selectionStyle = .none
        
        return taskCell
    }

}

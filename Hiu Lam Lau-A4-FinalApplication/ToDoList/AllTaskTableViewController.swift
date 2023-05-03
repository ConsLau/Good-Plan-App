//
//  AllTaskTableViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 25/4/2023.
//

import UIKit

class AllTaskTableViewController: UITableViewController, DatabaseListener {
    
    var selectedDate: String?
    // variables
    var allTask: [Task] = []
    var filteredTask: [Task] = []
    var listenerType = ListenerType.task
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredTask = allTask
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        print(selectedDate)
        
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
        selecteDateResults()
        tableView.reloadData()
    }
    
    func selecteDateResults(){
        filteredTask = allTask.filter({(task: Task) -> Bool in
            return (dateConvert(date: task.taskDate!) == selectedDate)
        })
        
        tableView.reloadData()
    }
    
    func dateConvert(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter.string(from: date)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredTask.count
        //        return self.taskForDate(date: selectedDate).count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row < filteredTask.count {
            let task = filteredTask[indexPath.row]
            if task.taskIsComplete == .inComplete {
                cell.backgroundColor = UIColor.lightGray
            } else {
                cell.backgroundColor = UIColor.white
            }
        }
    }
    
    @objc func doubleTapGestureHandler(_ sender: UITapGestureRecognizer){
        let location = sender.location(in: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at: location) {
            print("Double tapped")
            
            let task = filteredTask[indexPath.row]
            
            if task.taskIsComplete == .complete {
                task.taskIsComplete = .inComplete
            } else {
                task.taskIsComplete = .complete
            }
            
            databaseController?.updateTask(task: task)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        var content = taskCell.defaultContentConfiguration()
        
        if indexPath.row < filteredTask.count {
            let task = filteredTask[indexPath.row]
            content.text = task.taskName
            content.secondaryText = task.taskDesc
            
        }
        taskCell.contentConfiguration = content
        taskCell.selectionStyle = .none
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapGestureHandler(_:)))
        gestureRecognizer.numberOfTapsRequired = 2
        taskCell.addGestureRecognizer(gestureRecognizer)
        
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
            let task = filteredTask[indexPath.row]
            databaseController?.deleteTask(task: task)
        } else if editingStyle == .insert {
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

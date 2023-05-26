//
//  AllTaskTableViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 25/4/2023.
//
// Reference 1 (How can I add an image to my table cell in swift?): https://stackoverflow.com/questions/35531441/how-can-i-add-an-image-to-my-table-cell-in-swift
// Reference 2(Swift: Double Tap to like Feature (Xcode 11, 2020) - iOS Development): https://www.youtube.com/watch?v=4XKZPdp-0TA&t=180s

import UIKit

class AllTaskTableViewController: UITableViewController, DatabaseListener {

    

    // variables
    var selectedDate: String?
    var selectedMonth: String?
    var allTask: [Task] = []
    var filteredTask: [Task] = []
    var listenerType = ListenerType.task
    weak var databaseController: DatabaseProtocol?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredTask = allTask
        
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
        filteredTask = allTask
        selecteDateResults()
        tableView.reloadData()
    }
    
    func onBlogChange(change: DatabaseChange, blogs: [Blog]) {
        
    }
    
    func onTaskCategoryChange(change: DatabaseChange, taskCategory: [Task]) {
        
    }
    
    func selecteDateResults(){
        guard let selectedDate = selectedDate, let selectedMonth = selectedMonth else {
            let calendar = Calendar.current
            let today = Date()
            selectedDate = "\(calendar.component(.day, from: today))"
            selectedMonth = "\(calendar.component(.month, from: today))"
            selecteDateResults()
            return
        }
        print( selectedDate, selectedMonth)
        filteredTask = allTask.filter({(task: Task) -> Bool in
            return checkDateMonth(selectedDay: selectedDate, selectedMonth: selectedMonth, taskDate: task.taskDate!)
        })
//        filteredTask = allTask.filter({(task: Task) -> Bool in
//                if let taskDate = task.taskDate {
//                    return checkDateMonth(selectedDay: selectedDate, selectedMonth: selectedMonth, taskDate: taskDate)
//                }
//                return false
//            })
        
        tableView.reloadData()
    }
    
    func checkDateMonth(selectedDay: String, selectedMonth: String, taskDate: Date) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        let day = dateFormatter.string(from: taskDate)

        dateFormatter.dateFormat = "MMMM"
        let month = dateFormatter.string(from: taskDate)

        return selectedDay == day && selectedMonth == month
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredTask.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row < filteredTask.count {
            let task = filteredTask[indexPath.row]
            if task.taskIsComplete == .inComplete {
                cell.imageView?.image = UIImage(named:"Uncheck")
            } else {
                cell.imageView?.image = UIImage(named:"Checked")
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
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
//        let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
//        var content = taskCell.defaultContentConfiguration()
//
//        if indexPath.row < filteredTask.count {
//            let task = filteredTask[indexPath.row]
//            content.text = task.taskName
//            content.secondaryText = task.taskDesc
//
//            if task.taskIsComplete == .complete {
//                content.image = UIImage(named:"Checked")
//            } else {
//                content.image = UIImage(named:"Uncheck")
//            }
//        }
//
//        taskCell.contentConfiguration = content
//        taskCell.selectionStyle = .none
//
//        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapGestureHandler(_:)))
//        gestureRecognizer.numberOfTapsRequired = 1
//        taskCell.addGestureRecognizer(gestureRecognizer)
//
//        return taskCell
        
        // Configure the cell...
            let taskCell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
            var content = taskCell.defaultContentConfiguration()
            
            if indexPath.row < filteredTask.count {
                let task = filteredTask[indexPath.row]
                content.text = task.taskName
                content.secondaryText = task.category?.cateName ?? "Default Category"
                
                if task.taskIsComplete == .complete {
                    content.image = UIImage(named:"Checked")
                } else {
                    content.image = UIImage(named:"Uncheck")
                }
            }
            
            taskCell.contentConfiguration = content
            taskCell.selectionStyle = .none
            
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapGestureHandler(_:)))
            gestureRecognizer.numberOfTapsRequired = 1
            taskCell.addGestureRecognizer(gestureRecognizer)
            
            return taskCell
        
        
    }
    
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            let task = filteredTask[indexPath.row]
//            databaseController?.deleteTask(task: task)
//        } else if editingStyle == .insert {
//
//        }
//    }
    
    // new table view
    func updateSelectedDate(selectedDay: String, selectedMonth: String) {
        self.selectedDate = selectedDay
        self.selectedMonth = selectedMonth
        self.selecteDateResults()
    }
    
    // show details pop up message
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            let task = self.filteredTask[indexPath.row]
            self.databaseController?.deleteTask(task: task)
            completion(true)
        }
        
        // Details action
        let detailsAction = UIContextualAction(style: .normal, title: "Details") { (action, view, completion) in
            let task = self.filteredTask[indexPath.row]
            self.showTaskDetails(task: task)
            completion(true)
        }
        detailsAction.backgroundColor = .darkGray
        
        return UISwipeActionsConfiguration(actions: [deleteAction, detailsAction])
    }
    
    func showTaskDetails(task: Task) {
        let message = "Task Name: \(task.taskName ?? "")\nTask Description: \(task.taskDesc ?? "")\nTask Category: \(task.category?.cateName ?? "")\nTask Due Date: \(task.taskDate ?? Date())\nTask Status: \(task.taskIsComplete == .complete ? "Completed" : "Incomplete")"

        let alertController = UIAlertController(title: "Task Details", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)

        self.present(alertController, animated: true, completion: nil)
    }

}

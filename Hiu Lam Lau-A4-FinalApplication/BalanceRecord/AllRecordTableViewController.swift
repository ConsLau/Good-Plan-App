//
//  AllRecordTableViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 1/6/2023.
//

import UIKit

class AllRecordTableViewController: UITableViewController, DatabaseListener {
    
    
    
    // variable
    var selectedDate: String?
    var selectedMonth: String?
    var allRecord: [Record] = []
    var filteredRecord: [Record] = []
    var listenerType = ListenerType.record
    weak var recordDatabaseController: DatabaseProtocolRecord?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredRecord = allRecord
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        recordDatabaseController = appDelegate?.recordDatabaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recordDatabaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        recordDatabaseController?.removeListener(listener: self)
    }
    
    func onTaskChange(change: DatabaseChange, tasks: [Task]) {
        
    }
    
    func onBlogChange(change: DatabaseChange, blogs: [Blog]) {
        
    }
    
    func onTaskCategoryChange(change: DatabaseChange, taskCategory: [Task]) {
        
    }
    
    func onRecordChange(change: DatabaseChange, records: [Record]) {
        allRecord = records
        tableView.reloadData()
    }
    
    func onRecordCategoryChange(change: DatabaseChange, recordCategory: [Record]) {
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allRecord.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let recordCell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath)
        var content = recordCell.defaultContentConfiguration()

        if indexPath.row < allRecord.count {
            let sortedRecords = allRecord.sorted(by: { $0.recordDate ?? Date() > $1.recordDate ?? Date() }) // Sort the records by date in descending order
            let record = sortedRecords[indexPath.row]
            
            content.text = record.recordName
            content.secondaryText = "Amount: \(record.recordAmount) - \(formattedDate(from: record.recordDate!))"

            switch record.recRecordType {
            case .income:
                let image = UIImage(systemName: "plus.circle.fill")
                content.image = image?.withTintColor(UIColor(named: "greenAssets") ?? UIColor.black, renderingMode: .alwaysOriginal)
            case .expenditure:
                let image = UIImage(systemName: "minus.circle.fill")
                content.image = image?.withTintColor(UIColor(named: "pinkAssets") ?? UIColor.black, renderingMode: .alwaysOriginal)
            }
        }

        recordCell.contentConfiguration = content
        recordCell.selectionStyle = .none

        return recordCell
    }


    func formattedDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: date)
    }
  
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // show details pop up message
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            let record = self.allRecord[indexPath.row]
            self.recordDatabaseController?.deleteRecord(record: record)
            completion(true)
        }
        
        // Details action
//        let detailsAction = UIContextualAction(style: .normal, title: "Details") { (action, view, completion) in
//            let record = self.filteredRecord[indexPath.row]
//            self.showTaskDetails(record: record)
//            completion(true)
//        }
//        detailsAction.backgroundColor = .darkGray
//
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // other functions
    
    

    
//    func showTaskDetails(record: Record) {
//        let message = "Record Name: \(record.recordName ?? "")\nRecord Description: \(record.recordDesc ?? "")\nRecord Category: \(record.categoryR?.cateNameR ?? "")\nRecord Due Date: \(record.recordDate ?? Date())"
//
//        let alertController = UIAlertController(title: "Record Details", message: message, preferredStyle: .alert)
//
//        if let base64String = record.recordImage,
//               let imageData = Data(base64Encoded: base64String),
//               let image = UIImage(data: imageData) {
//
//                let imageView = UIImageView(frame: CGRect(x: 10, y: 70, width: 250, height: 150))
//                imageView.image = image
//                imageView.contentMode = .scaleAspectFit
//                alertController.view.addSubview(imageView)
//            }
//
//        let okAction = UIAlertAction(title: "OK", style: .default)
//        alertController.addAction(okAction)
//
//        self.present(alertController, animated: true, completion: nil)
//    }

}

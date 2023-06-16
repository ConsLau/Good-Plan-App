//
//  ToDoListTableViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 23/4/2023.
//

import UIKit

class ToDoListTableViewController: UITableViewController {
    
    let TaskCell = "TaskCell"

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell, for: indexPath)

        // Configure the cell...
        cell.contentView.backgroundColor = UIColor(red: 0/255.0, green: 255/255.0, blue: 187/255.0, alpha: 1.0)

        return cell
    }
    

}

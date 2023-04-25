//
//  CreateTaskViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 24/4/2023.
//

import UIKit
import CoreData

class CreateTaskViewController: UIViewController {

    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var isCompleteSegmentedControl: UISegmentedControl!

    weak var databaseController: DatabaseProtocol?
    var selectedDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    @IBAction func datePicker(_ sender: UIDatePicker) {
            selectedDate = sender.date
    }
    
    
    @IBAction func confirmBtn(_ sender: Any) {
        self.createTask()
        
    }
    
    func createTask() {
        guard let taskName = nameTextField.text,
              let taskDesc = descTextField.text,
              let isComplete = isComplete(rawValue: Int32(isCompleteSegmentedControl.selectedSegmentIndex)),
              let taskDate = selectedDate
        else {
            return
        }
        
        let _ = databaseController?.addTask(taskName: taskName, taskDesc: taskDesc, taskDate: taskDate, isComplete: isComplete)
        
        navigationController?.popViewController(animated: true)
    }

}

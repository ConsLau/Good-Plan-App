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

    @IBOutlet weak var confirmBtn: UIButton!
    
    weak var databaseController: DatabaseProtocol?
    var selectedDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        confirmBtn.tintColor = UIColor.darkGray
        
    }
    
    @IBAction func datePicker(_ sender: UIDatePicker) {
            selectedDate = sender.date
    }
    
    @IBAction func confirmBtn(_ sender: Any) {
        guard let taskName = nameTextField.text,
                      let taskDesc = descTextField.text,
                      let taskDate = selectedDate
                else {
                    print("error")
                    return
                }
                
        let isCompleteStatus = isComplete(rawValue: Int32(isCompleteSegmentedControl.selectedSegmentIndex)) ?? .inComplete
        
        let _ = databaseController?.addTask(taskName: taskName, taskDesc: taskDesc, taskDate: taskDate, isComplete: isCompleteStatus)
                print("task added")
                
                navigationController?.popViewController(animated: true)
    }
    

}

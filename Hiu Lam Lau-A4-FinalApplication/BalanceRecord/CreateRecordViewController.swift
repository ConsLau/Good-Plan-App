//
//  CreateRecordViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 1/6/2023.
//

import UIKit
import AVFoundation

class CreateRecordViewController: UIViewController, UINavigationControllerDelegate {

    
    @IBOutlet weak var recordName: UITextField!
    @IBOutlet weak var recordAmount: UITextField!
    @IBOutlet weak var recordCategory: UITextField!
    @IBOutlet weak var recordDate: UIDatePicker!
    @IBOutlet weak var recordType: UISegmentedControl!
    
    var selectedDate: Date?
    weak var recordDatabaseController: DatabaseProtocolRecord?
    var recordCategories: [RecordCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        recordDatabaseController = appDelegate?.recordDatabaseController
        
        
        // keyboard dismiss
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        self.navigationController?.navigationController?.isNavigationBarHidden = false
        
        // TextField boarder
        recordName.layer.borderWidth = 1.0
        recordName.layer.borderColor = UIColor.lightGray.cgColor
        recordName.layer.cornerRadius = 5.0
        
        // TextField boarder
        recordAmount.layer.borderWidth = 1.0
        recordAmount.layer.borderColor = UIColor.lightGray.cgColor
        recordAmount.layer.cornerRadius = 5.0
        
        // TextField boarder
        recordCategory.layer.borderWidth = 1.0
        recordCategory.layer.borderColor = UIColor.lightGray.cgColor
        recordCategory.layer.cornerRadius = 5.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.navigationController?.navigationController?.isNavigationBarHidden = true
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    @IBAction func datePicker(_ sender: Any) {
        selectedDate = (sender as AnyObject).date
    }
    
    
    @IBAction func confirmBtn(_ sender: Any) {
        var recordDate = selectedDate
        
        if recordDate == nil {
            recordDate = Date()
            displayMessage(message: "You didn't set the record date. It is now set to the current date.", completion: { [weak self] _ in
                self?.addRecord(recordDate: recordDate)
            })
            return
        }
        
        addRecord(recordDate: recordDate)
    }
    
    func addRecord(recordDate: Date?) {
        guard let recordName = recordName.text, !recordName.isEmpty,
              let recordAmount = recordAmount.text, !recordAmount.isEmpty,
              let recordCategoryName = recordCategory.text, !recordCategoryName.isEmpty,
              let finalRecordDate = recordDate
        else {
            displayMessage(message: "Please fill in all fields.")
            return
        }
        
        guard let recordAmountFloat = Float(recordAmount) else {
            displayMessage(message: "Invalid amount. Please enter a valid number.")
            return
        }
        
        let recordType = Good_Plan.recordType(rawValue: Int32(recordType.selectedSegmentIndex)) ?? .expenditure
        
        let _ = recordDatabaseController?.addRecord(recordName: recordName, recordAmount: recordAmountFloat, recordType: recordType, recordDate: finalRecordDate, categoryName: recordCategoryName)
        
        print("record added")
        dismiss(animated: true, completion: nil)
    }
    
    func formattedDate(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y HH:mm"
        return formatter.string(from: date)
    }
    
    func displayMessage(message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

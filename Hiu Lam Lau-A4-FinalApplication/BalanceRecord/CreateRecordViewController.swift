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
//    @IBOutlet weak var recordImage: UIImageView!
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
    
//    @IBAction func receiptImageBtn(_ sender: Any) {
//        let controller = UIImagePickerController()
//        controller.allowsEditing = false
//        controller.delegate = self
//        let actionSheet = UIAlertController(title: nil, message: "Select Option:",
//                                            preferredStyle: .actionSheet)
//
//        let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
//            if self.checkCameraAccess() {
//                controller.sourceType = .camera
//                self.present(controller, animated: true, completion: nil)
//            } else {
//                // Here, you might want to display an alert to the user explaining that camera access is needed.
//            }
//        }
//
//
//        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { action in
//            controller.sourceType = .photoLibrary
//            self.present(controller, animated: true, completion: nil)
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            actionSheet.addAction(cameraAction)
//        }
//        actionSheet.addAction(libraryAction)
//        actionSheet.addAction(cancelAction)
//        self.present(actionSheet, animated: true, completion: nil)
//    }
    
    
    @IBAction func confirmBtn(_ sender: Any) {
        guard let recordName = recordName.text, !recordName.isEmpty,
              let recordAmount = recordAmount.text, !recordAmount.isEmpty,
              let recordDate = selectedDate,
              let recordCategoryName = recordCategory.text, !recordCategoryName.isEmpty
//              let recordImage = recordImage.image
        else {
            displayMessage(message: "Please fill in all fields.")
            return
        }

            guard let recordAmountFloat = Float(recordAmount) else {
//                showAlert(title: "Error", message: "Invalid amount. Please enter a valid number.")
                return
            }
                
            // recordType
            let recordType = Good_Plan.recordType(rawValue: Int32(recordType.selectedSegmentIndex)) ?? .expenditure
            
                
                let _ = recordDatabaseController?.addRecord(recordName: recordName, recordAmount: recordAmountFloat, recordType: recordType,recordDate: recordDate, categoryName: recordCategoryName)
                
                print("record added")
//                navigationController?.popViewController(animated: true)
                dismiss(animated: true, completion: nil)
            }
    
        
    
    func formattedDate(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM y HH:mm"
        return formatter.string(from: date)
    }
    
    func displayMessage(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
        

}

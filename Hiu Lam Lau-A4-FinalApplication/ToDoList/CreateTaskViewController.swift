//
//  CreateTaskViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 24/4/2023.
//
// Reference 1 Schedule Local Notifications Swift Xcode Tutorial: https://www.youtube.com/watch?v=qDbbdvTYpVI
// Reference 2 Local notification: https://developer.apple.com/documentation/usernotifications

import UIKit
import CoreData
import UserNotifications

class CreateTaskViewController: UIViewController {
    
    // UI elements
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var isCompleteSegmentedControl: UISegmentedControl!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var confirmBtn: UIButton!
    
    // Variable
    let notificationCentre = UNUserNotificationCenter.current()
    weak var databaseController: DatabaseProtocol?
    var selectedDate: Date?
    var taskCategories: [TaskCategory] = []// Task categories data source
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        notificationCentre.requestAuthorization(options: [.alert, .sound]) { (permissionGranted, error) in
            if(!permissionGranted){
                print("Denied!!!!!")
            }
            
        }
        
        //self.navigationController?.navigationController?.isNavigationBarHidden = false
        
        // keyboard dismiss
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        // TextField boarder
        nameTextField.layer.borderWidth = 1.0
        nameTextField.layer.borderColor = UIColor.lightGray.cgColor
        nameTextField.layer.cornerRadius = 5.0
        
        // TextField boarder
        descTextField.layer.borderWidth = 1.0
        descTextField.layer.borderColor = UIColor.lightGray.cgColor
        descTextField.layer.cornerRadius = 5.0
        
        // TextField boarder
        categoryTextField.layer.borderWidth = 1.0
        categoryTextField.layer.borderColor = UIColor.lightGray.cgColor
        categoryTextField.layer.cornerRadius = 5.0
        
        isCompleteSegmentedControl.selectedSegmentIndex = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar of the initial navigation controller
        //self.navigationController?.navigationController?.isNavigationBarHidden = true
        
        isCompleteSegmentedControl.selectedSegmentIndex = 1
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func datePicker(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
    
    @IBAction func confirmBtn(_ sender: Any) {
        var taskDate = selectedDate
        
        if taskDate == nil {
            taskDate = Date()
            displayMessage(message: "You didn't set the task date. It is now set to the current date.", completion: { [weak self] _ in
                self?.addTask(taskDate: taskDate)
            })
            return
        }
        
        addTask(taskDate: taskDate)
        
    }
    
    func addTask(taskDate: Date?) {
        guard let taskName = nameTextField.text, !taskName.isEmpty,
              let taskDesc = descTextField.text, !taskDesc.isEmpty,
              let finalTaskDate = taskDate,
              let taskCategory = categoryTextField.text, !taskCategory.isEmpty
        else {
            displayMessage(message: "Please fill in all fields.")
            return
        }
        
        let isCompleteStatus = isComplete(rawValue: Int32(isCompleteSegmentedControl.selectedSegmentIndex)) ?? .inComplete
        
        let _ = databaseController?.addTask(taskName: taskName, taskDesc: taskDesc, taskDate: finalTaskDate, isComplete: isCompleteStatus, taskCategory: taskCategory)
        
        print("task added")
        
        // After the task is added, dismiss the view controller.
        dismiss(animated: true, completion: nil)
        
        // local notification
        notificationCentre.getNotificationSettings{ (settings) in
            
            DispatchQueue.main.async {
                let title = self.nameTextField.text!
                let message = self.descTextField.text!
                let date = self.datePicker.date
                
                if(settings.authorizationStatus == .authorized){
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = message
                    
                    let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    self.notificationCentre.add(request) { (error) in
                        if(error != nil){
                            print("Error" + error.debugDescription)
                            return
                        }
                    }
                    
                    let ac = UIAlertController(title: "Notification Scheduled", message: "At " + self.formattedDate(date: date), preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: {(_) in }))
                    self.present(ac, animated: true)
                    
                }else{
                    let ac = UIAlertController(title: "Notification Scheduled", message: "To use notification feature, please enable notification in settings", preferredStyle: .alert)
                    let goToSettings = UIAlertAction(title: "Settings", style: .default){(_) in
                        guard let settingURL = URL(string: UIApplication.openSettingsURLString)
                        else{
                            return
                        }
                        
                        if(UIApplication.shared.canOpenURL(settingURL)){
                            UIApplication.shared.open(settingURL) {(_) in}
                        }
                    }
                    ac.addAction(goToSettings)
                    ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {(_) in }))
                    self.present(ac, animated: true)
                }
            }
            
        }
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

//
//  CreateTaskViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 24/4/2023.
//
// Reference 1 Schedule Local Notifications Swift Xcode Tutorial: https://www.youtube.com/watch?v=qDbbdvTYpVI

import UIKit
import CoreData
import UserNotifications

class CreateTaskViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var isCompleteSegmentedControl: UISegmentedControl!

    @IBOutlet weak var confirmBtn: UIButton!
    
    let notificationCentre = UNUserNotificationCenter.current()
    
    weak var databaseController: DatabaseProtocol?
    var selectedDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        confirmBtn.tintColor = UIColor.darkGray
        
        notificationCentre.requestAuthorization(options: [.alert, .sound]) { (permissionGranted, error) in
            if(!permissionGranted){
                print("Denied!!!!!")
            }
            
        }
        
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
    

}

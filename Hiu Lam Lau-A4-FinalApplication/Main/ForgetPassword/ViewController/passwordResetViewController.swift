//
//  passwordResetViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 7/4/2023.
//
// Reference 1: (Send a code for password reset via email - Swift + Firebase) https://stackoverflow.com/questions/53471664/send-a-code-for-password-reset-via-email-swift-firebase
// Reference 2: (iOS Swift: Firebase 008 - Reset Password) https://www.youtube.com/watch?v=ScRSPEqxaNs

import UIKit

class passwordResetViewController: UIViewController {
    
    
    // UI element
    @IBOutlet weak var emailnput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // keyboard dismiss
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
     
    @IBAction func continuteBtn(_ sender: Any) {
        // check if the input feild is empty or not
        guard let email = emailnput.text, !email.isEmpty else {
                    displayMessage(title: "Error", message: "Please enter a valid email address.")
                    return
                }
        
        Auth.auth().sendPasswordReset(withEmail: emailnput.text!) { (error) in
                    if let error = error {
                        self.displayMessage(title: "Error", message: error.localizedDescription)
                    } else {
                        self.displayMessage(title: "Success", message: "A password reset email has been sent to your email address.")
                    }
                }
        
    }
    
    func displayMessage(title: String, message: String ){
        let alertController = UIAlertController(title: title, message: message,
        preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
        handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }

}

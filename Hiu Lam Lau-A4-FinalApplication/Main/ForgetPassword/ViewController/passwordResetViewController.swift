//
//  passwordResetViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 7/4/2023.
//

import UIKit
import FirebaseAuth

class passwordResetViewController: UIViewController {

    
    @IBOutlet weak var emailnput: UITextField!
    
    
    
    @IBAction func continuteBtn(_ sender: Any) {
        guard let email = emailnput.text, !email.isEmpty else {
                    displayMessage(title: "Error", message: "Please enter a valid email address.")
                    return
                }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
                    if let error = error {
                        self.displayMessage(title: "Error", message: error.localizedDescription)
                    } else {
                        self.displayMessage(title: "Success", message: "A password reset email has been sent to your email address.")
                    }
                }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func displayMessage(title: String, message: String ){
        let alertController = UIAlertController(title: title, message: message,
        preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
        handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }

}

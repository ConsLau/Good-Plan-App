//
//  loginPageViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 7/4/2023.
//

import UIKit
import FirebaseAuth
import Firebase

class loginPageViewController: UIViewController {

    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    
    
    @IBAction func signinBtn(_ sender: Any) {
        //check if the input field is empty or not
        guard let email = emailInput.text, !email.isEmpty,
                      let password = passwordInput.text, !password.isEmpty else {
                    displayMessage(title: "Error", message: "Please enter email and password")
                    return
                }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            if let error = error {
                strongSelf.displayMessage(title: "Error", message: error.localizedDescription)
            } else {
                strongSelf.displayMessage(title: "Welcome", message: "Login successful")
                print("Logged in successfully")
                strongSelf.performSegue(withIdentifier: "homePage", sender: nil)
            }
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // return from logout page
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailInput.text = ""
        passwordInput.text = ""
    }
    
    
    func displayMessage(title: String, message: String ){
        let alertController = UIAlertController(title: title, message: message,
        preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
        handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }

}

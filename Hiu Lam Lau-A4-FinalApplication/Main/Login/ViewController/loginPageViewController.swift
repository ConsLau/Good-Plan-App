//
//  loginPageViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 7/4/2023.
//
// Reference 1: (Swift: Firebase Email/Password Log In & Authentication (Swift 5) Xcode 11 - 2023) https://www.youtube.com/watch?v=ife5YK-Keng&list=PL5PR3UyfTWvck0dxs18MiJiFp7r3oRAk-
// Reference 2: (Firebase SwiftUI Auth, Login, Registration, Password Reset, Sign Out - Bug Fix In Description) https://www.youtube.com/watch?v=5gIuYHn9nOc&t=2680s
// Reference 3: (View setting after return from logout page) OpenAI, ChatGPT, 13 Apr. 2023, https://chat.openai.com/
// Reference 4: (HOW TO ADD IMAGES TO IOS APP - Swift (2020)) https://www.youtube.com/watch?v=Tb9J08y5a4w
// Reference 5: (Password Authentication) https://firebase.google.com/docs/auth/ios/password-auth

import UIKit
import FirebaseAuth
import Firebase

class loginPageViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.isHidden =  true
        
    }
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    
    @IBAction func signinBtn(_ sender: Any) {
        
        //ActivityIndicatorView controll
        spinner.isHidden = false
        self.spinner.startAnimating()
        
        //check if the input field is empty or not
        guard let email = emailInput.text, !email.isEmpty,
                      let password = passwordInput.text, !password.isEmpty else {
                    displayMessage(title: "Error", message: "Please enter email and password")
                    return
                }
        
        //Firebase authentication with email and password
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            // withEmail: emailInput.text!
            
            if let error = error {
                strongSelf.displayMessage(title: "Error", message: error.localizedDescription, actionHandler: nil)
                strongSelf.spinner.stopAnimating()
            } else {
                strongSelf.displayMessage(title: "Welcome", message: "Login successful", actionHandler: { _ in
                    strongSelf.performSegue(withIdentifier: "homePage", sender: nil)
                })
                print("Logged in successfully")
                strongSelf.spinner.stopAnimating()
            }
        }
    }


    // Navigate from logout page
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailInput.text = ""
        passwordInput.text = ""
    }
    
    
    func displayMessage(title: String, message: String ,actionHandler: ((UIAlertAction) -> Void)? = nil){
        let alertController = UIAlertController(title: title, message: message,
        preferredStyle: .alert)

        let segueAction = UIAlertAction(title: "Dismiss", style: .default, handler: { actions in
            self.spinner.isHidden = true
            actionHandler?(actions)
        })
        
        alertController.addAction(segueAction)
        self.present(alertController, animated: true, completion: nil)
    }

}

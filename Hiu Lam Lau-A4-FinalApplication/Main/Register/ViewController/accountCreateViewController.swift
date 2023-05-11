//
//  accountCreateViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 7/4/2023.
//
// Reference 1: https://www.youtube.com/watch?v=ife5YK-Keng&list=PL5PR3UyfTWvck0dxs18MiJiFp7r3oRAk-
// Reference 2: (How To Add Spinner (Activity Indicator) to iOS App in Swift - 2020) https://www.youtube.com/watch?v=FIXU6d370K8
// Reference 6: (Password Authentication) https://firebase.google.com/docs/auth/ios/password-aut

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Firebase

class accountCreateViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.isHidden = true
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var emailCreate: UITextField!
    @IBOutlet weak var passwordCreate: UITextField!
    @IBOutlet weak var nameCreate: UITextField!
    @IBOutlet weak var occupationCreate: UITextField!
    
    
    @IBAction func createBtn(_ sender: Any) {
        spinner.isHidden = false
        self.spinner.startAnimating()
        // check if the input feild is empty or not
        guard let email = emailCreate.text, !email.isEmpty,
              let password = passwordCreate.text, !password.isEmpty,
              let name = nameCreate.text, !name.isEmpty,
              let occupation = occupationCreate.text, !occupation.isEmpty else{
            displayMessage(title: "Description is empty", message: "Please enter the information", actionHandler: nil)
            return
        }
        
        // [weak self] -> prevent memory leak, break the strogn reference cycle that allow us to free up the memory when it is not needed
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: {[weak self]result, error in
            
            // convert it back into string self, so that object can remain in the memory when it is needed by the functions/ closure
            guard let strongSelf = self else{
                return
            }

            guard error == nil else {
                // show ac creation
                strongSelf.accountCreate(name: name, occupation: occupation, email: email, password: password)
                return
            }
            
        })
    }

    // account create function
    func accountCreate(name: String, occupation: String, email: String, password: String){
        let alert = UIAlertController(title: "Confirmation", message: "Would you like to create an account", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {[weak self] result, error in
                guard let strongSelf = self else{
                    return
                }

                // check if user successfully create the account
                guard error == nil, let user = result?.user else {
                    print("Account creation failed")
                    strongSelf.spinner.stopAnimating()
                    strongSelf.displayMessage(title: "Error", message: "Please create a stronger passwords or valid email", actionHandler: nil)
                    return
                }
                
                // account information storge in Firebase with the user id
                let Firebasedb = Firestore.firestore()
                Firebasedb.collection("users").document(user.uid).setData([
                    "name": name,
                    "occupation": occupation,
                    "email": email
                ]) {error in
                    strongSelf.spinner.stopAnimating()
                    if let err = error {
                        print("Error adding document: \(err)")
                        
                    } else {
                        print("Document successfully added!")
                        strongSelf.displayMessage(title: "Welcome", message: "Account successfully created!",actionHandler: { _ in
                            strongSelf.performSegue(withIdentifier: "backToLogin", sender: nil)
                        })
                    }
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            self.spinner.stopAnimating()
        }))
        present(alert, animated: true)
    }

    func displayMessage(title: String, message: String, actionHandler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: .alert)
        
        // create the action handler for returning back to login page after clicking the dismiss button
        let segueAction = UIAlertAction(title: "Dismiss", style: .default, handler: { actions in
            self.spinner.isHidden = true
            actionHandler?(actions)
        })
        
        alertController.addAction(segueAction)
        self.present(alertController, animated: true, completion: nil)
    }

}

//
//  accountCreateViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 7/4/2023.
//
// Reference 1: https://www.youtube.com/watch?v=ife5YK-Keng&list=PL5PR3UyfTWvck0dxs18MiJiFp7r3oRAk-

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Firebase

class accountCreateViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var emailCreate: UITextField!
    @IBOutlet weak var passwordCreate: UITextField!
    @IBOutlet weak var nameCreate: UITextField!
    @IBOutlet weak var occupationCreate: UITextField!
    
    @IBAction func createBtn(_ sender: Any) {
        
        // check if the input feild is empty or not
        guard let email = emailCreate.text, !email.isEmpty,
              let password = passwordCreate.text, !password.isEmpty,
              let name = nameCreate.text, !name.isEmpty,
              let occupation = occupationCreate.text, !occupation.isEmpty else{
            displayMessage(title: "Description is empty", message: "Please enter the information")
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
                strongSelf.showCreateAccount(name: name, occupation: occupation, email: email, password: password)
                return
            }
            
        })
    }

    // account create function
    func showCreateAccount(name: String, occupation: String, email: String, password: String){
        let alert = UIAlertController(title: "Confirmation", message: "Would you like to create an account", preferredStyle: .alert)
        
       
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {_ in
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {[weak self] result, error in
                guard let strongSelf = self else{
                    return
                }
                
                // check if user successfully create the account
                guard error == nil, let user = result?.user else {
                    print("Account creation failed")
                    strongSelf.displayMessage(title: "Error", message: "Please create a stronger passwords or valid email")
                    return
                }

                // account information storge in Firebase with the user id
                let db = Firestore.firestore()
                                db.collection("users").document(user.uid).setData([
                                    "name": name,
                                    "occupation": occupation,
                                    "email": email
                                ]) { [self] err in
                                    if let err = err {
                                        print("Error adding document: \(err)")

                                    } else {
                                        print("Document successfully added!")
                                        strongSelf.displayMessage(title: "Welcome", message: "Account successfully created!")
                                    }
                                }
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in}))
        present(alert, animated: true)
        
    }
    

    func displayMessage(title: String, message: String ){
        let alertController = UIAlertController(title: title, message: message,
        preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
        handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }

}

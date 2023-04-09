//
//  accountCreateViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 7/4/2023.
//

import UIKit
import FirebaseAuth

class accountCreateViewController: UIViewController {

    

    @IBOutlet weak var emailCreate: UITextField!
    @IBOutlet weak var passwordCreate: UITextField!
    
    
    @IBAction func createBtn(_ sender: Any) {
        guard let email = emailCreate.text, !email.isEmpty,
              let password = passwordCreate.text, !password.isEmpty else{
            displayMessage(title: "Description is empty", message: "Please enter the information")
            return
        }
        
        //Get auth instance
        // attemp sign in
        // if failure, present alert to creat ac
        // if user continute, create ac
        
        // check sign in on app lunch
        // allow user to sign out
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: {[weak self]result, error in
            guard let strongSelf = self else{
                return
            }
            
            guard error == nil else {
                // show ac creation
                strongSelf.showCreateAccount(email: email, password: password)
                return
            }
            

            strongSelf.emailCreate.isHidden = true
            strongSelf.passwordCreate.isHidden = true

        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func showCreateAccount(email: String, password: String){
        let alert = UIAlertController(title: "Create Account", message: "Would you like to create an account", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continute", style: .default, handler: {_ in
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {[weak self] result, error in
                guard let strongSelf = self else{
                    return
                }
                
                guard error == nil else {
                    // show ac creation
                    print("Account creation failed")
                    return
                }
                
                strongSelf.emailCreate.isHidden = true
                strongSelf.passwordCreate.isHidden = true
                //pass to home page
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

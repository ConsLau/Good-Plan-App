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
                // Login successful, perform any action or segue to the next screen
                print("Logged in successfully")
                strongSelf.performSegue(withIdentifier: "homePage", sender: nil)
            }
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    func displayMessage(title: String, message: String ){
        let alertController = UIAlertController(title: title, message: message,
        preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
        handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
    

}

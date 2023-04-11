//
//  homePageViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 10/4/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import PhotosUI

class homePageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var occupationText: UILabel!
    @IBOutlet weak var emailText: UILabel!
    @IBOutlet weak var picView: UIImageView!
    
    
    
    @IBAction func logoutBtn(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            // Navigate back to the login screen
            self.navigationController?.popViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    
    @IBAction func picBtn(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.sourceType = .photoLibrary
                present(imagePickerController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fetchUserData()
    }
    

    func fetchUserData(){
        guard let user = Auth.auth().currentUser else {
            print("No user is signed in.")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let name = data?["name"] as? String ?? ""
                let occupation = data?["occupation"] as? String ?? ""
                let email = data?["email"] as? String ?? ""

                
                // Update UI with the fetched data
                DispatchQueue.main.async {
                    self.nameText.text = "\(name)"
                    self.occupationText.text = "\(occupation)"
                    self.emailText.text = "\(email)"

                }
            } else {
                print("Error fetching user data: \(error?.localizedDescription ?? "No user data found")")
            }
        }
    }
    
    // UIImagePickerControllerDelegate method
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                picView.image = selectedImage
            }
            dismiss(animated: true, completion: nil)
        }

}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */



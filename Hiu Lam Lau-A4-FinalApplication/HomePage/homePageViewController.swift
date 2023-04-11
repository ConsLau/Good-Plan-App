//
//  homePageViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 10/4/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestoreSwift
import Firebase
import FirebaseFirestore
import PhotosUI
import FirebaseStorage


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
        fetchUserImage()
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
    
    func fetchUserImage() {
        guard let user = Auth.auth().currentUser else {
            print("No user is signed in.")
            return
        }
        
        let storageRef = Storage.storage().reference()
        let imagePath = "user_images/\(user.uid)/profile_image.jpg"
        
        storageRef.child(imagePath).getData(maxSize: 10 * 1024 * 1024) { (data, error) in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
            } else {
                if let imageData = data, let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.picView.image = image
                    }
                } else {
                    print("Error converting data to UIImage.")
                }
            }
        }
    }
    
    // UIImagePickerControllerDelegate method
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    picView.image = selectedImage
                    uploadImageToFirebase(image: selectedImage)
                }
                dismiss(animated: true, completion: nil)
        }
    
    
    func uploadImageToFirebase(image: UIImage) {
        guard let user = Auth.auth().currentUser else {
            print("No user is signed in.")
            return
        }

        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("Could not convert image to data.")
            return
        }

        let storageRef = Storage.storage().reference()
        let imagePath = "user_images/\(user.uid)/profile_image.jpg"

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        storageRef.child(imagePath).putData(imageData, metadata: metadata) { (metadata, error) in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
            } else {
                print("Image uploaded successfully.")
            }
        }
    }

}




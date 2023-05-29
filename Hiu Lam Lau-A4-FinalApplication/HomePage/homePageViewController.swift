//
//  homePageViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 10/4/2023.
//
// Reference 1: (Toolbar creation) https://www.youtube.com/watch?v=EFcMNSP0K9w
// Reference 2: (Firebase Storage - How To Upload & Download Images To Firebase Storage (Swift Xcode Tutorial)) https://www.youtube.com/watch?v=_Z53zF2R6r0
// Rference 3: (Swift: Upload Photos to Firebase Storage (and Download, Swift 5) - Xcode 11 - 2020) https://www.youtube.com/watch?v=TAF6cPZxmmI

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
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var titleText: UILabel!
    
    @IBOutlet weak var logoutBtn: UIButton! 
    @IBOutlet weak var picUploadBtn: UIButton!
    
    

    
    @IBAction func logoutBtn(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            // Navigate to the login screen
            self.navigationController?.popViewController(animated: true)
            
            // root view controller
            if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                        sceneDelegate.switchRootViewController(identifier: "NavController")
                    }
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    
    @IBAction func picUploadBtn(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.sourceType = .photoLibrary
                present(imagePickerController, animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pullUserImage()
        fetchUserData()
        
    }

    

    func fetchUserData(){
        guard let user = Auth.auth().currentUser else {
            print("No user is signed in.")
            return
        }
        
        let fireBase = Firestore.firestore()
        let userData = fireBase.collection("users").document(user.uid)
        
        // fetch data from firebase
        userData.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let name = data?["name"] as? String ?? ""
                let occupation = data?["occupation"] as? String ?? ""
                let email = data?["email"] as? String ?? ""

                
                // Update UI view with the fetched data
                DispatchQueue.main.async {
                    self.nameText.text = "\(name)"
                    self.occupationText.text = "\(occupation)"
                    self.emailText.text = "\(email)"
                    self.titleText.text = "Welcome back, \(name) !"

                }
            } else {
                print("Error fetching user data: \(error?.localizedDescription ?? "No user data found")")
            }
        }
    }

    
    func pullUserImage() {
        // check user sign in
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
                        self.imageView.image = image
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
            imageView.image = selectedImage
            pushImageToFirebase(image: selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    func pushImageToFirebase(image: UIImage) {
        // check user sign in
        guard let user = Auth.auth().currentUser else {
            print("No user is signed in.")
            return
        }

        // check image compression
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            print("Could not convert image to data.")
            return
        }

        let storageRef = Storage.storage().reference()

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        storageRef.child("user_images/\(user.uid)/profile_image.jpg").putData(imageData, metadata: metadata) { (metadata, error) in
            
            guard error == nil else {
                print("Error uploading image: \(error!.localizedDescription)")
                self.displayMessage(title: "Error", message: "Error uploading image: \(error!.localizedDescription)")
                return
            }
            
            print("Image uploaded successfully.")
            self.displayMessage(title: "Image uploaded successfully", message: "")

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




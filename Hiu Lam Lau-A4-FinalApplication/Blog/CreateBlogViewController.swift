//
//  CreateBlogViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 5/5/2023.
//

import UIKit
import CoreData
import AVFoundation

protocol ImageSelectionDelegate: AnyObject {
    func didSelectImage(imageURL: URL)
}

class CreateBlogViewController: UIViewController, UIImagePickerControllerDelegate , ImageSelectionDelegate & UINavigationControllerDelegate {
    
    
    
    // variable
    
    @IBOutlet weak var titleInput: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    //@IBOutlet weak var contentInput: UITextField!
    
    @IBOutlet weak var contentInput: UITextView!
    
    var blogCoreDataController: BlogCoreDataController?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        blogCoreDataController = appDelegate?.blogDatabaseController as? BlogCoreDataController
        
        //Looks for single or multiple taps.
        // keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        view.addGestureRecognizer(tap)

        // TextField boarder
        titleInput.layer.borderWidth = 1.0
        titleInput.layer.borderColor = UIColor.lightGray.cgColor
        titleInput.layer.cornerRadius = 5.0
        
        // TextView boarder
        contentInput.layer.borderWidth = 1.0
        contentInput.layer.borderColor = UIColor.lightGray.cgColor
        contentInput.layer.cornerRadius = 5.0
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    @IBAction func addImageBtn(_ sender: Any) {
        let controller = UIImagePickerController()
        controller.allowsEditing = false
        controller.delegate = self
        let actionSheet = UIAlertController(title: nil, message: "Select Option:",
                                            preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
            if self.checkCameraAccess() {
                controller.sourceType = .camera
                self.present(controller, animated: true, completion: nil)
            } else {

            }
        }
        
        
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { action in
            controller.sourceType = .photoLibrary
            self.present(controller, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
        actionSheet.addAction(cameraAction)
        }
        actionSheet.addAction(libraryAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    @IBAction func addBlogBtn(_ sender: Any) {
        guard let blogTitle = titleInput.text, !blogTitle.isEmpty,
              let blogContent = contentInput.text, !blogContent.isEmpty,
              let blogImage = imageView.image
        else {
            displayMessage(message: "Please fill in all fields.")
            

                return
            }
            
            // Save the image to documents directory and get the file path
            let imageName = UUID().uuidString + ".jpg"
            if let data = blogImage.jpegData(compressionQuality: 1.0),
               let fileURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(imageName) {
                do {
                    try data.write(to: fileURL)
                    
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        print("File exists at \(fileURL.path)")
                    } else {
                        print("File does not exist")
                    }
                }
                catch {
                    print(error)
                }
                // Save blog details to Core Data
                let isLocalImage = imageView.tag == 1
                let _ = blogCoreDataController?.addBlog(blogTitle: blogTitle, blogContent: blogContent, blogImage: fileURL.absoluteString, isLocalImage: isLocalImage)
                //blogCoreDataController?.cleanup()
                print("Add successfully")
                print(blogImage)
                
//                navigationController?.popViewController(animated: true)
                dismiss(animated: true, completion: nil)
            }
        }

    func checkCameraAccess() -> Bool {
        var hasAccess = false
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            hasAccess = true

        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted { hasAccess = true }
            }

        case .denied: // The user has previously denied access.
            return false

        case .restricted: // The user can't grant access due to restrictions.
            return false
        @unknown default:
            return false
        }
        return hasAccess
    }

    func didSelectImage(imageURL: URL) {
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.imageView.image = image
                self.imageView.tag = 0
            }
        }.resume()
    }
    
    func saveImage(_ image: UIImage){
        let imageName = UUID().uuidString + ".jpg"
        if let imageData = image.jpegData(compressionQuality: 1.0),
           let imageURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(imageName) {
            try? imageData.write(to: imageURL)
            imageView.image = image
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage{
            imageView.image = image
            imageView.tag = 1
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func displayMessage(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

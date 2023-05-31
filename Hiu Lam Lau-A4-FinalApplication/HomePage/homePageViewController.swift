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
import SwiftUI


class homePageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // UI elements
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleText.text = "Welcome back!"
        
        // Create the SwiftUI view that provides the window contents.
                let swiftUIView = homePageProgressCheck()

                // Use a UIHostingController to wrap it.
                let hostingController = UIHostingController(rootView: swiftUIView)

                // Add as a child of the current view controller.
                addChild(hostingController)

                // Add the SwiftUI view to the view controller view hierarchy.
                containerView.addSubview(hostingController.view)

                // Setup layout constraints.
                hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    hostingController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                    hostingController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                    hostingController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
                    hostingController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
                ])

                // Notify the child view controller it has been moved to the parent.
                hostingController.didMove(toParent: self)
        
    }

    
}




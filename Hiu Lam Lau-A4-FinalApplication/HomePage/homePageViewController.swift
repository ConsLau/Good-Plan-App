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
    @IBOutlet weak var dateText: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var coreDataController: RecordCoreDataController!
    var records: [Record] = []
    var incomeSum: Int16 = 0
    var expenditureSum: Int16 = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let currentDate = Date()
        // Create a date formatter
        let dateFormatter = DateFormatter()

        // Set the date format
        dateFormatter.dateStyle = .long

        // Convert the date to a string
        let dateString = dateFormatter.string(from: currentDate)

        // Set the dateText to the current date
        self.dateText.text = dateString
        self.titleText.text = "Good Plan"
        titleText.textColor = UIColor.tintColor

        // Initialize the coreDataController
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let container = appDelegate.persistentContainer
            coreDataController = RecordCoreDataController(container: container)
        } else {
            fatalError("Unable to access AppDelegate.")
        }
        
        // Fetch all records
        records = coreDataController.fetchRecord()
        
        // Create the SwiftUI view that provides the window contents.
        let swiftUIView = homePageProgressCheck()
        
        // Use a UIHostingController to wrap it.
        let hostingController = UIHostingController(rootView: swiftUIView.environmentObject(coreDataController))
        
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
        
        self.navigationController?.isNavigationBarHidden = false
    }


        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            self.navigationController?.isNavigationBarHidden = true
            
            
            // Get the current date
            let currentDate = Date()
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month], from: currentDate)
            var incomeSum: Int16 = 0
            var expenditureSum: Int16 = 0
            
            // Get the income and expenditure for the current month
                if let month = components.month, let year = components.year {
                    let monthlyCalculations = coreDataController.calculateMonthlyIncomeAndExpenditure(forMonth: month, forYear: year)
                    incomeSum = monthlyCalculations.income
                    expenditureSum = monthlyCalculations.expenditure
                }
                
                // Update the segmented control
                setupSegmentedControl(income: incomeSum, expenditure: expenditureSum)
        }
    
    func setupSegmentedControl(income: Int16, expenditure: Int16) {
        segmentedControl.setTitle("Income: \(income)", forSegmentAt: 0)
        segmentedControl.setTitle("Expenditure: \(expenditure)", forSegmentAt: 1)
        
        let selectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.tintColor]
        segmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
    }
}

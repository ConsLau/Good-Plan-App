//
//  FinancesViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 2/6/2023.
//

import UIKit

class FinancesViewController: UIViewController{
    
    @IBOutlet weak var totalAmountText: UILabel!
    @IBOutlet weak var highestCategoryExpenText: UILabel!
    @IBOutlet weak var highestCategoryInText: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    var coreDataController: RecordCoreDataController!
    
    //animation
    var displayLink: CADisplayLink?
    var currentAmount: Int = 0
    var totalAmount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let container = appDelegate.persistentContainer
            coreDataController = RecordCoreDataController(container: container)
            
            
            
        } else {
            fatalError("Unable to access AppDelegate.")
        }
        
        //animation
        totalAmountText.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        totalAmountText.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let records = coreDataController.fetchRecord()
        var totalIncome: Int16 = 0
        var totalExpenditure: Int16 = 0
        
        for record in records {
            if record.recRecordType == .income {
                totalIncome += record.recordAmount
            } else if record.recRecordType == .expenditure {
                totalExpenditure += record.recordAmount
            }
        }
        
        totalAmount = Int(totalIncome) - Int(totalExpenditure)
        totalAmountText.text = "\(totalAmount)"
        
        let incomePercentages = coreDataController.calculatePercentages(for: .income)
        let expenditurePercentages = coreDataController.calculatePercentages(for: .expenditure)
        
        let highestIncomeCategoryPercentage = incomePercentages.max(by: {$0.value < $1.value})?.key
        let highestExpenditureCategoryPercentage = expenditurePercentages.max(by: {$0.value < $1.value})?.key
        
        highestCategoryInText.text = "Highest income category: \(highestIncomeCategoryPercentage ?? "None")"
        highestCategoryExpenText.text = "Highest expenditure category: \(highestExpenditureCategoryPercentage ?? "None")"
        
        if totalAmount >= 0 {
            totalAmountText.textColor = UIColor(named: "greenAssets")
        } else {
            totalAmountText.textColor = UIColor(named: "pinkAssets")
        }
        
        // Reset the current amount for animation
        currentAmount = 0
        
        //animation
        startUpdatingAmount()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Invalidate the display link to stop updates
        displayLink?.invalidate()
        displayLink = nil
    }

    
    func startUpdatingAmount() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateAmount))
        displayLink?.add(to: .current, forMode: .default)
    }
    
    @objc func updateAmount() {
        if currentAmount < totalAmount {
            currentAmount += 1
        } else if currentAmount > totalAmount {
            currentAmount -= 1
        } else {
            displayLink?.invalidate()
            displayLink = nil
        }
        totalAmountText.text = "\(currentAmount)"
    }
    
    @objc func handleTap() {
            displayLink?.isPaused = true
            totalAmountText.text = "\(totalAmount)"
        }
    
    
    
}

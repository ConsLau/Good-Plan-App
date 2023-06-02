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

    override func viewDidLoad() {
            super.viewDidLoad()

            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let container = appDelegate.persistentContainer
                coreDataController = RecordCoreDataController(container: container)

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

                let totalAmount = totalIncome - totalExpenditure
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

            } else {
                fatalError("Unable to access AppDelegate.")
            }
        }
}

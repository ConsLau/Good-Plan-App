//
//  RecordCoreDataController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 1/6/2023.
//

import UIKit
import CoreData
import Firebase
import FirebaseAuth
import SwiftUI

// fin
enum CalculationType: Int32 {
    case income = 0
    case expenditure = 1
}



class RecordCoreDataController: NSObject, DatabaseProtocolRecord, NSFetchedResultsControllerDelegate, ObservableObject{
    

    // variables
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    var RecordFetchedResultsController: NSFetchedResultsController<Record>?
    let DEFAULT_RECORDCATE_NAME = "Default Record Category"
    var RecordCategoryFetchedResultsController: NSFetchedResultsController<Record>?


    override init() {
            // Initialize the persistent container
            persistentContainer = NSPersistentContainer(name: "BalanceRecordModel") // Replace "YourModelName" with the name of your Core Data Model
            
            // Load the stored data
            persistentContainer.loadPersistentStores { (description, error) in
                if let error = error {
                    fatalError("Failed to load Core Data stack: \(error)")
                }
            }
            
            super.init()
        }
    
    init(container: NSPersistentContainer) {
        self.persistentContainer = container
        super.init()
        setupFetchedResultsController()
    }

    private func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest<Record>(entityName: "Record")
        let sortDescriptor = NSSortDescriptor(key: "recordName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        RecordFetchedResultsController = NSFetchedResultsController<Record>(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        RecordFetchedResultsController?.delegate = self
        
        do {
            try RecordFetchedResultsController?.performFetch()
        } catch {
            print("Failed to initialize FetchedResultsController: \(error)")
        }
    }

    
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save changes to Core Data with error: \(error)")
            }
        }
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .record{
            listener.onRecordChange(change: .update, records: fetchRecord())
        }
        
        if listener.listenerType == .recordCategory || listener.listenerType == .all {
            listener.onRecordCategoryChange(change: .update, recordCategory: fetchRecordCateRecord())
        }

    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
//    func addRecord(recordName: String, recordAmount: Int16, recordType: recordType, recordDate: Date, recordImage: String) -> Record {
//        let record = NSEntityDescription.insertNewObject(forEntityName: "Record", into: persistentContainer.viewContext) as! Record
//
//        record.recordName = recordName
//        record.recordAmount = recordAmount
//        record.recRecordType = recordType
//        record.recordDate = recordDate
//        record.recordImage = URL(string: recordImage)?.lastPathComponent
//
//        cleanup()
//        return record
//    }
    
    func addRecord(recordName: String, recordAmount: Int16, recordType: recordType, recordDate: Date, recordImage: String, categoryName: String) -> Record {
        let record = NSEntityDescription.insertNewObject(forEntityName: "Record", into: persistentContainer.viewContext) as! Record

        // Get or create the category
        let categoryFetch: NSFetchRequest<RecordCategory> = RecordCategory.fetchRequest()
        categoryFetch.predicate = NSPredicate(format: "cateNameR = %@", categoryName)
        
        let categories = try? persistentContainer.viewContext.fetch(categoryFetch)
        let category: RecordCategory
        if let existingCategory = categories?.first {
            category = existingCategory
        } else {
            category = addRecordCategory(cateNameR: categoryName)
        }

        record.recordName = recordName
        record.recordAmount = recordAmount
        record.recRecordType = recordType
        record.recordDate = recordDate
        record.recordImage = URL(string: recordImage)?.lastPathComponent
        record.categoryR = category  // Set the category
        
        cleanup()
        return record
    }

    
    
//    func deleteRecord(record: Record) {
//        persistentContainer.viewContext.delete(record)
//    }
    
    func deleteRecord(record: Record) {
        persistentContainer.viewContext.delete(record)
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("Failed to save context after deleting record: \(error)")
        }
    }

    
    func updateRecord(record: Record) {
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == RecordFetchedResultsController {
            listeners.invoke { listener in
                if listener.listenerType == .record {
                    listener.onRecordChange(change: .update, records: fetchRecord())
                }
            }
        } else if controller == RecordCategoryFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == .recordCategory || listener.listenerType == .all {
                    listener.onRecordCategoryChange(change: .update, recordCategory: fetchRecordCateRecord())
                }
            }
        }
    }

    
    func fetchRecord() -> [Record]{
        let request: NSFetchRequest<Record> = Record.fetchRequest()

        let nameSortDescriptor = NSSortDescriptor(key: "recordName", ascending: true)
        request.sortDescriptors = [nameSortDescriptor]

        if RecordFetchedResultsController == nil {

            RecordFetchedResultsController =
            NSFetchedResultsController<Record>(fetchRequest: request,
                                             managedObjectContext: persistentContainer.viewContext,
                                             sectionNameKeyPath: nil, cacheName: nil)
            // Set this class to be the results delegate
            RecordFetchedResultsController?.delegate = self
        }


            do {
                try RecordFetchedResultsController?.performFetch()
                let records = RecordFetchedResultsController?.fetchedObjects ?? []

                return records
            } catch {
                print("Fetch Request Failed: \(error)")
            }
            return [Record]()
    }
    

    
    lazy var defaultRecordCate: RecordCategory = {
        var recordCate = [RecordCategory]()
        let request: NSFetchRequest<RecordCategory> = RecordCategory.fetchRequest()
        let predicate = NSPredicate(format: "cateNameR = %@", DEFAULT_RECORDCATE_NAME)
        request.predicate = predicate
        do {
            try recordCate = persistentContainer.viewContext.fetch(request)} catch {
                print("Fetch Request Failed: \(error)")
            }
        if let firstTaskCate = recordCate.first {
            return firstTaskCate
        }
        return addRecordCategory(cateNameR: DEFAULT_RECORDCATE_NAME)
    }()
    
    func addRecordCategory(cateNameR: String) -> RecordCategory {
        let recordCate = NSEntityDescription.insertNewObject(forEntityName:
        "RecordCategory", into: persistentContainer.viewContext) as! RecordCategory
        recordCate.cateNameR = cateNameR
        return recordCate
    }
    
    func deleteRecordCategory(cateNameR: RecordCategory) {
        persistentContainer.viewContext.delete(cateNameR)
    }
    
    func removeRecordFromRecordCate(record: Record, recordCate: RecordCategory) {
        recordCate.removeFromRecords(record)
    }
    
    func fetchRecordCateRecord() -> [Record] {
        if RecordCategoryFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Record> = Record.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "cateNameR", ascending: true)
            let predicate = NSPredicate(format: "ANY categoryR.cateNameR == %@",
                                        DEFAULT_RECORDCATE_NAME)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            fetchRequest.predicate = predicate
            RecordCategoryFetchedResultsController =
            NSFetchedResultsController<Record>(fetchRequest: fetchRequest,
                                                  managedObjectContext: persistentContainer.viewContext,
                                                  sectionNameKeyPath: nil, cacheName: nil)
            RecordCategoryFetchedResultsController?.delegate = self
            
        }
        
        do {
            try RecordCategoryFetchedResultsController?.performFetch()
        } catch {
            print("Fetch Request Failed: \(error)")
        }
        
        var records = [Record]()
        if RecordCategoryFetchedResultsController?.fetchedObjects != nil {
            records = (RecordCategoryFetchedResultsController?.fetchedObjects)!
        }
        return records
    }
    
    // finance chart
    

    // finance higheset income/expenditure
    func calculatePercentages(for recordType: recordType) -> [String: Double] {
        let records = fetchRecord() // Get all the records
        print("Fetched \(records.count) records")

        var totalAmount: Int16 = 0 // Initialise total amount to 0
        var amountPerCategory: [String: Int16] = [:] // Map to hold category and its corresponding amount

        // Calculate total amount and amount per category
        for record in records {
            print("Record Type: \(record.recRecordType)") // print record type for each record
            if let category = record.categoryR?.cateNameR {
                print("Category: \(category)") // print category for each record
            } else {
                print("Category is nil")
            }
            
            if record.recRecordType == recordType {
                totalAmount += record.recordAmount
                if let categoryName = record.categoryR?.cateNameR {
                    if let currentCategoryValue = amountPerCategory[categoryName] {
                        amountPerCategory[categoryName] = currentCategoryValue + record.recordAmount
                    } else {
                        amountPerCategory[categoryName] = record.recordAmount
                    }
                }
            }
        }


        print("Calculated total amount: \(totalAmount)")
        print("Amount per category: \(amountPerCategory)")

        // Calculate the percentage of amount for each category
        var percentagePerCategory: [String: Double] = [:] // Map to hold category and its corresponding percentage of amount
        for (category, amount) in amountPerCategory {
            let percentage = Double(amount) / Double(totalAmount) * 100
            percentagePerCategory[category] = percentage
        }

        return percentagePerCategory
    }

    func calculateMonthlyIncomeAndExpenditure(forMonth month: Int, forYear year: Int) -> (income: Int16, expenditure: Int16) {
        let records = fetchRecord()
        
        var totalIncome: Int16 = 0
        var totalExpenditure: Int16 = 0

        // Define Calendar component
        let calendar = Calendar.current

        for record in records {
            let recordMonth = calendar.component(.month, from: record.recordDate!)
            let recordYear = calendar.component(.year, from: record.recordDate!)

            // Only consider records in the specified month and year
            if recordMonth == month && recordYear == year {
                if record.recRecordType == .income {
                    totalIncome += record.recordAmount
                } else if record.recRecordType == .expenditure {
                    totalExpenditure += record.recordAmount
                }
            }
        }
        return (totalIncome, totalExpenditure)
    }

    
}




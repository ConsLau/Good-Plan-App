//
//  CalendarViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 28/4/2023.
//
// Reference 1 (Weekly Calendar Swift Xcode Tutorial | Daily Events List): https://www.youtube.com/watch?v=E-bFeJLsvW0&t=311s
// Reference 2 (Monthly Calendar View App SwiftUI Xcode Tutorial): https://www.youtube.com/watch?v=jBvkFKhnYLI

import UIKit
import CoreData
import FirebaseAuth

var selectedDate = Date()
var selectedMonth: String?

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DatabaseListener {
    
    
    // UI elements
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var addTaskBtn: UIButton!
    
    //variable
    var totalSquares = [String]()
    var selectedIndexPath: IndexPath?
    var allTaskTableViewController: AllTaskTableViewController?
    var allTask: [Task] = []
    weak var databaseController: DatabaseProtocol?
    var listenerType = ListenerType.task
    
    // DatabaseListener
    func onTaskChange(change: DatabaseChange, tasks: [Task]) {
        allTask = tasks
    }
    
    func onBlogChange(change: DatabaseChange, blogs: [Blog]) {
        
    }
    
    func onTaskCategoryChange(change: DatabaseChange, taskCategory: [Task]) {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the AllTaskTableViewController
        for child in self.children {
            if let childVC = child as? AllTaskTableViewController {
                allTaskTableViewController = childVC
            }
        }
        
        setCellView()
        setMonthView()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }

    @IBAction func previousBtn(_ sender: Any) {
        selectedDate = CalendarHelper().minusMonth(date: selectedDate)
        setMonthView()
    }
    
    @IBAction func nextBtn(_ sender: Any) {
        selectedDate = CalendarHelper().plusMonth(date: selectedDate)
        setMonthView()
    }
    
    func setCellView(){
        let width = (collectionView.frame.size.width - 2)/8
        let height = (collectionView.frame.size.width - 2)/7
        
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    func setMonthView(){
        totalSquares.removeAll()
        
        let daysInMonth = CalendarHelper().daysInMonth(date: selectedDate)
        let firstDayOfMonth = CalendarHelper().firstOnMonth(date: selectedDate)
        let startingSpaces = CalendarHelper().weekDay(date: firstDayOfMonth)
        
        var count : Int = 1
        
        while(count <= 42){
            if(count <= startingSpaces || count - startingSpaces > daysInMonth){
                totalSquares.append(" ")
            }else{
                totalSquares.append(String(count - startingSpaces))
            }
            
            count += 1
        }
        let space = " "
        monthLabel.text = CalendarHelper().monthString(date: selectedDate).prefix(3) + space + CalendarHelper().yearString(date: selectedDate)
        
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendarCell", for: indexPath) as! CalendarCell
        
        let dayStr = totalSquares[indexPath.item]
        cell.dateOfMonth.text = dayStr
        
        // Reset the cell's background color
        cell.backgroundColor = .systemBackground
        
        if dayStr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // This is an empty cell, just return it without further customization
            return cell
        }
        
        // Get the selected month and year
        let monthYearStr = CalendarHelper().monthString(date: selectedDate) + " " + CalendarHelper().yearString(date: selectedDate)
        
        // Construct the full date string
        let fullDateStr = monthYearStr + " " + dayStr
        
        // Date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy dd"
        
        guard let fullDate = dateFormatter.date(from: fullDateStr) else {
            return cell
        }
        
        // Filter allTask for tasks on the full date
        let tasksForFullDate = allTask.filter { task in
            guard let taskDate = task.taskDate else { return false }
            
            // We convert taskDate into a string to remove time and then back to Date for comparison
            let taskDateStr = dateFormatter.string(from: taskDate)
            return taskDateStr == dateFormatter.string(from: fullDate)
        }
        
        if tasksForFullDate.count > 0 {
            cell.backgroundColor = .tintColor
        } else if let selectedIndexPath = self.selectedIndexPath, selectedIndexPath == indexPath {
            cell.backgroundColor = .lightGray
        } else if CalendarHelper().isCurrentDate(date: fullDate) {
            cell.backgroundColor = .separator
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Update the selected index path and reload the data to apply the background color changes
        //        performSegue(withIdentifier: "addTask", sender: nil)
        selectedIndexPath = indexPath
        collectionView.reloadData()
        
        // Call the update method in AllTaskTableViewController
        if indexPath.item < totalSquares.count {
            let day = totalSquares[indexPath.item]
            allTaskTableViewController?.updateSelectedDate(selectedDay: day, selectedMonth: CalendarHelper().monthString(date: selectedDate))
        }
        
    }

    override open var shouldAutorotate: Bool{
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? AllTaskTableViewController {
            
            if let selectedindexPath = collectionView.indexPathsForSelectedItems?.first{
                controller.selectedDate = totalSquares[selectedindexPath.item]
                controller.selectedMonth = CalendarHelper().monthString(date: selectedDate)
            }
        }
        
    }
    
}


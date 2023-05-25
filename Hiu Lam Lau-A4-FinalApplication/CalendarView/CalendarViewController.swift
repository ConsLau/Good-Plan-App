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

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var monthLabel: UILabel!
    
    
    @IBOutlet weak var addTaskBtn: UIButton!
    
    var totalSquares = [String]()
    var selectedIndexPath: IndexPath?
    
    //table
    var allTaskTableViewController: AllTaskTableViewController?
    
    // task date
    var allTaskCount: Int = 0

    
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

        //task date

        
    }
    
    // task date
    
    
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

        cell.dateOfMonth.text = totalSquares[indexPath.item]


        // Update the cell background color based on the selected index path
        if indexPath == selectedIndexPath {
            cell.backgroundColor = .lightGray
        } else if let day = Int(totalSquares[indexPath.item]), CalendarHelper().isCurrentDate(day: day) {
            cell.backgroundColor = .separator
        } else if allTaskCount > 0 {
            cell.backgroundColor = .blue
        } else {
            cell.backgroundColor = .systemBackground
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
    
    
    @IBAction func previousBtn(_ sender: Any) {
        selectedDate = CalendarHelper().minusMonth(date: selectedDate)
        setMonthView()
    }
    
    @IBAction func nextBtn(_ sender: Any) {
        selectedDate = CalendarHelper().plusMonth(date: selectedDate)
        setMonthView()
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


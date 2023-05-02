//
//  CalendarViewController.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 28/4/2023.
//

import UIKit

var selectedDate = Date()

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var monthLabel: UILabel!
    
    
    @IBOutlet weak var addTaskBtn: UIButton!
    
    var totalSquares = [String]()
    var selectedIndexPath: IndexPath?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCellView()
        setMonthView()
    }
    
    func setCellView(){
        let width = (collectionView.frame.size.width - 2)/8
        let height = (collectionView.frame.size.width - 2)/8
        
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
        
        monthLabel.text = CalendarHelper().monthString(date: selectedDate).prefix(3) + "" + CalendarHelper().yearString(date: selectedDate)
        
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
            cell.backgroundColor = .gray
        } else {
            cell.backgroundColor = .white
        }

        return cell
    }
    


    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            // Update the selected index path and reload the data to apply the background color changes
            selectedIndexPath = indexPath
            collectionView.reloadData()
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
    

}

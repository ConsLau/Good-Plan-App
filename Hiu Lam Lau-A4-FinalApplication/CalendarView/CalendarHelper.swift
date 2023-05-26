//
//  CalendarHelper.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 29/4/2023.
//
// Reference 1 (Monthly Calendar View App SwiftUI Xcode Tutorial): https://www.youtube.com/watch?v=jBvkFKhnYLI

import Foundation
import UIKit

class CalendarHelper{
    let calendar = Calendar.current
    
    func plusMonth(date: Date) -> Date{
        return calendar.date(byAdding: .month, value: 1, to: date)!
    }
    
    func minusMonth(date: Date) -> Date{
        return calendar.date(byAdding: .month, value: -1, to: date)!
    }
    
    func monthString(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: date)
    }
    
    func yearString(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: date)
    }
    
    func daysInMonth(date: Date) -> Int{
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    
    func daysOfMonth(date: Date) -> Int{
        let components = calendar.dateComponents([.day], from: date)
        return components.day!
    }
    
    func firstOnMonth(date: Date) -> Date{
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }
    
    func weekDay(date: Date) -> Int{
        let components = calendar.dateComponents([.weekday], from: date)
        return components.weekday! - 1
    }
    
    
    // weekly
    func addDays(date: Date, days: Int) -> Date {
        return calendar.date(byAdding: .day, value: days, to: date)!
    }
    
    func sundayForDate(date: Date) -> Date {
        var current = date
        let oneWeekAgo = addDays(date: current, days: -7)
        
        while(current > oneWeekAgo){
            let currentWeekDay = calendar.dateComponents([.weekday], from: current).weekday
            if(currentWeekDay == 1){
                return current
            }
            current = addDays(date: current, days: -1)
        }
        
        return current
        
    }

//    func isCurrentDate(day: Int) -> Bool { 
//        let calendar = Calendar.current
//        let today = Date()
//        let currentDay = calendar.component(.day, from: today)
//        let currentMonth = calendar.component(.month, from: today)
//        let currentYear = calendar.component(.year, from: today)
//
//        let month = calendar.component(.month, from: selectedDate)
//        let year = calendar.component(.year, from: selectedDate)
//
//        return day == currentDay && month == currentMonth && year == currentYear
//    }
    
    func isCurrentDate(date: Date) -> Bool {
        let currentDateString = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
        let dateString = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
        return currentDateString == dateString
    }


    
}

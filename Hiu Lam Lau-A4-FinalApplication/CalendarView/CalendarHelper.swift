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

    
    func isCurrentDate(date: Date) -> Bool {
        let currentDateString = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
        let dateString = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
        return currentDateString == dateString
    }
 
}

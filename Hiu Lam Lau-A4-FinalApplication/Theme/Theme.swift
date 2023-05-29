//
//  Theme.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 14/5/2023.
//

import Foundation
import UIKit

protocol Theme {
    var backgroundColor: UIColor { get }
    var buttonBackgroundColor: UIColor { get }
    var buttonTextColor: UIColor { get }
    var textColor: UIColor { get }
}

struct AppTheme: Theme {
    var backgroundColor: UIColor
    var buttonBackgroundColor: UIColor
    var buttonTextColor: UIColor
    var textColor: UIColor

    // testing testing
}

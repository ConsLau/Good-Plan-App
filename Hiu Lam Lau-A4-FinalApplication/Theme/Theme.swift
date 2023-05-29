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
<<<<<<< HEAD
    // testing commit
    // testing 123
=======
>>>>>>> 078c1bd5c9d14141c4b6f2e511198811b2eab8c3
}

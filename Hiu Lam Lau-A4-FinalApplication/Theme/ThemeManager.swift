//
//  ThemeManager.swift
//  Hiu Lam Lau-A4-FinalApplication
//
//  Created by Cons Lau on 14/5/2023.
//

import Foundation
import UIKit

class ThemeManager {
    
    static let shared = ThemeManager()

    var currentTheme: Theme = AppTheme(
        backgroundColor: UIColor(named: "BackgroundColour") ?? .white,
        buttonBackgroundColor: UIColor(named: "ButtonBackgroundColour") ?? .blue,
        buttonTextColor: UIColor(named: "ButtonTextColour") ?? .black,
        textColor: UIColor(named: "TextColour") ?? .black
    )

    func applyTheme(to window: UIWindow?) {

    }
    
}


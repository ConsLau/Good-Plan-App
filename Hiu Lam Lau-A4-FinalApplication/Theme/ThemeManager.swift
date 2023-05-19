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

        
        //        window?.tintColor = currentTheme.buttonBackgroundColor
//        window?.backgroundColor = currentTheme.backgroundColor
//
//        UINavigationBar.appearance().barTintColor = currentTheme.buttonTextColor
//        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: currentTheme.textColor]
//
//        UIButton.appearance().tintColor = currentTheme.buttonBackgroundColor
//        UIButton.appearance().backgroundColor = nil
//
//        UILabel.appearance().textColor = currentTheme.textColor
//
    }
    
}


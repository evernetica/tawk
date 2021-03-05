//
//  UIColor+Extension.swift
//  tawkApp
//
//  Created by Eugene Shapovalov on 05.03.2021.
//

import UIKit

extension UIColor {
    
    // Main Label
    static var mainLabel: UIColor {
        return dynamicColor(light: UIColor.black, dark: UIColor.white)
    }
    
    // Main cell bg
    static var mainCellBg: UIColor {
        return dynamicColor(light: UIColor.white, dark: UIColor.black)
    }
    
    // Main cell bg
    static var mainButtonBg: UIColor {
        return dynamicColor(light: UIColor.black, dark: UIColor.white)
    }
    
    // Main cell bg
    static var mainButtonLabel: UIColor {
        return dynamicColor(light: UIColor.white, dark: UIColor.black)
    }
    
    private static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        guard #available(iOS 13.0, *) else { return light }
        return UIColor { $0.userInterfaceStyle == .dark ? dark : light }
    }
}

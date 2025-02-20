//
//  UIColor+Extension.swift
//  iosUtilDemo
//
//  Created by Jiankai Lei on 2025/2/19.
//

import Foundation
import UIKit

extension UIColor {
    convenience init?(hex: String) {
        var rgb: UInt64 = 0
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        guard Scanner(string: hexString).scanHexInt64(&rgb) else {
            return nil
        }
        
        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

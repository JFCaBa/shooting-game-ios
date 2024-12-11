//
//  NSAttributedString+BicolorText.swift
//  ShootingApp
//
//  Created by Jose on 11/12/2024.
//

import UIKit

extension NSAttributedString {
    static func attributedStringWithBicolor(string: String, targetSubstring: String, bicolor: (UIColor, UIColor), font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string)
        
        // Define the attributes for the target substring
        let targetAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: bicolor.1,
            .font: font
            
        ]
        
        // Define the attributes for the rest of the string
        let restAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: bicolor.0,
            .font: font
        ]
        
        let restOfStringRange = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttributes(restAttributes, range: restOfStringRange)
        
        // Find and apply the attributes to the target substring
        let targetRange = (string as NSString).range(of: targetSubstring)
        if targetRange.location != NSNotFound {
            attributedString.addAttributes(targetAttributes, range: targetRange)
        }
        
        return attributedString
    }
}

//
//  UIFont+PreferedLabel.swift
//  ShootingApp
//
//  Created by Jose on 11/12/2024.
//

import UIKit

extension UIFont {
    static func preferredFont(forTextStyle textStyle: TextStyle, weight: Weight) -> UIFont {
        let size = UIFont.preferredFont(forTextStyle: textStyle).pointSize
        let font = UIFont.systemFont(ofSize: size, weight: weight)
        
        return font
    }
}

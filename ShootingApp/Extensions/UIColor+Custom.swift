//
//  UIColor+Custom.swift
//  ShootingApp
//
//  Created by Jose on 08/12/2024.
//

import UIKit

extension UIColor {
    static var customPlaygroundQuickLook: UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.systemBlue
            default:
                return UIColor.systemYellow
            }
        }
    }
}

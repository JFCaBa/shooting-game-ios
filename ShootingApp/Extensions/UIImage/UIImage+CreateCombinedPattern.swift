//
//  UIImage+CreateCombinedPattern.swift
//  ShootingApp
//
//  Created by Jose on 09/12/2024.
//

import UIKit

extension UIImage {
    static func createCombinedPattern(baseColor: UIColor, overlayPattern: UIImage) -> UIImage? {
        let size = overlayPattern.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        // Draw base color
        baseColor.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        // Draw overlay pattern
        overlayPattern.draw(in: CGRect(origin: .zero, size: size), blendMode: .normal, alpha: 1.0)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

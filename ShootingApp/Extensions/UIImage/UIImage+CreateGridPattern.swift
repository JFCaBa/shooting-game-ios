//
//  UIImage+CreateGridPattern.swift
//  ShootingApp
//
//  Created by Jose on 09/12/2024.
//

import UIKit

extension UIImage {
    static func createGridPattern(size: CGSize, lineWidth: CGFloat, spacing: CGFloat, color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.setLineWidth(lineWidth)
        context.setStrokeColor(color.cgColor)
        
        let numLinesX = Int(size.width / spacing)
        let numLinesY = Int(size.height / spacing)
        
        // Draw vertical lines
        for i in 0...numLinesX {
            let x = CGFloat(i) * spacing
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: size.height))
        }
        
        // Draw horizontal lines
        for i in 0...numLinesY {
            let y = CGFloat(i) * spacing
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: size.width, y: y))
        }
        
        context.strokePath()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

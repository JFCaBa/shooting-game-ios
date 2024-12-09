//
//  UIImage+CreateHexagonPattern.swift
//  ShootingApp
//
//  Created by Jose on 09/12/2024.
//

import UIKit

extension UIImage {
    static func createHexagonPattern(size: CGSize, color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Clear background
        context.clear(CGRect(origin: .zero, size: size))
        
        color.setStroke()
        context.setLineWidth(2.0)
        
        let hexagonSize: CGFloat = 20
        let rows = Int(size.height / hexagonSize) + 1
        let cols = Int(size.width / hexagonSize) + 1
        
        for row in 0...rows {
            for col in 0...cols {
                let centerX = CGFloat(col) * hexagonSize * 1.5
                let centerY = CGFloat(row) * hexagonSize * 1.732
                let offset = (row % 2 == 0 ? 0 : hexagonSize * 0.75)
                
                let path = UIBezierPath()
                for i in 0...5 {
                    let angle = CGFloat(i) * CGFloat.pi / 3
                    let x = centerX + offset + cos(angle) * hexagonSize
                    let y = centerY + sin(angle) * hexagonSize
                    
                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                path.close()
                path.stroke()
            }
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

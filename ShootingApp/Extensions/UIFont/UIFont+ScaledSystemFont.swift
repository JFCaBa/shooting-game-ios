//
//  UIFont+ScaledSystemFont.swift
//  ShootingApp
//
//  Created by Jose on 11/12/2024.
//

import UIKit

extension UIFont {
    static func scaledSystemFont(for textStyle: UIFont.TextStyle, pointSize: CGFloat) -> UIFont {
        let font = UIFont.systemFont(ofSize: pointSize)
        let metrics = UIFontMetrics(forTextStyle: textStyle)
        return metrics.scaledFont(for: font)
    }
}

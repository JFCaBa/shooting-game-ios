//
//  UIViewController+Child.swift
//  ShootingApp
//
//  Created by Jose on 29/11/2024.
//

import UIKit

extension UIViewController {
    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

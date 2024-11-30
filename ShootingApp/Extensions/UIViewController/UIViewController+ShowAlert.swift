//
//  UIViewController+ShowAlert.swift
//  ShootingApp
//
//  Created by Jose on 30/11/2024.
//

import UIKit

extension UIViewController {
    // MARK: - showAlert(title:, message:)
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(action)
        
        present(alert, animated: true)
    }

}

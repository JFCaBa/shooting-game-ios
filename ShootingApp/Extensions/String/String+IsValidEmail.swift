//
//  String+IsValidEmail.swift
//  ShootingApp
//
//  Created by Jose on 27/12/2024.
//

import Foundation

extension String {
    var isValidEmail: Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return emailPredicate.evaluate(with: self)
    }
}

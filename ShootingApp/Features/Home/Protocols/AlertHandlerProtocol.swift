//
//  AlertHandlerProtocol.swift
//  ShootingApp
//
//  Created by Jose on 04/12/2024.
//

import Foundation

protocol AlertHandlerProtocol {
    func showTimerOrAdAlert(title: String, message: String, completion: (()->())?)
    func startTimer(duration: Int, completion: (()->())?)
}

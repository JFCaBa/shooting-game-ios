//
//  WebSocketServiceDelegate.swift
//  ShootingApp
//
//  Created by Jose on 24/11/2024.
//

import Foundation

protocol WebSocketServiceDelegate: AnyObject {
    func webSocketDidConnect()
    func webSocketDidDisconnect(error: Error?)
    func webSocketDidReceiveMessage(_ message: GameMessage)
}

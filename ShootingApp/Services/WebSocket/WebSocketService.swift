//
//  WebSocketService.swift
//  ShootingApp
//
//  Created by Jose on 26/10/2024.
//

import Foundation

protocol WebSocketServiceDelegate: AnyObject {
    func webSocketDidConnect()
    func webSocketDidDisconnect(error: Error?)
    func webSocketDidReceiveMessage(_ message: GameMessage)
}

class WebSocketService {
    private var webSocket: URLSessionWebSocketTask?
    private let serverURL = URL(string: "ws://onedayvpn.com:8182")!
    private var isConnected = false
    weak var delegate: WebSocketServiceDelegate?
    
    func connect() {
        let session = URLSession(configuration: .default)
        webSocket = session.webSocketTask(with: serverURL)
        webSocket?.resume()
        receiveMessage()
    }
    
    func disconnect() {
        webSocket?.cancel(with: .goingAway, reason: nil)
        isConnected = false
    }
    
    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    self?.handleMessage(data)
                case .string(let string):
                    guard let data = string.data(using: .utf8) else { return }
                    self?.handleMessage(data)
                @unknown default:
                    break
                }
                self?.receiveMessage()
            case .failure(let error):
                self?.delegate?.webSocketDidDisconnect(error: error)
            }
        }
    }
    
    private func handleMessage(_ data: Data) {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let message = try decoder.decode(GameMessage.self, from: data)
            delegate?.webSocketDidReceiveMessage(message)
//            print(message)
        } catch {
            print("Failed to decode message: \(error)")
        }
    }
    
    func send(message: GameMessage) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(message)
            webSocket?.send(.data(data)) { error in
                if let error = error {
                    print("Failed to send message: \(error)")
                }
            }
        } catch {
            print("Failed to encode message: \(error)")
        }
    }
}

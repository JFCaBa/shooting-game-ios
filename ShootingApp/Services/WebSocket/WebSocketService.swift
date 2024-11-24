//
//  WebSocketService.swift
//  ShootingApp
//
//  Created by Jose on 26/10/2024.
//

import Foundation

final class WebSocketService {
    // MARK: - Constants
    
    private let serverURL = URL(string: "ws://onedayvpn.com:8182")!
    private let reconnectDelay: TimeInterval = 3.0
    private let maxReconnectAttempts = 5

    // MARK: - Properties
    
    private var isConnected = false
    private var isReconnecting = false
    private var webSocket: URLSessionWebSocketTask?
    private var reconnectAttempts = 0
    private var pingTimer: Timer?
    
    // MARK: - Delegate
    
    weak var delegate: WebSocketServiceDelegate?
    
    // MARK: - connect()
    
    func connect() {
        guard !isConnected else { return }
        let session = URLSession(configuration: .default)
        webSocket = session.webSocketTask(with: serverURL)
        webSocket?.resume()
        receiveMessage()
        startPingTimer()
    }
    
    // MARK: - disconnect()
    
    func disconnect() {
        stopPingTimer()
        webSocket?.cancel(with: .goingAway, reason: nil)
        isConnected = false
        reconnectAttempts = 0
    }
    
    // MARK: - startPingTimer()
    
    private func startPingTimer() {
        pingTimer?.invalidate()
        pingTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }
    
    // MARK: - stopPingTimer()
    
    private func stopPingTimer() {
        pingTimer?.invalidate()
        pingTimer = nil
    }
    
    // MARK: - sendPing()
    
    private func sendPing() {
        webSocket?.sendPing { [weak self] error in
            if let error = error {
                self?.handleConnectionFailure(error: error)
            }
        }
    }
    
    // MARK: - handleconnectionFailure(error:)
    
    private func handleConnectionFailure(error: Error) {
        isConnected = false
        delegate?.webSocketDidDisconnect(error: error)
        
        guard !isReconnecting else { return }
        attemptReconnection()
    }
    
    // MARK: - attemptReconnection()
    
    private func attemptReconnection() {
        guard reconnectAttempts < maxReconnectAttempts else {
            isReconnecting = false
            reconnectAttempts = 0
            return
        }
        
        isReconnecting = true
        reconnectAttempts += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + reconnectDelay) { [weak self] in
            self?.connect()
            self?.isReconnecting = false
        }
    }
    
    // MARK: - reciveMessage()
    
    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                self.isConnected = true
                self.reconnectAttempts = 0
                
                switch message {
                case .data(let data):
                    self.handleMessage(data)
                case .string(let string):
                    guard let data = string.data(using: .utf8) else { return }
                    self.handleMessage(data)
                @unknown default:
                    break
                }
                self.receiveMessage()
                
            case .failure(let error):
                self.handleConnectionFailure(error: error)
            }
        }
    }
    
    // MARK: - handleMessage(_:)
    
    private func handleMessage(_ data: Data) {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let message = try decoder.decode(GameMessage.self, from: data)
            delegate?.webSocketDidReceiveMessage(message)
        } catch {
            print("Failed to decode message: \(error)")
        }
    }
    
    // MARK: - send(message:)
    
    func send(message: GameMessage) {
        guard isConnected else { return }
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(message)
            webSocket?.send(.data(data)) { [weak self] error in
                if let error = error {
                    self?.handleConnectionFailure(error: error)
                }
            }
        } catch {
            print("Failed to encode message: \(error)")
        }
    }
}

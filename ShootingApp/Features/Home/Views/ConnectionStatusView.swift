//
//  ConnectionStatusView.swift
//  ShootingApp
//
//  Created by Jose on 06/12/2024.
//

import UIKit
import Network
import Combine

final class ConnectionStatusView: UIView {
    // MARK: - Properties
    
    private var cancellables: Set<AnyCancellable> = []
    private let networkMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitoring")
    
    // MARK: - UI Components
    
    private lazy var networkView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "wifi"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGreen
        return imageView
    }()
    
    private lazy var websocketView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "arrow.rectanglepath"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGreen
        return imageView
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupObservers()
        startNetworkMonitoring()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        networkMonitor.cancel()
        cancellables.removeAll()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(networkView)
        addSubview(websocketView)
        
        NSLayoutConstraint.activate([
            networkView.trailingAnchor.constraint(equalTo: trailingAnchor),
            networkView.topAnchor.constraint(equalTo: topAnchor),
            networkView.widthAnchor.constraint(equalToConstant: 20),
            networkView.heightAnchor.constraint(equalToConstant: 20),
            
            websocketView.trailingAnchor.constraint(equalTo: trailingAnchor),
            websocketView.topAnchor.constraint(equalTo: networkView.bottomAnchor, constant: 8),
            websocketView.widthAnchor.constraint(equalToConstant: 20),
            websocketView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupObservers() {
        // Observe WebSocket connection status changes
        NotificationCenter.default.publisher(for: .websocketStatusChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                if let isConnected = notification.userInfo?["isConnected"] as? Bool {
                    self?.updateWebsocketStatus(isConnected: isConnected)
                }
            }
            .store(in: &cancellables)
    }
    
    private func startNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.checkNetworkConnection(path: path)
            }
        }
        networkMonitor.start(queue: monitorQueue)
    }
    
    // MARK: - Connection Checking
    
    /// Check the internet connection and change the icon if lost or reconnected
    private func checkNetworkConnection(path: NWPath) {
        let isConnected = path.status == .satisfied
        
        UIView.animate(withDuration: 0.3) {
            self.networkView.tintColor = isConnected ? .systemGreen : .systemRed
            self.networkView.image = UIImage(
                systemName: isConnected ? "wifi" : "wifi.slash"
            )
        }
    }
    
    /// Check the connection to the websocket server and change the icon if lost or reconnected
    private func updateWebsocketStatus(isConnected: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.websocketView.tintColor = isConnected ? .systemGreen : .systemRed
            self.websocketView.transform = isConnected ? .identity : CGAffineTransform(rotationAngle: .pi)
        }
    }
}

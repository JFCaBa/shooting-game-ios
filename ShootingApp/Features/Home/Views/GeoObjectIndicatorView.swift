//
//  GeoObjectIndicatorView.swift
//  ShootingApp
//
//  Created by Jose on 19/12/2024.
//

import UIKit
import CoreLocation

class GeoObjectIndicatorView: UIView {
    // MARK: - Properties
    
    private let geoObject: GeoObject
    private var distanceUpdateTimer: Timer?
    private let locationManager = LocationManager.shared
    
    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black.withAlphaComponent(0.7)
        view.layer.cornerRadius = 25
        return view
    }()
    
    private lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = iconColor
        return imageView
    }()
    
    private lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private var iconColor: UIColor {
        switch geoObject.type {
        case .drone:
            return .systemBlue
        case .target:
            return .systemRed
        case .powerup:
            return .systemYellow
        }
    }
    
    // MARK: - Init
    
    init(geoObject: GeoObject) {
        self.geoObject = geoObject
        super.init(frame: .zero)
        setupUI()
        configureForType()
        startDistanceUpdates()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopDistanceUpdates()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(iconView)
        containerView.addSubview(distanceLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 50),
            containerView.heightAnchor.constraint(equalToConstant: 65),
            
            iconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            iconView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            distanceLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 4),
            distanceLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
            distanceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
            distanceLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
    }
    
    private func configureForType() {
        let imageName: String
        switch geoObject.type {
        case .drone:
            imageName = "drone.fill"
        case .target:
            imageName = "scope"
        case .powerup:
            imageName = "star.fill"
        }
        iconView.image = UIImage(systemName: imageName)
        
        // Add glow effect
        let glowLayer = CALayer()
        glowLayer.backgroundColor = iconColor.cgColor
        glowLayer.cornerRadius = 12
        glowLayer.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        glowLayer.shadowColor = iconColor.cgColor
        glowLayer.shadowOffset = .zero
        glowLayer.shadowOpacity = 0.5
        glowLayer.shadowRadius = 8
        iconView.layer.insertSublayer(glowLayer, at: 0)
    }
    
    // MARK: - Distance Updates
    
    private func startDistanceUpdates() {
        updateDistance()
        distanceUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateDistance()
        }
    }
    
    private func stopDistanceUpdates() {
        distanceUpdateTimer?.invalidate()
        distanceUpdateTimer = nil
    }
    
    private func updateDistance() {
        guard let userLocation = locationManager.location else { return }
        
        let objectLocation = CLLocation(
            latitude: geoObject.coordinate.latitude,
            longitude: geoObject.coordinate.longitude
        )
        
        let distance = userLocation.distance(from: objectLocation)
        updateDistanceLabel(distance)
    }
    
    private func updateDistanceLabel(_ distance: CLLocationDistance) {
        let formattedDistance: String
        if distance >= 1000 {
            formattedDistance = String(format: "%.1fkm", distance / 1000)
        } else {
            formattedDistance = "\(Int(distance))m"
        }
        distanceLabel.text = formattedDistance
    }
    
    // MARK: - Animation
    
    func startAnimating() {
        // Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, 1.1, 1.0]
        scaleAnimation.keyTimes = [0, 0.5, 1]
        scaleAnimation.duration = 2
        scaleAnimation.repeatCount = .infinity
        containerView.layer.add(scaleAnimation, forKey: "pulse")
        
        // Rotation animation for specific types
        if geoObject.type == .powerup {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnimation.toValue = Double.pi * 2
            rotationAnimation.duration = 4
            rotationAnimation.repeatCount = .infinity
            iconView.layer.add(rotationAnimation, forKey: "rotate")
        }
    }
    
    func stopAnimating() {
        containerView.layer.removeAllAnimations()
        iconView.layer.removeAllAnimations()
    }
}

//
//  DroneAnnotationView.swift
//  ShootingApp
//
//  Created by Jose on 12/12/2024.
//

import MapKit

// MARK: - DroneAnnotationView

class DroneAnnotationView: MKAnnotationView {
    static let reuseIdentifier = "DroneAnnotationView"
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "drone.fill"))
        imageView.tintColor = .systemRed
        return imageView
    }()
    
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        frame = CGRect(x: 0, y: 0, width: 30, height: 20)
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
        canShowCallout = true
        addSubview(imageView)
        imageView.frame = bounds
    }
}

// MARK: - Animation

extension DroneAnnotationView {
    func startAnimating() {
        guard let annotation = annotation as? DroneAnnotation else { return }
        
        // Base animation radius (meters converted to degrees)
        let baseRadius: Double = 0.0001 // ~10 meters
        let maxVariation: Double = 0.00005 // ~5 meters random variation
        let totalKeyframes = 10
        
        // Randomize duration for added realism
        let animationDuration = Double.random(in: 3.0...7.0)
        
        // Animate in a semi-random path
        UIView.animateKeyframes(withDuration: animationDuration, delay: 0, options: [.repeat, .calculationModePaced, .autoreverse]) {
            for i in 0..<totalKeyframes {
                UIView.addKeyframe(withRelativeStartTime: Double(i) / Double(totalKeyframes), relativeDuration: 1.0 / Double(totalKeyframes)) {
                    // Generate random variations for angle and radius
                    let randomAngle = Double.random(in: 0...(2 * .pi))
                    let randomRadius = baseRadius + Double.random(in: -maxVariation...maxVariation)
                    
                    // Calculate the displacement
                    let dx = cos(randomAngle) * randomRadius
                    let dy = sin(randomAngle) * randomRadius
                    
                    // Apply displacement to the annotation
                    annotation.coordinate.latitude += dy
                    annotation.coordinate.longitude += dx
                }
            }
        }
    }
}

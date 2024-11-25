//
//  PlayerAnnotationView.swift
//  ShootingApp
//
//  Created by Jose on 27/10/2024.
//

import MapKit

final class PlayerAnnotationView: MKAnnotationView {
    // MARK: - Constants
    static let reuseIdentifier = "PlayerAnnotationView"
    
    // MARK: - UI Components
    
    private lazy var directionImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "arrow.up.circle.fill"))
        imageView.tintColor = .systemRed
        return imageView
    }()
    
    // MARK: - Overrides
    
    override var annotation: MKAnnotation? {
        didSet {
            guard let playerAnnotation = annotation as? PlayerAnnotation else { return }
            directionImageView.transform = CGAffineTransform(rotationAngle: playerAnnotation.heading * .pi / 180)
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    // MARK: - init?(coder:)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setupUI()
    
    private func setupUI() {
        frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
        canShowCallout = true
        addSubview(directionImageView)
        directionImageView.frame = bounds
    }
}

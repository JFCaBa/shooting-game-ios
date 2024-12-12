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

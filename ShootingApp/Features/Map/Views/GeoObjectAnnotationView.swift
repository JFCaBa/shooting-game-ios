//
//  GeoObjectAnnotationView.swift
//  ShootingApp
//
//  Created by Jose on 19/12/2024.
//

import MapKit

final class GeoObjectAnnotationView: MKAnnotationView {
    // MARK: - Constants
    static let reuseIdentifier = "GeoObjectAnnotationView"
    
    // MARK: - UI Components
    
    private lazy var geoObjectImageView: UIImageView = {
        let image = UIImage(systemName: "fuelpump.fill")
        let imageView = UIImageView(image: image)
        imageView.tintColor = .systemGreen
        return imageView
    }()
    
    // MARK: - Overrides    
    
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
        addSubview(geoObjectImageView)
        geoObjectImageView.frame = bounds
    }
}


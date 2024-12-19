//
//  GeoObjectAnnotationView.swift
//  ShootingApp
//
//  Created by Jose on 19/12/2024.
//

import MapKit

final class GeoObjectAnnotationView: MKAnnotationView {
    static let reuseIdentifier = "GeoObjectAnnotationView"
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Make the view more prominent
        frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        backgroundColor = .systemRed // Make background visible for debugging
        layer.cornerRadius = 20
        
        // Add image
        let imageView = UIImageView(image: UIImage(systemName: "target"))
        imageView.tintColor = .white
        imageView.frame = bounds.insetBy(dx: 8, dy: 8)
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        
        // Enable callout
        canShowCallout = true
        
        // Make sure it's not hidden
        isHidden = false
        alpha = 1.0
    }
}

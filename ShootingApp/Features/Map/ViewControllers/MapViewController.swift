//
//  MapViewController.swift
//  ShootingApp
//
//  Created by Jose on 26/10/2024.
//

import CoreLocation
import MapKit
import UIKit

final class MapViewController: UIViewController {
    // MARK: - Constants
    
    private let viewModel: MapViewModel
    let locationManager = CLLocationManager()
    
    // MARK: - UI Components

    lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.showsUserLocation = true
        map.delegate = self
        return map
    }()
    
    private lazy var handleBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 2.5
        return view
    }()
    
    // MARK: - Initialisers
    
    init(viewModel: MapViewModel = MapViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocation()
        addPanGesture()
        setupBindings()
        mapView.register(PlayerAnnotationView.self, forAnnotationViewWithReuseIdentifier: PlayerAnnotationView.reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refreshPlayers()
    }
    
    // MARK: - setupUI()
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        
        view.addSubview(handleBar)
        view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            handleBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 17),
            handleBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            handleBar.widthAnchor.constraint(equalToConstant: 40),
            handleBar.heightAnchor.constraint(equalToConstant: 5),
            
            mapView.topAnchor.constraint(equalTo: handleBar.bottomAnchor, constant: 24),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - setupBindings()
    
    private func setupBindings() {
        viewModel.playersUpdated = { [weak self] players in
            self?.updateMapAnnotations(with: players)
        }
    }
    
    // MARK: - setupLocation()
    
    private func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    // MARK: - updateMapAnnotations(with:)
    
    private func updateMapAnnotations(with players: [Player]) {
        let oldAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(oldAnnotations)
        let annotations = viewModel.createAnnotations(from: players)
        mapView.addAnnotations(annotations)
    }
    
    // MARK: - addPanGesture()
    
    private func addPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    // MARK: - handlePanGesture(_:)
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let isDraggingDown = translation.y > 0
        
        switch gesture.state {
        case .changed:
            if isDraggingDown {
                view.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
        case .ended:
            let velocity = gesture.velocity(in: view)
            if velocity.y >= 300 || translation.y > 200 {
                dismiss(animated: true)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.view.transform = .identity
                }
            }
        default:
            break
        }
    }
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }
        
        let annotationView = mapView.dequeueReusableAnnotationView(
            withIdentifier: PlayerAnnotationView.reuseIdentifier,
            for: annotation
        )
        return annotationView
    }
}

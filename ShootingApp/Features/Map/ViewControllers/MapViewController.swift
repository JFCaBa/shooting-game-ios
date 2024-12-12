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
    
    private lazy var playersButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "person.3.fill"), for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(playersButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var closeListButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(closeListButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "PlayerCell")
        table.delegate = self
        table.dataSource = self
        table.isHidden = true
        return table
    }()
    
    private lazy var emptyStateView: EmptyStateView = {
        let view = EmptyStateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
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
        setupBindings()
        setupDroneObservers()
        mapView.register(PlayerAnnotationView.self, forAnnotationViewWithReuseIdentifier: PlayerAnnotationView.reuseIdentifier)
        mapView.register(DroneAnnotationView.self, forAnnotationViewWithReuseIdentifier: DroneAnnotationView.reuseIdentifier)
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
        view.addSubview(playersButton)
        view.addSubview(dismissButton)
        view.addSubview(tableView)
        view.addSubview(closeListButton)
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            handleBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 17),
            handleBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            handleBar.widthAnchor.constraint(equalToConstant: 40),
            handleBar.heightAnchor.constraint(equalToConstant: 5),
            
            mapView.topAnchor.constraint(equalTo: handleBar.bottomAnchor, constant: 24),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            playersButton.topAnchor.constraint(equalTo: handleBar.bottomAnchor, constant: 32),
            playersButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            playersButton.widthAnchor.constraint(equalToConstant: 50),
            playersButton.heightAnchor.constraint(equalToConstant: 50),
            
            dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dismissButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32),
            dismissButton.widthAnchor.constraint(equalToConstant: 50),
            dismissButton.heightAnchor.constraint(equalToConstant: 50),
            
            tableView.topAnchor.constraint(equalTo: handleBar.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            closeListButton.topAnchor.constraint(equalTo: handleBar.bottomAnchor, constant: 32),
            closeListButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeListButton.widthAnchor.constraint(equalToConstant: 50),
            closeListButton.heightAnchor.constraint(equalToConstant: 50),
            
            emptyStateView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 32),
            emptyStateView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: -32)
        ])
        
        emptyStateView.configure(
            image: UIImage(systemName: "person.slash"),
            title: "No players nearby\nStart moving around to find other players!"
        )
    }
    
    // MARK: - setupDroneObservers()
    
    private func setupDroneObservers() {
        // Get initial drones if any already exist
        if let arView = ARService.shared.arView {
            showExistingDrones(count: arView.manager.numberOfDrones())
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewDrone(_:)),
            name: .newDroneArrived,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRemoveDrones),
            name: .removeAllDrones,
            object: nil
        )
    }
    
    private func showExistingDrones(count: Int) {
        guard count > 0,
              let userLocation = locationManager.location?.coordinate else { return }
        
        // Create random positions around user for each existing drone
        for _ in 0..<count {
            let randomLatOffset = Double.random(in: -0.001...0.001)
            let randomLonOffset = Double.random(in: -0.001...0.001)
            
            let droneCoordinate = CLLocationCoordinate2D(
                latitude: userLocation.latitude + randomLatOffset,
                longitude: userLocation.longitude + randomLonOffset
            )
            
            let annotation = DroneAnnotation(
                coordinate: droneCoordinate,
                droneId: UUID().uuidString // Temporary ID since we don't have the original
            )
            
            mapView.addAnnotation(annotation)
        }
    }
    
    // MARK: - setupBindings()
    
    private func setupBindings() {
        viewModel.playersUpdated = { [weak self] players in
            self?.updateMapAnnotations(with: players)
            
            // Update empty state if table view is visible
            if !(self?.tableView.isHidden ?? true) {
                self?.emptyStateView.isHidden = !players.isEmpty
            }
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
        // Remove only player annotations
        let oldAnnotations = mapView.annotations.filter {
            !($0 is MKUserLocation) && !($0 is DroneAnnotation)
        }
        mapView.removeAnnotations(oldAnnotations)
        let annotations = viewModel.createAnnotations(from: players)
        mapView.addAnnotations(annotations)
    }
    
    // MARK: - Actions
    
    @objc private func playersButtonTapped() {
        mapView.isHidden = true
        playersButton.isHidden = true
        dismissButton.isHidden = true
        tableView.isHidden = false
        closeListButton.isHidden = false
        tableView.reloadData()
        
        // Show empty state if no players
        emptyStateView.isHidden = !viewModel.players.isEmpty
    }
    
    @objc private func closeListButtonTapped() {
        mapView.isHidden = false
        playersButton.isHidden = false
        dismissButton.isHidden = false
        tableView.isHidden = true
        closeListButton.isHidden = true
        emptyStateView.isHidden = true
    }
    
    @objc private func dismissButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func handleNewDrone(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let drone = userInfo["drone"] as? DroneData,
              let userLocation = locationManager.location?.coordinate else { return }
        
        // Create random position around user
        let randomLatOffset = Double.random(in: -0.001...0.001)
        let randomLonOffset = Double.random(in: -0.001...0.001)
        
        let droneCoordinate = CLLocationCoordinate2D(
            latitude: userLocation.latitude + randomLatOffset,
            longitude: userLocation.longitude + randomLonOffset
        )
        
        let annotation = DroneAnnotation(
            coordinate: droneCoordinate,
            droneId: drone.droneId
        )
        
        DispatchQueue.main.async {
            self.mapView.addAnnotation(annotation)
        }
    }
    
    @objc private func handleRemoveDrones() {
        let droneAnnotations = mapView.annotations.filter { $0 is DroneAnnotation }
        mapView.removeAnnotations(droneAnnotations)
    }
}

// MARK: - UITableViewDataSource

extension MapViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath)
        let player = viewModel.players[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = "Player: \(player.id)"
        
        if let userLocation = locationManager.location {
            let playerLocation = CLLocation(
                latitude: player.location.latitude,
                longitude: player.location.longitude
            )
            let distance = userLocation.distance(from: playerLocation)
            content.secondaryText = String(format: "%.0f meters away", distance)
        }
        
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MapViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let player = viewModel.players[indexPath.row]
        let coordinate = CLLocationCoordinate2D(
            latitude: player.location.latitude,
            longitude: player.location.longitude
        )
        
        closeListButtonTapped()
        
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        mapView.setRegion(region, animated: true)
    }
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        if annotation is DroneAnnotation {
            return mapView.dequeueReusableAnnotationView(
                withIdentifier: DroneAnnotationView.reuseIdentifier,
                for: annotation
            )
        }
        
        return mapView.dequeueReusableAnnotationView(
            withIdentifier: PlayerAnnotationView.reuseIdentifier,
            for: annotation
        )
    }
}

//
//  HomeViewController.swift
//  ShootingApp
//
//  Created by Jose on 26/10/2024.
//

import UIKit
import AVFoundation

final class HomeViewController: UIViewController {
    // MARK: - Constants
    
    private let viewModel: HomeViewModel
    private var captureSession: AVCaptureSession?
    private var initialCrosshairPosition: CGPoint = .zero
    private let crosshairRecoilDistance: CGFloat = 20
    private let maxAmmo = 30
    private var currentAmmo = 30
    private let maxLives = 10
    private var currentLives = 10
    private var isReloading = false
    
    // MARK: - Properties
    
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer()
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    private lazy var ammoBar: StatusBarView = {
        let bar = StatusBarView(
            icon: UIImage(named: "bullets"),
            tintColor: .systemGreen,
            maxValue: Float(maxAmmo)
        )
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.accessibilityIdentifier = "ammoBar"
        return bar
    }()
    
    private lazy var lifeBar: StatusBarView = {
        let bar = StatusBarView(
            icon: UIImage(systemName: "heart.fill"),
            tintColor: .systemRed,
            maxValue: Float(maxLives)
        )
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.accessibilityIdentifier = "lifeBar"
        return bar
    }()
    
    private lazy var mapButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "map"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(mapButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    private lazy var reloadTimerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 70, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private lazy var crosshairView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalLine = UIView()
        horizontalLine.translatesAutoresizingMaskIntoConstraints = false
        horizontalLine.backgroundColor = .white
        horizontalLine.alpha = 0.8
        
        let verticalLine = UIView()
        verticalLine.translatesAutoresizingMaskIntoConstraints = false
        verticalLine.backgroundColor = .white
        verticalLine.alpha = 0.8
        
        view.addSubview(horizontalLine)
        view.addSubview(verticalLine)
        
        NSLayoutConstraint.activate([
            horizontalLine.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            horizontalLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            horizontalLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            horizontalLine.heightAnchor.constraint(equalToConstant: 2),
            
            verticalLine.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            verticalLine.topAnchor.constraint(equalTo: view.topAnchor),
            verticalLine.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            verticalLine.widthAnchor.constraint(equalToConstant: 2)
        ])
        
        return view
    }()
    
    private lazy var shootButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 35
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(shootButtonTapped), for: .touchUpInside)
        
        // Add inner circle
        let innerCircle = UIView()
        innerCircle.translatesAutoresizingMaskIntoConstraints = false
        innerCircle.backgroundColor = .white
        innerCircle.layer.cornerRadius = 25
        
        return button
    }()
    
    // MARK: - Initialisers
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
        setupObservers()
        shootButton.isExclusiveTouch = true
        viewModel.start()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        initialCrosshairPosition = crosshairView.center
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - setupObservers()
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePlayerHit),
            name: .playerWasHit,
            object: nil
        )
    }
    
    // MARK: - SetupUI
    
    private func setupUI() {
        view.backgroundColor = .black
        view.layer.addSublayer(previewLayer)
        
        view.addSubview(crosshairView)
        view.addSubview(shootButton)
        view.addSubview(ammoBar)
        view.addSubview(lifeBar)
        view.addSubview(reloadTimerLabel)
        view.addSubview(mapButton)
        
        NSLayoutConstraint.activate([
            // Cross hair view
            crosshairView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            crosshairView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -150),
            crosshairView.widthAnchor.constraint(equalToConstant: 50),
            crosshairView.heightAnchor.constraint(equalToConstant: 50),
            // Shoot button
            shootButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shootButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            shootButton.widthAnchor.constraint(equalToConstant: 70),
            shootButton.heightAnchor.constraint(equalToConstant: 70),
            // Ammo bar
            ammoBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            ammoBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            ammoBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            ammoBar.heightAnchor.constraint(equalToConstant: 20),
            // Life bar
            lifeBar.topAnchor.constraint(equalTo: ammoBar.bottomAnchor, constant: 8),
            lifeBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            lifeBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            lifeBar.heightAnchor.constraint(equalToConstant: 20),
            // Reload timer label
            reloadTimerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            reloadTimerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            // Map
            mapButton.centerYAnchor.constraint(equalTo: shootButton.centerYAnchor),
            mapButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mapButton.widthAnchor.constraint(equalToConstant: 50),
            mapButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        reloadTimerLabel.isHidden = true
    }
    
    // MARK: - setupCamera()
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              let captureSession = captureSession else {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        previewLayer.session = captureSession
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    // MARK: - Actions
    
    @objc private func shootButtonTapped() {
        guard !isReloading && currentAmmo > 0 else { return }
        viewModel.shoot()
        performShootEffects()
        updateAmmo()
    }
    
    @objc private func mapButtonTapped() {
        let mapVC = MapViewController()
        mapVC.modalPresentationStyle = .pageSheet
        
        if let sheet = mapVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = false
        }
        
        present(mapVC, animated: true)
    }
    
    // MARK: - Player hit
    
    @objc private func handlePlayerHit() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
        
        DispatchQueue.main.async {
            let flashView = UIView(frame: self.view.bounds)
            flashView.backgroundColor = .red
            flashView.alpha = 0
            flashView.accessibilityIdentifier = "hitFlashView"
            self.view.addSubview(flashView)
            
            UIView.animate(withDuration: 0.1, animations: {
                flashView.alpha = 0.3
            }) { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    flashView.alpha = 0
                }) { _ in
                    flashView.removeFromSuperview()
                }
            }
            
            self.updateLives()
        }
        
    }
    
    // MARK: - performShootEffects
    
    private func performShootEffects() {
        // Vibrate
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
        
        // Crosshair recoil animation
        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: []) { [weak self] in
            guard let self = self else { return }
            
            // Move up quickly
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1) {
                self.crosshairView.center.y -= self.crosshairRecoilDistance
            }
            
            // Move down slowly
            UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.2) {
                self.crosshairView.center.y = self.initialCrosshairPosition.y
            }
        }
        
        // Button animation
        UIView.animate(withDuration: 0.1, animations: {
            self.shootButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.shootButton.transform = .identity
            }
        }
        
        // Screen flash effect
        let flashView = UIView(frame: view.bounds)
        flashView.backgroundColor = .white
        flashView.alpha = 0
        flashView.accessibilityIdentifier = "flashView"
        view.addSubview(flashView)
        
        UIView.animate(withDuration: 0.1, animations: {
            flashView.alpha = 0.3
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                flashView.alpha = 0
            }) { _ in
                flashView.removeFromSuperview()
            }
        }
    }
    
    // MARK: - updateAmmo()
    
    private func updateAmmo() {
        guard currentAmmo > 0 else {
            startReloading()
            return
        }
        
        currentAmmo -= 1
        ammoBar.updateValue(Float(currentAmmo))
        
        if currentAmmo == 0 {
            shootButton.isEnabled = false
            shootButton.alpha = 0.5
            startReloading()
        }
    }
    
    // MARK: - startReloading()
    
    private func startReloading() {
        guard !isReloading else { return }
        isReloading = true
        
        var timeLeft = 60
        reloadTimerLabel.isHidden = false
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.reloadTimerLabel.text = "\(timeLeft)"
            
            if timeLeft <= 0 {
                timer.invalidate()
                self.finishReloading()
            }
            timeLeft -= 1
        }
    }
    
    // MARK: - finishReloading()
    
    private func finishReloading() {
        currentAmmo = maxAmmo
        ammoBar.updateValue(Float(maxAmmo))
        reloadTimerLabel.isHidden = true
        shootButton.isEnabled = true
        shootButton.alpha = 1.0
        isReloading = false
    }
    
    // MARK: - updateLives()
    
    private func updateLives() {
        guard currentLives > 0 else {
            startRecovering()
            return
        }
        
        currentLives -= 1
        lifeBar.updateValue(Float(currentLives))
        
        if currentLives == 0 {
            shootButton.isEnabled = false
            shootButton.alpha = 0.5
            startRecovering()
        }
    }
    
    // MARK: - startRecovering()
    
    private func startRecovering() {
        guard !isReloading else { return }
        isReloading = true
        
        var timeLeft = 60
        reloadTimerLabel.isHidden = false
        reloadTimerLabel.text = "\(timeLeft)"
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.reloadTimerLabel.text = "\(timeLeft)"
            
            if timeLeft <= 0 {
                timer.invalidate()
                self.finishRecovering()
            }
            timeLeft -= 1
        }
    }
    
    // MARK: - finishRecovering()
    
    private func finishRecovering() {
        currentLives = maxLives
        lifeBar.updateValue(Float(maxLives))
        reloadTimerLabel.isHidden = true
        shootButton.isEnabled = true
        shootButton.alpha = 1.0
        isReloading = false
    }
}


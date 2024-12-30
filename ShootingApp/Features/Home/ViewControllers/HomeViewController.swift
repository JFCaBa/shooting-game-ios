//
//  HomeViewController.swift
//  ShootingApp
//
//  Created by Jose on 26/10/2024.
//

import AVFoundation
import Combine
import CoreLocation
import CoreML
import GoogleMobileAds
import UIKit
import Vision
import SceneKit

final class HomeViewController: UIViewController {
    // MARK: - Constants
    
    private let crosshairRecoilDistance: CGFloat = 20
    let maxAmmo = 30
    let maxLives = 10
    let amountHitReward = 1
    let amountHitDroneReward = 2
    let amountKillReward = 5
    private let amountAdReward = 10
    private let hitValidator = HitValidationService()
    let viewModel = HomeViewModel()
    
    // MARK: - Properties
    
    private var initialCrosshairPosition: CGPoint = .zero
    private var currentAmmo = 30
    private var currentLives = 10
    private var isReloading = false
    private var rewardedAd: GADRewardedAd?
    private let previewZoom = CATransform3DMakeScale(1, 1, 1)
    private var cancellables: Set<AnyCancellable> = []
    private var alertHandler: HomeAlertHandler! = nil
    var droneCount: Int = 0
    
    public var visionDebugView: VisionDebugView! // Used in extension HomeViewController+VisionDebug
    
    // MARK: - UI Components
    
    private lazy var topContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black.withAlphaComponent(0.8)
        return view
    }()
    
    lazy var ammoBar: StatusBarView = {
        let bar = StatusBarView(
            icon: UIImage(named: "bullets"),
            tintColor: .systemGreen,
            maxValue: Float(maxAmmo)
        )
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.accessibilityIdentifier = "ammoBar"
        return bar
    }()
    
    lazy var lifeBar: StatusBarView = {
        let bar = StatusBarView(
            icon: UIImage(systemName: "heart.fill"),
            tintColor: .systemRed,
            maxValue: Float(maxLives)
        )
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.accessibilityIdentifier = "lifeBar"
        return bar
    }()
    
    lazy var droneCountView: DroneCountView = {
        let view = DroneCountView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var scoreView: ScoreView = {
        let view = ScoreView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var statusView: ConnectionStatusView = {
        let view = ConnectionStatusView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var modeSelectorView: ModeSelectorView = {
        let selector = ModeSelectorView(frame: .zero)
        selector.setInitialCenteredIndex(2)
        selector.translatesAutoresizingMaskIntoConstraints = false
        return selector
    }()
    
    lazy var reloadTimerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 70, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    lazy var crosshairView: UIView = {
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
    
    private lazy var shootFeedbackView: ShootFeedbackView = {
        let view = ShootFeedbackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var zoomSlider: ZoomSliderControlView = {
        let control = ZoomSliderControlView()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.zoomChanged = { [weak self] zoom in
            guard let arView = ARService.shared.arView else { return }
            arView.updateZoom(scale: zoom)
        }
        return control
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
    
    lazy var radarView: RadarView = {
        let radar = RadarView()
        radar.translatesAutoresizingMaskIntoConstraints = false
        radar.backgroundColor = .clear
        radar.layer.cornerRadius = 8
        radar.clipsToBounds = true
        radar.isHidden = true
        return radar
    }()
    
    private lazy var contentContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    // MARK: - Initialisers
    
    init(coordinator: AppCoordinator) {
        self.viewModel.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        // Preload the sounds
        SoundManager.shared.preloadSounds(sounds: [.drone, .shoot, .explosion])
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        ARService.shared.cleanup()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.alertHandler = HomeAlertHandler(viewController: self)
        setupAR()
        setupTopContainer()
        setupUI()
        setupObservers()
        setupDebugViews()
        shootButton.isExclusiveTouch = true
        setupBindings()
        modeSelectorViewCallback()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initialCrosshairPosition = crosshairView.center
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showOnboardingIfNeeded()
    }
    
    // MARK: - setupBindings()
    private func setupBindings() {
        viewModel.$error
            .compactMap({$0})
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self else { return }
                
                showAlert(title: "Error", message: error.localizedDescription)
            }
            .store(in: &cancellables)
        
        viewModel.$reward
            .compactMap({$0})
            .receive(on: DispatchQueue.main)
            .sink { [weak self] reward in
                guard let self else { return }
                
                showFeedback(.reward, amount: reward.amount ?? amountAdReward)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - setupObservers()
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePlayerHit),
            name: .playerWasHit,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleHitConfirmation),
            name: .playerHitTarget,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleHitDroneConfirmation),
            name: .dronShootConfirmed,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKillConfirmation),
            name: .playerKilledTarget,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleShootConfirmed(_:)),
            name: .shootConfirmed,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewGeoObjectArrived(_:)),
            name: .newGeoObjectArrived,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleGeoObjectHit(_:)),
            name: .geoObjectHit,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleGeoObjectShootConfirmed(_:)),
            name: .geoObjectShootConfirmed,
            object: nil
        )
    }
    
    // MARK: - SetupTopContainer
    
    private func setupTopContainer() {
        // Add blur effect to top container
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        topContainerView.addSubview(blurView)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topContainerView.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: topContainerView.bottomAnchor)
        ])
        
        // Ensure the blur view is behind the content
        topContainerView.sendSubviewToBack(blurView)
    }
    
    // MARK: - SetupUI
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(topContainerView)
        view.addSubview(crosshairView)
        view.addSubview(zoomSlider)
        view.addSubview(modeSelectorView)
        view.addSubview(shootButton)
        view.addSubview(reloadTimerLabel)
        view.addSubview(radarView)
        view.addSubview(settingsButton)
        view.addSubview(contentContainerView)
        
        topContainerView.addSubview(ammoBar)
        topContainerView.addSubview(lifeBar)
        topContainerView.addSubview(scoreView)
        topContainerView.addSubview(droneCountView)
        topContainerView.addSubview(statusView)
        
        NSLayoutConstraint.activate([
            // Top container
            topContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            topContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topContainerView.heightAnchor.constraint(equalToConstant: 150),
            
            // Ammo bar
            ammoBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 44),
            ammoBar.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 16),
            ammoBar.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -16),
            ammoBar.heightAnchor.constraint(equalToConstant: 20),
            
            // Life bar
            lifeBar.topAnchor.constraint(equalTo: ammoBar.bottomAnchor, constant: 8),
            lifeBar.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 16),
            lifeBar.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -16),
            lifeBar.heightAnchor.constraint(equalToConstant: 20),
            
            // Score view
            scoreView.topAnchor.constraint(equalTo: lifeBar.bottomAnchor, constant: 8),
            scoreView.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 16),
            scoreView.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -16),
            scoreView.heightAnchor.constraint(equalToConstant: 50),
            
            // Drones view
            droneCountView.topAnchor.constraint(equalTo: lifeBar.bottomAnchor, constant: 8),
            droneCountView.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 16),
            droneCountView.widthAnchor.constraint(equalToConstant: 60),
            droneCountView.heightAnchor.constraint(equalToConstant: 50),
            
            // Status view
            statusView.topAnchor.constraint(equalTo: lifeBar.bottomAnchor, constant: 5),
            statusView.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -25),
            statusView.widthAnchor.constraint(equalToConstant: 20),
            statusView.heightAnchor.constraint(equalToConstant: 48),
            
            // Crosshair
            crosshairView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            crosshairView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -150),
            crosshairView.widthAnchor.constraint(equalToConstant: 50),
            crosshairView.heightAnchor.constraint(equalToConstant: 50),
            
            // Zoom
            zoomSlider.centerXAnchor.constraint(equalTo: shootButton.centerXAnchor),
            zoomSlider.bottomAnchor.constraint(equalTo: modeSelectorView.topAnchor, constant: -10),
            zoomSlider.heightAnchor.constraint(equalToConstant: 44),
            zoomSlider.widthAnchor.constraint(equalToConstant: 140),
            
            // Shoot button
            shootButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shootButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            shootButton.widthAnchor.constraint(equalToConstant: 70),
            shootButton.heightAnchor.constraint(equalToConstant: 70),
            
            // Settings button
            settingsButton.heightAnchor.constraint(equalToConstant: 50),
            settingsButton.widthAnchor.constraint(equalToConstant: 50),
            settingsButton.centerYAnchor.constraint(equalTo: shootButton.centerYAnchor),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Reload timer
            reloadTimerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            reloadTimerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Mode selector view
            modeSelectorView.topAnchor.constraint(equalTo: shootButton.topAnchor, constant: -54),
            modeSelectorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            modeSelectorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            modeSelectorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Radar View
            radarView.topAnchor.constraint(equalTo: topContainerView.bottomAnchor, constant: 16),
            radarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            radarView.widthAnchor.constraint(equalToConstant: 120),
            radarView.heightAnchor.constraint(equalToConstant: 120),
            
            // Container view
            contentContainerView.topAnchor.constraint(equalTo: topContainerView.bottomAnchor),
            contentContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: modeSelectorView.topAnchor)
        ])
        
        reloadTimerLabel.isHidden = true
    }
    
    
    // MARK: - Mode selector callback
    
    private func modeSelectorViewCallback() {
        modeSelectorView.setOnModeSelect { [weak self] mode in
            guard let self = self else { return }
            
            // Remove any existing child view controller
            self.removeCurrentViewController()
            
            switch mode {
            case .inventory:
                self.showAlert(title: "Info", message: "Coming soon...")
                self.contentContainerView.isHidden = true
                
            case .map:
                let mapVC = MapViewController()
                self.addViewController(mapVC)
                
            case .game:
                self.contentContainerView.isHidden = true
                self.removeCurrentViewController()
                
            case .achievements:
                let achievementsVC = AchievementsViewController(viewModel: AchievementsViewModel())
                self.addViewController(achievementsVC)
                
            case .hallOfFame:
                let hallOfFameVC = HallOfFameViewController(viewModel: HallOfFameViewModel())
                self.addViewController(hallOfFameVC)
            }
        }
    }
    
    private func addViewController(_ viewController: UIViewController) {
        removeCurrentViewController()
        addChild(viewController)
        contentContainerView.isHidden = false
        
        viewController.view.frame = contentContainerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentContainerView.addSubview(viewController.view)
        
        viewController.didMove(toParent: self)
        
        // Add blur effect to the background
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = viewController.view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.view.insertSubview(blurView, at: 0)
    }

    private func removeCurrentViewController() {
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }
    
    
    // MARK: - shootButtonTapped()
    
    @objc private func shootButtonTapped() {
        guard !isReloading && currentAmmo > 0 else { return }
        
        let crosshairCenter = crosshairView.center
        
#if targetEnvironment(simulator)
        viewModel.shoot(at: crosshairCenter, isValid: false)
        performShootEffects()
        updateAmmo()
#else
        // Use AR's scene view to validate hit
        Task {
            do {
                let validation = try await hitValidator.validateHit(
                    sceneView: ARService.shared.arView?.sceneView,
                    tapLocation: crosshairCenter
                )
                
                await MainActor.run {
                    viewModel.shoot(at: crosshairCenter, isValid: validation.isValid)
                }
                
            } catch {
                await MainActor.run {
                    handleShootingError(error)
                    viewModel.shoot(at: crosshairCenter, isValid: false)
                }
            }
        }
        performShootEffects()
        updateAmmo()
#endif
    }
    
    // MARK: - handleShootingError(_:)
    
    private func handleShootingError(_ error: Error) {
        switch error {
        case AntiCheatError.shotTooFast:
            // TODO: show a cooldown indicator
            break
        case AntiCheatError.noPersonDetected:
            // TODO: show "No target detected" message
            break
        case HitValidationError.invalidDistance:
            // TODO: show "Target too far" message
            break
        case AntiCheatError.noObservations:
            // TODO: show "No boservations" message
            break
        default:
            break
        }
    }
    
    // MARK: - handleShootConfirmed()
    
    @objc private func handleShootConfirmed(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let shootInfo = userInfo["shootInfo"] as? ShootData else { return }
        
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            view.addSubview(shootFeedbackView)
            NSLayoutConstraint.activate([
                shootFeedbackView.centerXAnchor.constraint(equalTo: crosshairView.centerXAnchor),
                shootFeedbackView.topAnchor.constraint(equalTo: crosshairView.bottomAnchor, constant: 8)
            ])
            
            shootFeedbackView.show(distance: shootInfo.distance, deviation: shootInfo.deviation)
        }
    }
    
    
    // MARK: - handleHitConfirmation()
    
    @objc func handleHitConfirmation() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            let gameScore = GameManager.shared.gameScore
            self.scoreView.updateScore(hits: gameScore.hits, kills: gameScore.kills)
            
            showFeedback(.hit, amount: amountHitReward)
        }
    }
    
    // MARK: - settingsButtonTapped()
    
    @objc private func settingsButtonTapped() {
        viewModel.coordinator?.showSettings()
    }
    
    
    // MARK: - showFeedback(_:)
    
    func showFeedback(_ style: FeedbackStyle, amount: Int) {
        let hitFeedback = FeedbackView()
        hitFeedback.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hitFeedback)
        
        NSLayoutConstraint.activate([
            hitFeedback.centerXAnchor.constraint(equalTo: crosshairView.centerXAnchor),
            hitFeedback.bottomAnchor.constraint(equalTo: crosshairView.topAnchor, constant: -10),
            hitFeedback.widthAnchor.constraint(equalToConstant: 150),
            hitFeedback.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        hitFeedback.show(style: style, amount: amount)
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
        // Reproduce the sound
        SoundManager.shared.playSound(type: .shoot)
        
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
        
        askTimerOrAd(title: "You run out of ammo!",
                     message: "Do you prefer a timer or a rewarded ad?")
        { [weak self] in
            guard let self else { return }
            finishReloading()
        }
    }
    
    // MARK: - finishReloading()
    
    private func finishReloading() {
        DispatchQueue.main.async { [weak self] in
            guard let self else  { return }
            
            currentAmmo = maxAmmo
            ammoBar.updateValue(Float(maxAmmo))
            reloadTimerLabel.isHidden = true
            shootButton.isEnabled = true
            shootButton.alpha = 1.0
            isReloading = false
        }
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
        
        askTimerOrAd(title: "You have been Killed!",
                     message: "Do you prefer a timer or a rewarded ad?")
        { [weak self] in
            guard let self else { return }
            
            finishRecovering()
        }
    }
    
    // MARK: - askTimerOrAd()
    
    private func askTimerOrAd(title: String, message: String, completion: (()->())? = nil) {
        alertHandler.showTimerOrAdAlert(title: title, message: message, completion: completion)
    }
    
    // MARK: - loadTimer()
    
    private func loadTimer(completion: (()->())? = nil) {
        alertHandler.startTimer(duration: 60, completion: completion)
    }
    
    // MARK: - finishRecovering()
    
    private func finishRecovering() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            currentLives = maxLives
            lifeBar.updateValue(Float(maxLives))
            reloadTimerLabel.isHidden = true
            shootButton.isEnabled = true
            shootButton.alpha = 1.0
            isReloading = false
        }
    }
    
    // MARK: - showOnboardingIfNeeded()
    
    private func showOnboardingIfNeeded() {
        if let viewController = OnboardingSheetViewController(configuration: .home) {
            viewController.additionalSafeAreaInsets.top = 3
            viewController.sheetPresentationController?.prefersGrabberVisible = false
            viewController.sheetPresentationController?.detents = [.large()]
            viewController.isModalInPresentation = true
            present(viewController, animated: true)
        }
    }
    
    // MARK: - refreshAmmoAndLives()
    
    private func refreshAmmoAndLives() {
        if currentLives == 0 {
            finishRecovering()
        }
        if currentAmmo < maxAmmo {
            finishReloading()
        }
    }
    
    // MARK: - adReward()
    
    private func adReward() {
        viewModel.adReward()
    }
}

// MARK: - Google Ads

extension HomeViewController: GADFullScreenContentDelegate {
    func loadRewardedAd() async {
        let testAdUnit = "ca-app-pub-3940256099942544/1712485313"
        //        let realAdUnit = "ca-app-pub-7775310069169651/7326907431"
        do {
            rewardedAd = try await GADRewardedAd.load(
                withAdUnitID: testAdUnit, request: GADRequest()
            )
            rewardedAd?.fullScreenContentDelegate = self
            rewardedAd?.present(fromRootViewController: self) { [weak self] in
                guard let self else { return }
                
                // Reward user
                let reward = rewardedAd?.adReward
                print("User earned reward: \(reward?.amount ?? 0) \(reward?.type ?? "")")
            }
            
        } catch {
            print("Rewarded ad failed to load with error: \(error.localizedDescription)")
            refreshAmmoAndLives()
        }
    }
    
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        refreshAmmoAndLives()
    }
    
    /// Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
        refreshAmmoAndLives()
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        adReward()
    }
}

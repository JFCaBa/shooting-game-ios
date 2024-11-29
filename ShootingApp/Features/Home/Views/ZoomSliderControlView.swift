//
//  ZoomSliderControlView.swift
//  ShootingApp
//
//  Created by Jose on 29/11/2024.
//

import UIKit

final class ZoomSliderControlView: UIView {
    // MARK: - Constants
    
    private let minZoom: CGFloat = 1.0
    private let maxZoom: CGFloat = 10.0
    private let zoomStep: CGFloat = 2.5
    
    // MARK: - Properties
    
    private var lastStepValue: CGFloat = 1.0
    private var handleCenterXConstraint: NSLayoutConstraint?
    private var currentZoom: CGFloat = 1.0
    var zoomChanged: ((CGFloat) -> Void)?
    
    // MARK: - UI
    
    private lazy var sliderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 1
        return view
    }()
    
    private lazy var handleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 2
        return view
    }()
    
    private lazy var zoomLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemYellow
        label.text = "1.0x"
        return label
    }()
    
    private lazy var stepsStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        return stack
    }()
    
    // MARK: - init(frame:)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setupUI()
    
    private func setupUI() {
        backgroundColor = .clear
        addSubview(sliderView)
        addSubview(stepsStackView)
        addSubview(handleView)
        addSubview(zoomLabel)
        
        setupStepMarks()
        
        NSLayoutConstraint.activate([
            sliderView.centerYAnchor.constraint(equalTo: centerYAnchor),
            sliderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            sliderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            sliderView.heightAnchor.constraint(equalToConstant: 2),
            
            stepsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stepsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stepsStackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
            stepsStackView.heightAnchor.constraint(equalToConstant: 8),
            
            handleView.centerYAnchor.constraint(equalTo: centerYAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 20),
            handleView.heightAnchor.constraint(equalToConstant: 20),
            
            zoomLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 20),
            zoomLabel.centerXAnchor.constraint(equalTo: handleView.centerXAnchor)
        ])
        
        handleCenterXConstraint = handleView.centerXAnchor.constraint(equalTo: leadingAnchor)
        handleCenterXConstraint?.isActive = true
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
        isUserInteractionEnabled = true
    }
    
    private func setupStepMarks() {
        let numberOfSteps = Int((maxZoom - minZoom) / zoomStep) + 1
        
        for _ in 0..<numberOfSteps {
            let mark = UIView()
            mark.translatesAutoresizingMaskIntoConstraints = false
            mark.backgroundColor = .white.withAlphaComponent(0.3)
            mark.widthAnchor.constraint(equalToConstant: 2).isActive = true
            mark.heightAnchor.constraint(equalToConstant: 8).isActive = true
            stepsStackView.addArrangedSubview(mark)
        }
    }
    
    // MARK: - handlePan(_:)
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let maxX = bounds.width
        
        var newX = (handleCenterXConstraint?.constant ?? 0) + translation.x
        newX = min(maxX, max(0, newX))
        
        handleCenterXConstraint?.constant = newX
        
        let progress = newX / maxX
        currentZoom = minZoom + (maxZoom - minZoom) * progress
        
        let roundedZoom = (currentZoom / zoomStep).rounded() * zoomStep
        if roundedZoom != lastStepValue {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            lastStepValue = roundedZoom
        }
        
        zoomLabel.text = String(format: "%.1fx", currentZoom)
        zoomChanged?(currentZoom)
        gesture.setTranslation(.zero, in: self)
    }
}

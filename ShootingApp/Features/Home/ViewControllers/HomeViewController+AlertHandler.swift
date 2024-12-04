//
//  HomeViewController+AlertHandler.swift
//  ShootingApp
//
//  Created by Jose on 04/12/2024.
//

import UIKit

extension HomeViewController {
    class HomeAlertHandler: AlertHandlerProtocol {
        weak var viewController: HomeViewController?
        
        init(viewController: HomeViewController) {
            self.viewController = viewController
        }
        
        func showTimerOrAdAlert(title: String, message: String, completion: (()->())? = nil) {
            guard let viewController else { return }
            
            // If another VC is presented, start timer directly
            if viewController.presentedViewController != nil {
                startTimer(duration: 60, completion: completion)
                return
            }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            let timer = UIAlertAction(title: "Timer", style: .default) { [weak self] _ in
                self?.startTimer(duration: 60, completion: completion)
            }
            let ad = UIAlertAction(title: "Ad", style: .default) { [weak self] _ in
                guard let self else { return }
                Task {
                    await viewController.loadRewardedAd()
                    completion?()
                }
            }
            
            alert.addAction(timer)
            alert.addAction(ad)
            viewController.present(alert, animated: true)
        }
        
        func startTimer(duration: Int, completion: (()->())? = nil) {
            guard let viewController else { return }
            
            var timeLeft = duration
            viewController.reloadTimerLabel.isHidden = false
            viewController.reloadTimerLabel.text = "\(timeLeft)"
            
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak viewController] timer in
                guard let viewController else { return }
                
                viewController.reloadTimerLabel.text = "\(timeLeft)"
                
                if timeLeft <= 0 {
                    timer.invalidate()
                    completion?()
                }
                timeLeft -= 1
            }
        }
    }
}

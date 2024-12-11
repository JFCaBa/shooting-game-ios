//
//  Configuration.swift
//  ShootingApp
//
//  Created by Jose on 29/11/2024.
//

import Foundation

extension OnboardingSheetViewController {
    struct Configuration {
        var title: String = ""
        var subtitle: String = ""
        var onboardingItems: [OnboardingItem] = []
        var presented: Bool = false
    }
}

extension OnboardingSheetViewController.Configuration {
    struct OnboardingItem {
        var title: String
        var subtitle: String
        var image: String
    }
}

extension OnboardingSheetViewController.Configuration {
    static var home: Self {
        var configuration = OnboardingSheetViewController.Configuration()
        configuration.title = "Welcome to ShootingApp"
        configuration.onboardingItems = [
            OnboardingItem(title: "Real-Time Combat", subtitle: "Engage in augmented reality battles with players around you.", image: "scope"),
            OnboardingItem(title: "Stats Tracking", subtitle: "Monitor your hits, kills and drone captures in real-time.", image: "chart.xyaxis.line"),
            OnboardingItem(title: "Drone Hunting", subtitle: "Find and capture drones to earn extra tokens.", image: "drone"),
            OnboardingItem(title: "Health System", subtitle: "Manage your health and ammo carefully to survive longer.", image: "heart.fill")
        ]
        let key = "onboarding_sheet_home"
        configuration.presented = UserDefaults.standard.bool(forKey: key)
        UserDefaults.standard.set(true, forKey: key)
        return configuration
    }
    
    static var achievements: Self {
        var configuration = OnboardingSheetViewController.Configuration()
        configuration.title = "Achievements"
        configuration.onboardingItems = [
            OnboardingItem(title: "Kill Milestones", subtitle: "Unlock achievements at 10, 50, 100, 500, and 1000 kills.", image: "target"),
            OnboardingItem(title: "Hit Accuracy", subtitle: "Track your precision with hit achievements at 100, 500, and 1000 hits.", image: "scope"),
            OnboardingItem(title: "Token Rewards", subtitle: "Earn SHOT for each achievement you unlock and exchange them for $SHOT you can send to your Metamask wallet.", image: "bitcoinsign.circle")
        ]
        let key = "onboarding_sheet_achievements"
        configuration.presented = UserDefaults.standard.bool(forKey: key)
        UserDefaults.standard.set(true, forKey: key)
        return configuration
    }
    
    static var hallOfFame: Self {
        var configuration = OnboardingSheetViewController.Configuration()
        configuration.title = "Hall of Fame"
        configuration.onboardingItems = [
            OnboardingItem(title: "Top Players", subtitle: "Compete to be among the best players ranked by kills and hits.", image: "trophy.fill"),
            OnboardingItem(title: "Stats Display", subtitle: "View detailed stats including kills, hits, and drone captures.", image: "list.number"),
            OnboardingItem(title: "Weekly Rankings", subtitle: "Rankings are updated in real-time as you play.", image: "chart.bar.fill")
        ]
        let key = "onboarding_sheet_halloffame"
        configuration.presented = UserDefaults.standard.bool(forKey: key)
        UserDefaults.standard.set(true, forKey: key)
        return configuration
    }
}

//
//  NotificationsManager.swift
//  ShootingApp
//
//  Created by Jose on 02/12/2024.
//

import FirebaseMessaging
import UserNotifications
import UIKit

final class NotificationManager: NSObject {
    // MARK: - Constantns
    
    static let shared = NotificationManager()
    
    // MARK: - Properties
    
    private var tokenUpdateHandler: ((String?) -> Void)?
    
    // MARK: - init()
    
    private override init() {
        super.init()
    }
    
    // MARK: - configure(tokenHandler:)
    
    func configure() {
        UNUserNotificationCenter.current().delegate = self
        
        // Only configure if already authorized
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            if settings.authorizationStatus == .authorized {
                self?.requestToken()
            }
        }
    }
    
    // MARK: - requestAuthorization()
    
    func requestAuthorization(completion: @escaping (Bool) -> Void = { _ in }) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            if granted {
                self?.requestToken()
            }
            completion(granted)
        }
    }
    
    private func requestToken() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    // MARK: - handleSilentNotificatoin(_:, completion:)
    
    func handleSilentNotification(_ userInfo: [AnyHashable: Any], completion: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let type = userInfo["notificationType"] as? String else {
            completion(.noData)
            return
        }
        
        switch type {
        case "playerJoined":
            handlePlayerJoined(userInfo)
            
        case "playerNearby":
            handlePlayerNearby(userInfo)
            
        case "achievement":
            handleAchievement(userInfo)
            
        default:
            break
        }
        
        completion(.newData)
    }
    
    // MARK: - handlePlayerJoined(_:)
    
    private func handlePlayerJoined(_ userInfo: [AnyHashable: Any]) {
        let playerId: String
        let latitude: Double
        let longitude: Double
        
        if let playerDataString = userInfo["player"] as? String,
           let data = playerDataString.data(using: .utf8),
           let playerData = try? JSONDecoder().decode(Player.self, from: data) {
            playerId = playerData.id
            latitude = playerData.location.latitude
            longitude = playerData.location.longitude
        } else if let id = userInfo["playerId"],
                  let lat = userInfo["latitude"] as? Double,
                  let lon = userInfo["longitude"] as? Double {
            playerId = String(describing: id)
            latitude = lat
            longitude = lon
        } else {
            return
        }
        
        let distance = LocationManager.shared.distanceFrom(latitude: latitude, longitude: longitude)
        
        guard distance < 1000 else { return }
        
        NotificationCenter.default.post(
            name: .playerJoined,
            object: nil,
            userInfo: [
                "playerId": playerId,
                "latitude": latitude,
                "longitude": longitude,
                "distance": distance
            ]
        )
        
        let content = UNMutableNotificationContent()
        content.title = "Player Nearby!"
        content.body = "New player is \(distance)m away"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - handlePlayerNearby(_:)
    
    private func handlePlayerNearby(_ userInfo: [AnyHashable: Any]) {
        guard let playerName = userInfo["playerName"] as? String,
              let distance = userInfo["distance"] as? Int else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Player Nearby!"
        content.body = "\(playerName) is \(distance)m away"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - handleAchievement(_:)
    
    private func handleAchievement(_ userInfo: [AnyHashable: Any]) {
        guard let achievementName = userInfo["achievementName"] as? String else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Achievement Unlocked!"
        content.body = achievementName
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - User Notification Delegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

// MARK: - MessagingDelegate

extension NotificationManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        tokenUpdateHandler?(token)
    }
}

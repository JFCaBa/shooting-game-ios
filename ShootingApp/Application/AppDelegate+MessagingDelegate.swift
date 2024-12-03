//
//  AppDelegate+MessagingDelegate.swift
//  ShootingApp
//
//  Created by Jose on 02/12/2024.
//

import FirebaseMessaging
import Foundation

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token: \(fcmToken ?? "none")")
    }
}

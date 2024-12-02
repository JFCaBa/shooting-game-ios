import Firebase
import FirebaseMessaging
import UIKit
import UserNotifications

extension AppDelegate {
    func setupNotifications() {
        FirebaseApp.configure()
        NotificationManager.shared.configure()
        
        // Setup Messaging delegate early
        Messaging.messaging().delegate = NotificationManager.shared
        
        // Register for remote notifications immediately
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications:", error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("🔔 Silent notification received")
        print("Payload:", userInfo)
        
        NotificationManager.shared.handleSilentNotification(userInfo) { result in
            print("🔔 Notification handled with result:", result)
            switch result {
            case .newData:
                completionHandler(.newData)
            case .noData:
                completionHandler(.noData)
            case .failed:
                completionHandler(.failed)
            @unknown default:
                completionHandler(.noData)
            }
        }
    }
}

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
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications:", error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NotificationManager.shared.handleSilentNotification(userInfo, completion: completionHandler)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

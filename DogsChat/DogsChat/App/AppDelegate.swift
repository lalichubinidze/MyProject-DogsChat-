
import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        requestPushNotificationPermission()
        seupUIConfigurations()
        application.registerForRemoteNotifications()
        application.applicationIconBadgeNumber = 0
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    //MARK: - UIConfigurations
    private func seupUIConfigurations() {
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().backgroundColor = UIColor().primary()
        UITabBar.appearance().unselectedItemTintColor = UIColor().tabBarUnselected()
        UITabBar.appearance().tintColor = .white

        UINavigationBar.appearance().barTintColor = UIColor().primary()
        UINavigationBar.appearance().backgroundColor = UIColor().primary()
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().isTranslucent = false
    }

        //MARK: - Push Notifications
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        completionHandler(UIBackgroundFetchResult.newData)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {

        print("unable to register for remote notifications", error.localizedDescription)
    }

    private func  requestPushNotificationPermission() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in})

    }
    private func updateUserPushId(newPushId: String) {

        if let user = FUser.currentUser() {
            user.pushId = newPushId
            user.saveUserLocally()
            user.updateCurrentUserInFireStore(withValues: [kPUSHID : newPushId]) { (error) in
                print("updated user push id with error ", error?.localizedDescription)
            }
        }
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate  {

}
extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("user push id is ", fcmToken)
        updateUserPushId(newPushId: "\(fcmToken!)")
    }
}


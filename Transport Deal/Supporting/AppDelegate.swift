//
//  AppDelegate.swift
//  swift-login-system-tutorial
//
//  Created by YouTube on 2022-10-26.
//

import UIKit
import Stripe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Create the main window
        StripeAPI.defaultPublishableKey = "pk_test_51LrKnIHO7XYPxtMQsdadtOwqMnl0uyzMXrFXUEkL3pWdFigWqK03pJ6WAoKvomFnoeHoLbQRS6vEy8P95qaDbrvX00igm9kbNA"
               // do any other necessary launch configuration
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let loginController = LoginController()
        let navController = UINavigationController(rootViewController: loginController)
        
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        
        return true
    }
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


//
//  AppDelegate.swift
//  Sluggo
//
//  Created by Isaac Trimble-Pederson on 4/8/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        configureInitialViewController()
        return true
    }

    // https://stackoverflow.com/questions/33714671/value-of-type-appdelegate-has-no-member-window
    func configureInitialViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController: UIViewController

        window = UIWindow()
        let identity = AppIdentity.loadFromDisk() ?? AppIdentity()

        initialViewController = storyboard.instantiateViewController(identifier: "launchView", creator: { coder in
            return LaunchViewController(coder: coder, identity: identity)
        })
        window!.rootViewController = initialViewController
        window!.makeKeyAndVisible()
        
        // If any windows exist below, delete them
        if(!(UIApplication.shared.windows.first == window)) {
            UIApplication.shared.windows[0].dismiss()
        }
    }

    // MARK: UISceneSession Lifecycle

//    func application(_ application: UIApplication,
//                     configurationForConnecting connectingSceneSession: UISceneSession,
//                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running,
//        // this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes,
//        // as they will not return.
//    }

}

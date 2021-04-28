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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        configureInitialViewController()
        return true
    }
    
    // https://stackoverflow.com/questions/33714671/value-of-type-appdelegate-has-no-member-window
    private func configureInitialViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController: UIViewController
    
        window = UIWindow()
        let identity = AppIdentity.loadFromDisk() ?? AppIdentity()
        
        // TODO: for testing purposes, the team for the identity is hardcoded. Change this eventually :)
        identity.team = TeamRecord(id: 1, name: "bugslotics", object_uuid: UUID(), ticket_head: 1,
                                        created: Date(), activated: nil, deactivated: nil)
        
        initialViewController = storyboard.instantiateViewController(identifier: "launchView", creator: { coder in
            return LaunchViewController(coder: coder, identity: identity)
        })
        window!.rootViewController = initialViewController
        window!.makeKeyAndVisible()
    }

    // MARK: UISceneSession Lifecycle

//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }

}


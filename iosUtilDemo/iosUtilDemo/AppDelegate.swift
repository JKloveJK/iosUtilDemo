//
//  AppDelegate.swift
//  iosUtilDemo
//
//  Created by Jiankai Lei on 2025/2/5.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MainTabbarViewController()
        window?.makeKeyAndVisible()
        
        return true
    }


}


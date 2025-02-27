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
    private var launchScreenViewController: LaunchScreenViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        launchScreenViewController = LaunchScreenViewController()
        window?.rootViewController = launchScreenViewController
        window?.makeKeyAndVisible()
        
        // 延迟加载主界面
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.showMainInterface()
        }
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
    
    private func showMainInterface() {
        // 创建主界面（这里假设使用TabBarController作为根控制器）
        let tabBarController = MainTabbarViewController()
        
        // 使用转场动画
        UIView.transition(with: window!,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in
            self?.window?.rootViewController = tabBarController
        }, completion: { [weak self] _ in
            // 释放启动屏控制器
            self?.launchScreenViewController = nil
        })
    }


}


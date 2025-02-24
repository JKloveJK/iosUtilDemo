//
//  MainTabbarViewController.swift
//  iosUtilDemo
//
//  Created by Jiankai Lei on 2025/2/18.
//

import Foundation
import UIKit

class MainTabbarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupAppearance()
        
        // Tabbar 默认是懒加载，需要显示触发一下view的渲染
        viewControllers?.forEach { viewController in
            if let navController = viewController as? UINavigationController {
                // 强制加载导航控制器的视图
                _ = navController.view
                // 强制加载根视图控制器的视图
                _ = navController.topViewController?.view
            }
        }
    }
    
    private func setupViewControllers() {
        let homeVC = HomeViewController()
        let contactsVC = ContactViewController()
        let discoverVC = DiscoverViewController()
        let meVC = MeViewController()
        
        let homeNav = UINavigationController(rootViewController: homeVC)
        let contactsNav = UINavigationController(rootViewController: contactsVC)
        let discoverNav = UINavigationController(rootViewController: discoverVC)
        let meNav = UINavigationController(rootViewController: meVC)
        
        viewControllers = [homeNav, contactsNav, discoverNav, meNav]
        
    }
    
    private func setupAppearance() {
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.backgroundColor = .white.withAlphaComponent(0.4)
            
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor.black
            ]
            
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor.green
            ]
            
            tabBar.tintColor = .systemGreen
            tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
        } else {
            tabBar.tintColor = .systemGreen
            tabBar.barTintColor = .white
            tabBar.unselectedItemTintColor = .gray
        }
    }
}

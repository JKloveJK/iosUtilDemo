//
//  BaseTabbarViewController.swift
//  iosUtilDemo
//
//  Created by Jiankai Lei on 2025/2/18.
//

import Foundation
import UIKit

class BaseTabbarViewController: UIViewController {
    /// tab 标题
    var tabTitle: String {
        return ""  // 子类重写这个属性
    }
    
    /// tab 普通状态图标名称
    var tabNormalImageName: String {
        return ""  // 子类重写这个属性
    }
    
    /// tab 选中状态图标名称
    var tabSelectedImageName: String {
        return ""  // 子类重写这个属性
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBasicUI()
        setupTabBarItem()
    }
    
    // MARK: - Private Methods
    
    private func setupBasicUI() {
        view.backgroundColor = .white
        title = tabTitle  // 设置导航栏标题
    }
    
    private func setupTabBarItem() {
        // 设置 tabBar 图标和标题
        tabBarItem = UITabBarItem(
            title: tabTitle,
            image: UIImage(named: tabNormalImageName)?.withRenderingMode(.alwaysOriginal).resize(to: .init(width: 25, height: 25)),
            selectedImage: UIImage(named: tabSelectedImageName)?.withRenderingMode(.alwaysOriginal).resize(to: .init(width: 25, height: 25))
        )
    }
}

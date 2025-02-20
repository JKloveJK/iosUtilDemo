//
//  HomeViewController.swift
//  iosUtilDemo
//
//  Created by Jiankai Lei on 2025/2/18.
//

import Foundation
import UIKit
import SnapKit

class HomeViewController: BaseTabbarViewController {
    
    private var dropdownView: UIView?
    private var backgroundView: UIView?
    
    override var tabTitle: String {
        return "微信"
    }
    
//    override var tabTitle: String {
//        return "首页"
//    }
    
    override var tabNormalImageName: String {
        return "tab_home"
    }
    
    override var tabSelectedImageName: String {
        return "tab_home"
    }
    
    private var unreadCount: Int = 0 {
        didSet {
            updateNavTitle()
            updateBadge()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateBadge()
        setupNav()
    }
}

// MARK: UI
extension HomeViewController {
    private func updateNavTitle() {
        if unreadCount > 0 {
            self.navigationItem.title = "微信(\(unreadCount))"
        } else {
            self.navigationItem.title = "微信"
        }
    }
    
    private func updateBadge() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.unreadCount > 0 {
                self.tabBarItem.badgeValue = "\(self.unreadCount)"
                
                // iOS 13 及以上可以设置气泡的颜色
                if #available(iOS 13.0, *) {
                    self.tabBarItem.badgeColor = .red
                }
            } else {
                self.tabBarItem.badgeValue = nil
            }
        }
        if self.unreadCount > 0 {
            self.tabBarItem.badgeValue = "\(self.unreadCount)"
            
            // iOS 13 及以上可以设置气泡的颜色
            if #available(iOS 13.0, *) {
                self.tabBarItem.badgeColor = .red
            }
        } else {
            self.tabBarItem.badgeValue = nil
        }
    }
    
    func updateUnreadCount(_ count: Int) {
        unreadCount = count
    }
    
    private func setupNavigationItem() {
        let addButton = UIButton(type: .system)
        addButton.setImage(UIImage(named: "add")?.resize(to: .init(width: 24, height: 24)), for: .normal)
        addButton.addTarget(self, action: #selector(showDropdownMenu), for: .touchUpInside)
        addButton.tintColor = .black
        addButton.snp.makeConstraints { make in
            make.width.height.equalTo(44)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
    }
    
    @objc private func showDropdownMenu() {
        if dropdownView != nil {
            hideDropdownMenu()
            return
        }
        
        guard let addButton = navigationItem.rightBarButtonItem?.customView,
              let window = UIApplication.shared.windows.first else { return }
        let addButtonFrame = addButton.convert(addButton.bounds, to: window)
        
        let triangleHeight: CGFloat = 8
        
        let menuView = UIView()
        menuView.backgroundColor = UIColor(hex: "#4c4c4c")
        menuView.layer.cornerRadius = 8
        menuView.layer.shadowColor = UIColor.black.cgColor
        menuView.layer.shadowOffset = CGSize(width: 0, height: 2)
        menuView.layer.shadowRadius = 4
        menuView.layer.shadowOpacity = 0.1
        view.addSubview(menuView)
        self.dropdownView = menuView
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideDropdownMenu))
        let bgView = UIView()
        bgView.backgroundColor = .clear
        bgView.addGestureRecognizer(tapGesture)
        
        view.addSubview(bgView)
        self.backgroundView = bgView
        
        let triangleView = TriangleView(fillColor: UIColor(hex: "#4c4c4c"))
        menuView.addSubview(triangleView)
        
        menuView.snp.makeConstraints { make in
            make.top.equalTo(navigationController?.navigationBar.snp.bottom ?? view.snp.top).offset(10)
            make.right.equalTo(view).offset(-10)
            make.width.equalTo(130)
            make.height.equalTo(224)
        }
        
        // 设置三角形位置
        triangleView.snp.makeConstraints { make in
            make.bottom.equalTo(menuView.snp.top)
            make.right.equalTo(menuView).offset(-20)
            make.width.equalTo(16)
            make.height.equalTo(triangleHeight)
        }
        
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let menuItems = [
            ("发起群聊", "group_chat"),
            ("添加好友", "add_friend"),
            ("扫一扫", "scan"),
            ("收付款", "payment")
        ]
        
        var previousButton: UIButton?
        
        for (index, item) in menuItems.enumerated() {
            let button = createMenuView(title: item.0, imageName: item.1, tag: index)
            menuView.addSubview(button)
            
            button.snp.makeConstraints { make in
                if let previousButton = previousButton {
                    make.top.equalTo(previousButton.snp.bottom)
                } else {
                    make.top.equalTo(menuView)
                }
                make.left.right.equalTo(menuView)
                make.height.equalTo(56)
            }
            
            previousButton = button
        }
        
        menuView.transform = CGAffineTransform(translationX: 0, y: -10)
        menuView.alpha = 0
        
        UIView.animate(withDuration: 0.2) {
            self.dropdownView?.transform = .identity
            self.dropdownView?.alpha = 1
        }
    }
    
    private func createMenuView(title: String, imageName: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.tag = tag
        
        // 创建图标
        let imageView = UIImageView(image: UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = .white
        button.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        // 创建标题
        let label = UILabel(frame: CGRect(x: 45, y: 0, width: 90, height: 56))
        label.text = title
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        button.addSubview(label)
        label.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
        
        button.addTarget(self, action: #selector(menuItemTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    private func setupNav() {
        updateNavTitle()
        setupNavigationItem()
    }
    
    @objc private func hideDropdownMenu() {
        UIView.animate(withDuration: 0.2, animations: {
            self.dropdownView?.transform = CGAffineTransform(translationX: 0, y: -10)
            self.dropdownView?.alpha = 0
            self.backgroundView?.alpha = 0
        }) { _ in
            self.dropdownView?.removeFromSuperview()
            self.dropdownView = nil
            self.backgroundView?.removeFromSuperview()
            self.backgroundView = nil
        }
    }
    
    @objc private func menuItemTapped(_ sender: UIButton) {
        hideDropdownMenu()
        
        // 处理菜单项点击
        switch sender.tag {
        case 0:
            print("发起群聊")
            // TODO: 实现发起群聊功能
        case 1:
            print("添加好友")
            // TODO: 实现添加好友功能
        case 2:
            print("扫一扫")
            // TODO: 实现扫一扫功能
        case 3:
            print("收付款")
            // TODO: 实现收付款功能
        default:
            break
        }
    }
}

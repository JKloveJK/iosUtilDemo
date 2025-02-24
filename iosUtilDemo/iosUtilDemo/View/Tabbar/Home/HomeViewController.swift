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
    
    private let viewModel = HomeViewModel()
    private var dropdownView: UIView?
    private var backgroundView: UIView?
    private var confirmingIndexPath: IndexPath?
    
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
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ConversationCell.self, forCellReuseIdentifier: "ConversationCell")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 76, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = "搜索"
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.delegate = self
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadData()
    }
}

// MARK: UI
extension HomeViewController {
    private func bindViewModel() {
        // 监听数据变化
        viewModel.onConversationsChanged = { [weak self] in
            self?.tableView.reloadData()
        }
        
        // 监听未读数变化
        viewModel.onUnreadCountChanged = { [weak self] count in
            self?.updateNavTitle(count: count)
            self?.updateBadge(count: count)
        }
    }
    
    private func setupUI() {
        setupNav()
        setupTableView()
        setupSearchBar()
    }
    
    private func updateNavTitle(count: Int) {
        if count > 0 {
            self.navigationItem.title = "微信(\(count))"
        } else {
            self.navigationItem.title = "微信"
        }
    }
    
    private func updateBadge(count: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if count > 0 {
                self.tabBarItem.badgeValue = "\(count)"
                if #available(iOS 13.0, *) {
                    self.tabBarItem.badgeColor = .red
                }
            } else {
                self.tabBarItem.badgeValue = nil
            }
        }
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
//        updateNavTitle()
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
    
    private func setupTableView() {
        view.backgroundColor = .red
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
            make.left.top.right.bottom.equalToSuperview()
        }
    }
    
    private func setupSearchBar() {
        // 设置搜索栏
        navigationItem.searchController = searchController
        // 滚动时是否隐藏搜索栏
        navigationItem.hidesSearchBarWhenScrolling = true
        
        // 定义搜索栏的样式
        let searchBar = searchController.searchBar
        // 设置搜索栏样式
        searchBar.tintColor = .systemBlue           // 设置光标和按钮颜色
        searchBar.barTintColor = .white             // 设置背景色
        
        // 设置取消按钮文字（本地化支持）
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "取消"
        
        // 设置搜索框样式
        let searchField = searchBar.searchTextField
        searchField.backgroundColor = UIColor(hex: "#F5F5F5")  // 设置搜索框背景色
        // 设置占位符文字及其样式
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 14)
        ]
        searchField.attributedPlaceholder = NSAttributedString(
            string: "搜索",
            attributes: attributes
        )
        
        // 设置搜索框圆角
        searchField.layer.cornerRadius = 8
        searchField.clipsToBounds = true
        
        // 设置文本颜色和字体
        searchField.textColor = .black
        searchField.font = .systemFont(ofSize: 14)
    }
}

// MARK: tableview delegate
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
        let conversation = viewModel.conversations[indexPath.row]
        cell.configure(with: conversation)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let conversation = viewModel.conversations[indexPath.row]
        let detailVC = ChatDetailViewController(conversation: conversation)
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // 左滑删除
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "删除") { [weak self] (_, _, completion) in
            self?.viewModel.deleteConversation(at: indexPath.row)
            completion(true)
        }
        
        let pinAction = UIContextualAction(style: .normal, title: "置顶") { [weak self] (_, _, completion) in
            self?.viewModel.togglePin(at: indexPath.row)
            completion(true)
        }
        pinAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [deleteAction, pinAction])
    }
}

// MARK: searchDelegate
extension HomeViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // 开始编辑时的处理
        print("开始搜索")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // 搜索文本改变时的处理
        print("搜索文本：\(searchText)")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 点击搜索按钮时的处理
        print("点击搜索按钮")
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // 点击取消按钮时的处理
        print("取消搜索")
    }
}

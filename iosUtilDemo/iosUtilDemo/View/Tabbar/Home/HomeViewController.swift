//
//  HomeViewController.swift
//  iosUtilDemo
//
//  Created by Jiankai Lei on 2025/2/18.
//

import Foundation
import UIKit
import SnapKit

struct Conversation {
    let avatar: String
    let name: String
    let lastMessage: String
    let time: Date
    var unreadCount: Int
    var isPinned: Bool
}

class HomeViewController: BaseTabbarViewController {
    
    private var conversations: [Conversation] = [] {
        didSet {
            conversations.sort { (conv1, conv2) in
                if conv1.isPinned != conv2.isPinned {
                    return conv1.isPinned
                }
                
                return conv1.time > conv2.time
            }
        }
    }
    
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
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ConversationCell.self, forCellReuseIdentifier: "ConversationCell")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 76, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: UI
extension HomeViewController {
    private func setupUI() {
        updateBadge()
        setupNav()
        setupTableView()
        loadMockData()
    }
    
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
    
    private func setupTableView() {
        view.backgroundColor = .red
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
            make.left.top.right.bottom.equalToSuperview()
        }
    }
    
    private func loadMockData() {
        let mockData: [Conversation] = [
            // 置顶会话
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=tech_group", name: "技术群", lastMessage: "谁改了我的代码？", time: Date().addingTimeInterval(-3600), unreadCount: 99, isPinned: true),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=product_group", name: "产品需求群", lastMessage: "这个需求很简单，下班前做完", time: Date().addingTimeInterval(-7200), unreadCount: 50, isPinned: true),
            
            // 普通会话
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=zhang", name: "张三", lastMessage: "晚上一起吃饭吗？", time: Date().addingTimeInterval(-1800), unreadCount: 1, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=li", name: "李四", lastMessage: "项目进度如何了？", time: Date().addingTimeInterval(-5400), unreadCount: 3, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=weekend", name: "周末加班群", lastMessage: "这周末能不加班吗？", time: Date().addingTimeInterval(-9000), unreadCount: 12, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=design", name: "设计组", lastMessage: "新的UI设计稿已经上传", time: Date().addingTimeInterval(-12600), unreadCount: 5, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=test", name: "测试组", lastMessage: "发现一个严重bug", time: Date().addingTimeInterval(-16200), unreadCount: 8, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=ops", name: "运维组", lastMessage: "服务器需要更新", time: Date().addingTimeInterval(-19800), unreadCount: 2, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=market", name: "市场部", lastMessage: "新产品推广方案", time: Date().addingTimeInterval(-23400), unreadCount: 0, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=hr", name: "人事部", lastMessage: "关于年终奖的通知", time: Date().addingTimeInterval(-27000), unreadCount: 1, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=finance", name: "财务部", lastMessage: "报销单据已审批", time: Date().addingTimeInterval(-30600), unreadCount: 0, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=frontend", name: "前端小组", lastMessage: "API文档更新了吗", time: Date().addingTimeInterval(-34200), unreadCount: 15, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=backend", name: "后端小组", lastMessage: "数据库优化完成", time: Date().addingTimeInterval(-37800), unreadCount: 7, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=mobile", name: "移动开发组", lastMessage: "新版本已提交审核", time: Date().addingTimeInterval(-41400), unreadCount: 4, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=wang", name: "王五", lastMessage: "文档我已经看完了", time: Date().addingTimeInterval(-45000), unreadCount: 0, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=zhao", name: "赵六", lastMessage: "明天开会记得带电脑", time: Date().addingTimeInterval(-48600), unreadCount: 2, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=notice", name: "公司公告", lastMessage: "关于端午节放假安排", time: Date().addingTimeInterval(-52200), unreadCount: 1, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=team", name: "团建群", lastMessage: "这周六去爬山", time: Date().addingTimeInterval(-55800), unreadCount: 20, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=intern", name: "实习生群", lastMessage: "实习报告记得提交", time: Date().addingTimeInterval(-59400), unreadCount: 3, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=support", name: "客户支持", lastMessage: "客户反馈已处理", time: Date().addingTimeInterval(-63000), unreadCount: 6, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=product_exp", name: "产品体验群", lastMessage: "新功能测试反馈", time: Date().addingTimeInterval(-66600), unreadCount: 9, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=system", name: "系统通知", lastMessage: "您的账号有异常登录", time: Date().addingTimeInterval(-70200), unreadCount: 1, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=security", name: "安全组", lastMessage: "漏洞修复确认", time: Date().addingTimeInterval(-73800), unreadCount: 4, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=architect", name: "架构组", lastMessage: "技术方案讨论", time: Date().addingTimeInterval(-77400), unreadCount: 7, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=data", name: "数据组", lastMessage: "数据分析报告", time: Date().addingTimeInterval(-81000), unreadCount: 2, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=algorithm", name: "算法组", lastMessage: "模型优化完成", time: Date().addingTimeInterval(-84600), unreadCount: 5, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=operation", name: "运营部", lastMessage: "活动数据统计", time: Date().addingTimeInterval(-88200), unreadCount: 0, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=business", name: "商务部", lastMessage: "合作方案已发送", time: Date().addingTimeInterval(-91800), unreadCount: 1, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=legal", name: "法务部", lastMessage: "合同审核完成", time: Date().addingTimeInterval(-95400), unreadCount: 0, isPinned: false),
            Conversation(avatar: "https://api.dicebear.com/7.x/avataaars/png?seed=admin", name: "行政部", lastMessage: "办公用品申请", time: Date().addingTimeInterval(-99000), unreadCount: 3, isPinned: false)
        ]
        
        conversations = mockData
        tableView.reloadData()
    }
}

// MARK: tableview delegate
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
        let conversation = conversations[indexPath.row]
        cell.configure(with: conversation)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: 跳转到聊天详情页
    }
    
    // 左滑删除
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "删除") { [weak self] (action, view, completion) in
            self?.conversations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        
        let pinAction = UIContextualAction(style: .normal, title: "置顶") { [weak self] (action, view, completion) in
            guard let self = self else { return }
            var conversation = self.conversations[indexPath.row]
            conversation.isPinned.toggle()
            self.conversations[indexPath.row] = conversation
            // TODO: 重新排序会话列表
            completion(true)
        }
        pinAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [deleteAction, pinAction])
    }
}

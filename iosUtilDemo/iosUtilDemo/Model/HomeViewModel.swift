//
//  HomeViewModel.swift
//  iosUtilDemo
//
//  Created by Jiankai Lei on 2025/2/24.
//

import Foundation

struct Conversation: Equatable {
    let avatar: String
    let name: String
    let lastMessage: String
    let time: Date
    var unreadCount: Int
    var isPinned: Bool
    
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        return lhs.avatar == rhs.avatar &&
        lhs.name == rhs.name
    }
}

class HomeViewModel {
    // 使用自定义的setter方法避免死循环
    private var _conversations: [Conversation] = []
    var conversations: [Conversation] {
        get { _conversations }
        set {
            _conversations = newValue
            sortConversations()
            updateUnreadCount()
            onConversationsChanged?()
        }
    }
    
    private(set) var unreadCount: Int = 0 {
        didSet {
            // 通知UI更新未读数
            onUnreadCountChanged?(unreadCount)
        }
    }
    
    var onConversationsChanged: (() -> Void)?
    var onUnreadCountChanged: ((Int) -> Void)?
    
    func loadData() {
        conversations = mockConversations()
//        sortConversations()
    }
    
    func deleteConversation(at index: Int) {
        conversations.remove(at: index)
//        sortConversations()
    }
    
    func togglePin(at index: Int) {
        var conversation = conversations[index]
        conversation.isPinned.toggle()
        conversations[index] = conversation
        /*sortConversations() */      // 单独排序
    }
    
    private func sortConversations() {
        // 直接操作存储属性，不触发setter
        _conversations.sort { (conv1, conv2) in
            if conv1.isPinned != conv2.isPinned {
                return conv1.isPinned
            }
            return conv1.time > conv2.time
        }
        // 排序后手动触发UI更新
        onConversationsChanged?()
    }
    
    private func updateUnreadCount() {
        let totalUnreadCount = conversations.reduce(0) { $0 + $1.unreadCount }
        unreadCount = totalUnreadCount
    }
    
    private func mockConversations() -> [Conversation] {
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
        return mockData
    }
}

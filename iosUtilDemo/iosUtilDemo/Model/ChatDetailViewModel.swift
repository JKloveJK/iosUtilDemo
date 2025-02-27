//
//  ChatDetailModel.swift
//  iosUtilDemo
//
//  Created by Jiankai Lei on 2025/2/24.
//

import Foundation

class ChatDetailViewModel {
    private(set) var messages: [Message] = []
    let conversation: Conversation
    
    init(conversation: Conversation) {
        self.conversation = conversation
        loadMessages()
    }
    
    private func loadMessages() {
        let calendar = Calendar.current
        let now = Date()
        // 模拟消息数据
        messages = [
            // 早上的对话
            Message(
                id: "1",
                content: "早上好！今天天气不错 ☀️",
                isSelf: true,
                time: calendar.date(byAdding: .hour, value: -8, to: now)!,
                avatarUrl: UserInfo.shared.avatarUrl
            ),
            Message(
                id: "2",
                content: "是啊，适合出去走走",
                isSelf: false,
                time: calendar.date(byAdding: .hour, value: -8, to: now)!.addingTimeInterval(120),
                avatarUrl: conversation.avatar
            ),
            
            // 上午的工作对话
            Message(
                id: "3",
                content: "关于下午的项目会议，我们需要准备哪些材料？",
                isSelf: true,
                time: calendar.date(byAdding: .hour, value: -6, to: now)!,
                avatarUrl: UserInfo.shared.avatarUrl
            ),
            Message(
                id: "4",
                content: "主要是上周的项目进度报告和下一阶段的计划书，我已经整理好了一部分，待会发给你",
                isSelf: false,
                time: calendar.date(byAdding: .hour, value: -6, to: now)!.addingTimeInterval(300),
                avatarUrl: conversation.avatar
            ),
            Message(
                id: "5",
                content: "好的，收到后我再补充一下技术方案部分",
                isSelf: true,
                time: calendar.date(byAdding: .hour, value: -6, to: now)!.addingTimeInterval(500),
                avatarUrl: UserInfo.shared.avatarUrl
            ),
            
            // 中午休息时间
            Message(
                id: "6",
                content: "午饭时间到了，要一起去吃饭吗？🍱",
                isSelf: false,
                time: calendar.date(byAdding: .hour, value: -4, to: now)!,
                avatarUrl: conversation.avatar
            ),
            Message(
                id: "7",
                content: "抱歉，我这边还在处理一个紧急问题，你们先去吧 😅",
                isSelf: true,
                time: calendar.date(byAdding: .hour, value: -4, to: now)!.addingTimeInterval(180),
                avatarUrl: UserInfo.shared.avatarUrl
            ),
            
            // 下午的讨论
            Message(
                id: "8",
                content: "刚才会议讨论的新功能，我觉得可以这样实现...",
                isSelf: true,
                time: calendar.date(byAdding: .hour, value: -2, to: now)!,
                avatarUrl: UserInfo.shared.avatarUrl
            ),
            Message(
                id: "9",
                content: "这个方案不错，但是我们需要考虑一下性能优化的问题",
                isSelf: false,
                time: calendar.date(byAdding: .hour, value: -2, to: now)!.addingTimeInterval(400),
                avatarUrl: conversation.avatar
            ),
            Message(
                id: "10",
                content: "对的，我们可以先做一个性能测试，看看具体的数据表现",
                isSelf: true,
                time: calendar.date(byAdding: .hour, value: -2, to: now)!.addingTimeInterval(600),
                avatarUrl: UserInfo.shared.avatarUrl
            ),
            
            // 最近的消息
            Message(
                id: "11",
                content: "今天辛苦了，项目进展很顺利 👍",
                isSelf: false,
                time: calendar.date(byAdding: .minute, value: -30, to: now)!,
                avatarUrl: conversation.avatar
            ),
            Message(
                id: "12",
                content: "是的，团队配合得很好。明天继续加油！💪",
                isSelf: true,
                time: calendar.date(byAdding: .minute, value: -25, to: now)!,
                avatarUrl: UserInfo.shared.avatarUrl
            )
        ]
    }
    
    func sendMessage(_ text: String) {
        let newMessage = Message(
            id: UUID().uuidString,
            content: text,
            isSelf: true,
            time: Date(),
            avatarUrl: UserInfo.shared.avatarUrl
        )
        messages.append(newMessage)
    }
}

struct Message: Identifiable {
    let id: String
    let content: String
    let isSelf: Bool
    let time: Date
    let avatarUrl: String
}

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
        // 模拟消息数据
        messages = [
            Message(id: "1", content: "你好，今天有什么安排？", isSelf: true, time: Date().addingTimeInterval(-3600)),
            Message(id: "2", content: "下午有个会议，需要准备材料", isSelf: false, time: Date().addingTimeInterval(-1800)),
            Message(id: "3", content: "好的，我马上准备", isSelf: true, time: Date())
        ]
    }
    
    func sendMessage(_ text: String) {
        let newMessage = Message(
            id: UUID().uuidString,
            content: text,
            isSelf: true,
            time: Date()
        )
        messages.append(newMessage)
    }
}

struct Message: Identifiable {
    let id: String
    let content: String
    let isSelf: Bool
    let time: Date
}

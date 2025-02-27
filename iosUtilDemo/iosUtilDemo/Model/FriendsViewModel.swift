//
//  FriendsViewModel.swift
//  iosUtilDemo
//
//  Created by Jiankai Lei on 2025/2/25.
//

import Foundation

struct Friend: Identifiable {
    let id: String
    let name: String
    let avatar: String
    let remark: String?
    let pinyin: String  // 用于排序的拼音
    
    var displayName: String {
        return remark ?? name
    }
}

struct FriendsSection: Identifiable {
    let id: String  // 首字母
    let title: String
    var friends: [Friend]
}

class FriendsViewModel {
    var sections: [FriendsSection] = []
    var searchText: String = ""
    
    private var allFriends: [Friend] = []
    
    init() {
        loadMockData()
        generateSections()
    }
    
    private func loadMockData() {
        // 模拟数据
        allFriends = [
            Friend(id: "1", name: "张三", avatar: "avatar1", remark: "技术总监", pinyin: "zhangsan"),
            Friend(id: "2", name: "李四", avatar: "avatar2", remark: nil, pinyin: "lisi"),
            Friend(id: "3", name: "王五", avatar: "avatar3", remark: "产品经理", pinyin: "wangwu"),
            Friend(id: "4", name: "赵六", avatar: "avatar4", remark: nil, pinyin: "zhaoliu"),
            Friend(id: "5", name: "Alice", avatar: "avatar5", remark: "UI设计师", pinyin: "alice"),
            Friend(id: "6", name: "Bob", avatar: "avatar6", remark: nil, pinyin: "bob")
        ]
    }
    
    private func generateSections() {
        let grouped = Dictionary(grouping: allFriends) { friend -> String in
            guard let first = friend.pinyin.uppercased().first else { return "#" }
            let firstLetter = String(first)
            // 使用Character的isLetter属性判断
            return first.isLetter ? firstLetter : "#"
        }
        
        sections = grouped.keys.sorted().map { key in
            let sortedFriends = grouped[key]?.sorted { $0.pinyin < $1.pinyin } ?? []
            return FriendsSection(id: key, title: key, friends: sortedFriends)
        }
        
        // 将#号分组移到最后
        if let index = sections.firstIndex(where: { $0.id == "#" }) {
            let hashSection = sections.remove(at: index)
            sections.append(hashSection)
        }
    }
}

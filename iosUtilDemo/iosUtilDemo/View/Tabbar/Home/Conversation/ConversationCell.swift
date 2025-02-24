//
//  ConversationCell.swift
//  iosUtilDemo
//
//  Created by Jiankai Lei on 2025/2/20.
//

import Foundation
import UIKit
import Kingfisher

class ConversationCell: UITableViewCell {
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "loading")
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()
    
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .red
        label.textColor = .white
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.layer.cornerRadius = 8  // 改小一点更适合放在头像角落
        label.clipsToBounds = true
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(badgeLabel)
        
        avatarImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(56)
        }
        
        badgeLabel.snp.makeConstraints { make in
            make.right.equalTo(avatarImageView).offset(4)
            make.top.equalTo(avatarImageView).offset(-4)
            make.width.height.equalTo(16)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView.snp.right).offset(12)
            make.top.equalTo(avatarImageView).offset(8)
            make.right.equalTo(timeLabel.snp.left).offset(-12)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.bottom.equalTo(avatarImageView).offset(-8)
            make.right.lessThanOrEqualToSuperview().offset(-16)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel)
            make.right.equalToSuperview().offset(-16)
        }
    }
    
    func configure(with conversation: Conversation) {
        //        avatarImageView.image = UIImage(named: conversation.avatar)
        if let url = URL(string: conversation.avatar) {
            avatarImageView.kf.setImage(with: url, placeholder: UIImage(named: "loading"), options: [
                .transition(.fade(0.2)),          // 淡入淡出动画
                .cacheOriginalImage               // 缓存原始图片
            ])
        }
        nameLabel.text = conversation.name
        messageLabel.text = conversation.lastMessage
        timeLabel.text = formatDate(conversation.time)
        
        if conversation.unreadCount > 0 {
            badgeLabel.isHidden = false
            badgeLabel.text = conversation.unreadCount > 99 ? "99+" : "\(conversation.unreadCount)"
        } else {
            badgeLabel.isHidden = true
        }
        
        if conversation.isPinned {
            backgroundColor = UIColor(white: 0.95, alpha: 1)
        } else {
            backgroundColor = .white
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        // 今天
        if calendar.isDate(date, inSameDayAs: now) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            return timeFormatter.string(from: date)
        }
        
        // 昨天
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(date, inSameDayAs: yesterday) {
            return "昨天"
        }
        
        // 本周其他日期
        if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.locale = Locale(identifier: "zh_CN")
            weekdayFormatter.dateFormat = "EEEE"
            return weekdayFormatter.string(from: date)
        }
        
        // 今年
        if calendar.isDate(date, equalTo: now, toGranularity: .year) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd"
            return dateFormatter.string(from: date)
        }
        
        // 更早
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}

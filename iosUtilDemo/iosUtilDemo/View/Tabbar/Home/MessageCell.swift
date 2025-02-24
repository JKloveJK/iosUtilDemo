//
//  MessageCell.swift
//  iosUtilDemo
//
//  Created by Jiankai Lei on 2025/2/24.
//

import Foundation
import UIKit

class MessageCell: UITableViewCell {
    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
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
        selectionStyle = .none
        contentView.addSubview(bubbleView)
        contentView.addSubview(messageLabel)
        contentView.addSubview(timeLabel)
        
        // 布局代码根据消息方向调整...
    }
    
    func configure(with message: Message) {
        messageLabel.text = message.content
        timeLabel.text = formatDate(message.time)
        
        if message.isSelf {
            // 发送方样式
            bubbleView.backgroundColor = UIColor(hex: "#95ec69")
            // 布局靠右
        } else {
            // 接收方样式
            bubbleView.backgroundColor = .white
            // 布局靠左
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

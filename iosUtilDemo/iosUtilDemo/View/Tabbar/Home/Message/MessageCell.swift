//
//  MessageCell.swift
//  iosUtilDemo
//
//  Created by Jiankai Lei on 2025/2/24.
//

import Foundation
import UIKit
import Kingfisher
import AVFoundation

class MessageCell: UITableViewCell {
    private var audioUrl: URL? = nil
    
    private lazy var voiceView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var voiceButton: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(toggleVoicePlay), for: .touchUpInside)
        return btn
    }()
    
    private lazy var voiceDurationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var voiceWaveView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.animationDuration = 1.0
        iv.animationRepeatCount = 0
        return iv
    }()
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 18  // 圆形头像
        iv.layer.masksToBounds = true
        iv.layer.borderWidth = 0.5
        iv.layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
        return iv
    }()
    
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
    
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(bubbleView)
        contentView.addSubview(avatarImageView)
        bubbleView.addSubview(messageLabel)
        contentView.addSubview(timeLabel)
        
        avatarImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 36, height: 36))
            make.bottom.equalTo(bubbleView)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.centerX.equalToSuperview()
        }
        
        bubbleView.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-8)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.75)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
        }
        
        contentView.addSubview(voiceView)
        voiceView.addSubview(voiceWaveView)
        voiceView.addSubview(voiceDurationLabel)
        voiceView.addSubview(voiceButton)
        
        voiceButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        voiceWaveView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.width.equalTo(20)
            $0.height.equalTo(15)
        }
        
        voiceDurationLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
        }
    }
    
    func configure(with message: Message) {
        switch message.type {
        case .text(let text):
            messageLabel.text = text
            messageLabel.isHidden = false
            voiceView.isHidden = true
        case .voice(let duration, let url):
            configureVoiceView(duration: duration, url: url, isSelf: message.isSelf)
            messageLabel.isHidden = true
            voiceView.isHidden = false
        }
        
        timeLabel.text = formatDate(message.time)
        
        if let url = URL(string: message.avatarUrl) {
            avatarImageView.kf.setImage(with: url)
        } else {
            avatarImageView.image = nil
        }
        
        // 先重置头像约束
        avatarImageView.snp.remakeConstraints { make in
            make.size.equalTo(CGSize(width: 36, height: 36))
            make.bottom.equalTo(bubbleView)
            
            if message.isSelf {
                make.trailing.equalToSuperview().offset(-12)
            } else {
                make.leading.equalToSuperview().offset(12)
            }
        }
        
        // 再设置气泡约束
        bubbleView.snp.remakeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-8)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.75)
            
            if message.isSelf {
                // 发送方：气泡在头像左侧
                make.trailing.equalTo(avatarImageView.snp.leading).offset(-8)
                bubbleView.backgroundColor = UIColor(hex: "#95ec69")
                // 右上+左右下圆角
                bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
            } else {
                // 接收方：气泡在头像右侧
                make.leading.equalTo(avatarImageView.snp.trailing).offset(8)
                bubbleView.backgroundColor = .white
                // 左上+右下圆角
                bubbleView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner]
                bubbleView.layer.borderWidth = 0.5
                bubbleView.layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
            }
        }
        
        // 统一设置圆角
        bubbleView.layer.cornerRadius = 8
        bubbleView.layer.masksToBounds = true
        
        // 时间标签样式
        timeLabel.font = .systemFont(ofSize: 11)
        timeLabel.textColor = UIColor(white: 0.6, alpha: 1)
    }
    
    private func configureVoiceView(duration: TimeInterval, url: URL, isSelf: Bool) {
        audioUrl = url
        voiceDurationLabel.text = "\(Int(duration))''"
        voiceWaveView.image = UIImage(named: isSelf ? "voice_right_3" : "voice_left_3")
//        voiceWaveView.animationImages = (1...3).map {
//            UIImage(named: isSelf ? "voice_right_\($0)" : "voice_left_\($0)")!
//        }
        
        // 布局调整
        if isSelf {
            voiceWaveView.snp.remakeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().offset(-12)
                $0.width.equalTo(20)
                $0.height.equalTo(15)
            }
            voiceDurationLabel.snp.remakeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalTo(voiceWaveView.snp.leading).offset(-8)
            }
        } else {
            voiceWaveView.snp.remakeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalToSuperview().offset(12)
                $0.width.equalTo(20)
                $0.height.equalTo(15)
            }
            voiceDurationLabel.snp.remakeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalTo(voiceWaveView.snp.trailing).offset(8)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    @objc private func toggleVoicePlay() {
        isPlaying.toggle()
        
        isPlaying ? startPlaying() : stopPlaying()
    }
    
    private func startPlaying() {
        voiceWaveView.startAnimating()
        // 实现音频播放逻辑
        if let url = audioUrl {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = self
                audioPlayer?.play()
            } catch {
                print("播放失败: \(error)")
            }
        }
    }
    
    private func stopPlaying() {
        voiceWaveView.stopAnimating()
        audioPlayer?.stop()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopPlaying()
        voiceWaveView.animationImages = nil
        audioUrl = nil
    }
}

extension MessageCell: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPlaying()
    }
}

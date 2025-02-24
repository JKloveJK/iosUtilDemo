//
//  MessageInputBar.swift
//  iosUtilDemo
//
//  Created by Jiankai Lei on 2025/2/24.
//

import Foundation
import UIKit

protocol MessageInputBarDelegate: AnyObject {
    func inputBarDidTapVoiceButton(_ inputBar: MessageInputBar)
    func inputBarDidTapEmojiButton(_ inputBar: MessageInputBar)
    func inputBarDidTapMoreButton(_ inputBar: MessageInputBar)
    func inputBarDidTapSendButton(_ inputBar: MessageInputBar, text: String)
    func inputBarDidStartRecording(_ inputBar: MessageInputBar)
    func inputBarDidFinishRecording(_ inputBar: MessageInputBar)
    func inputBarDidCancelRecording(_ inputBar: MessageInputBar)
}

class MessageInputBar: UIView {
    // MARK: - Properties
    weak var delegate: MessageInputBarDelegate?
    private var isRecording = false
    
    // MARK: - UI Components
    private lazy var voiceButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        btn.tintColor = .darkGray
        btn.addTarget(self, action: #selector(voiceButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var textView: GrowingTextView = {
        let tv = GrowingTextView()
        tv.font = .systemFont(ofSize: 16)
        tv.maxHeight = 100
        tv.layer.cornerRadius = 18
        tv.layer.borderWidth = 0.5
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        tv.enablesReturnKeyAutomatically = true
        tv.returnKeyType = .send
        tv.delegate = self
        return tv
    }()
    
    private lazy var emojiButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "face.smiling"), for: .normal)
        btn.tintColor = .darkGray
        btn.addTarget(self, action: #selector(emojiButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var moreButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        btn.tintColor = .darkGray
        btn.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("发送", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.isHidden = true
        btn.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var voiceInputButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("按住 说话", for: .normal)
        btn.setTitleColor(.darkGray, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15)
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth = 0.5
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.isHidden = true
        btn.addTarget(self, action: #selector(startRecording), for: .touchDown)
        btn.addTarget(self, action: #selector(finishRecording), for: [.touchUpInside, .touchUpOutside])
        btn.addTarget(self, action: #selector(cancelRecording), for: .touchDragExit)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemGroupedBackground
        addSubview(voiceButton)
        addSubview(textView)
        addSubview(emojiButton)
        addSubview(moreButton)
        addSubview(sendButton)
        addSubview(voiceInputButton)
    }
    
    private func setupConstraints() {
        voiceButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(8)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-20) // 对齐安全区域底部
            $0.size.equalTo(36)
        }
        
        textView.snp.makeConstraints {
            $0.left.equalTo(voiceButton.snp.right).offset(8)
            $0.right.equalTo(emojiButton.snp.left).offset(-8)
            $0.top.equalToSuperview().offset(8)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-20) // 对齐安全区域底部
            $0.height.greaterThanOrEqualTo(36)
        }
        
        emojiButton.snp.makeConstraints {
            $0.right.equalTo(moreButton.snp.left).offset(-8)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-20) // 对齐安全区域底部
            $0.size.equalTo(36)
        }
        
        moreButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-8)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-20) // 对齐安全区域底部
            $0.size.equalTo(36)
        }
        
        sendButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-8)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-20) // 对齐安全区域底部
            $0.width.equalTo(60)
            $0.height.equalTo(36)
        }
        
        voiceInputButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.left.equalTo(voiceButton.snp.right).offset(8)
            $0.right.equalTo(emojiButton.snp.left).offset(-8)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-20) // 对齐安全区域底部
        }
        
        // 新增底部填充视图
        let bottomFillView = UIView()
        bottomFillView.backgroundColor = backgroundColor
        addSubview(bottomFillView)
        sendSubviewToBack(bottomFillView)
        
        bottomFillView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
    }
}

// delegate method
extension MessageInputBar {
    @objc private func voiceButtonTapped() {
        let showVoice = voiceInputButton.isHidden
        voiceInputButton.isHidden = !showVoice
        textView.isHidden = showVoice
        sendButton.isHidden = true
        moreButton.isHidden = !showVoice
    }
    
    @objc private func emojiButtonTapped() {
        delegate?.inputBarDidTapEmojiButton(self)
    }
    
    @objc private func moreButtonTapped() {
        delegate?.inputBarDidTapMoreButton(self)
    }
    
    @objc private func sendButtonTapped() {
        guard let text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return }
        delegate?.inputBarDidTapSendButton(self, text: text)
        textView.text = nil
        textViewDidChange(textView)
    }
    
    @objc private func startRecording() {
        isRecording = true
        voiceInputButton.setTitle("松开 结束", for: .normal)
        voiceInputButton.backgroundColor = .lightGray.withAlphaComponent(0.2)
        delegate?.inputBarDidStartRecording(self)
    }
    
    @objc private func finishRecording() {
        guard isRecording else { return }
        isRecording = false
        resetVoiceButton()
        delegate?.inputBarDidFinishRecording(self)
    }
    
    @objc private func cancelRecording() {
        guard isRecording else { return }
        isRecording = false
        resetVoiceButton()
        delegate?.inputBarDidCancelRecording(self)
    }
    
    private func resetVoiceButton() {
        voiceInputButton.setTitle("按住 说话", for: .normal)
        voiceInputButton.backgroundColor = .clear
    }
}

extension MessageInputBar: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        sendButton.isHidden = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        moreButton.isHidden = !sendButton.isHidden
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            sendButtonTapped()
            return false
        }
        return true
    }
}

class GrowingTextView: UITextView {
    var maxHeight: CGFloat = 100
    
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
            layoutIfNeeded()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height = min(maxHeight, size.height)
        return size
    }
}

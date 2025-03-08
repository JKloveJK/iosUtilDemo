//
//  ChatDetailViewController.swift
//  iosUtilDemo
//
//  Created by Jiankai Lei on 2025/2/24.
//

import Foundation
import UIKit

class ChatDetailViewController: UIViewController {
    private let viewModel: ChatDetailViewModel
    private lazy var tableView = UITableView()
    private lazy var inputBar = MessageInputBar()
    
    init(conversation: Conversation) {
        self.viewModel = ChatDetailViewModel(conversation: conversation)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
        setupGesture()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTableViewTap))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTableViewTap() {
        view.endEditing(true)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardNotification(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardNotification(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func handleKeyboardNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }
        
        let isShowing = notification.name == UIResponder.keyboardWillShowNotification
        let keyboardHeight = isShowing ? keyboardFrame.height : 0
        
        let bottomOffset = isShowing ?
        -keyboardHeight + view.safeAreaInsets.bottom :
        0
        
        inputBar.snp.updateConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(bottomOffset)
        }
        
        tableView.snp.updateConstraints {
            $0.bottom.equalTo(inputBar.snp.top)
        }
        
        // 同步键盘动画
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: curve),
            animations: {
                self.view.layoutIfNeeded()
                self.scrollToBottom()
            }
        )
    }
    
    private func setupUI() {
        view.backgroundColor = .white.withAlphaComponent(0.7)
        title = viewModel.conversation.name
        
        // 配置表格视图
        tableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1) // 反转表格
        
        view.addSubview(tableView)
        view.addSubview(inputBar)
        
        tableView.snp.makeConstraints {
            $0.top.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(inputBar.snp.top)
        }
        
        inputBar.delegate = self
        inputBar.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(56)
        }
    }
    
    private func scrollToBottom() {
        guard !viewModel.messages.isEmpty else { return }
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
}

extension ChatDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("jiankai 00 index = \(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        let message = viewModel.messages[indexPath.row]
        cell.configure(with: message)
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1) // 反转单元格
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ChatDetailViewController: MessageInputBarDelegate {
    // 发送文本消息
    func inputBarDidTapSendButton(_ inputBar: MessageInputBar, text: String) {
        viewModel.sendMessage(text)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
            print("执行了，count = \(self?.viewModel.messages.count)")
            self?.tableView.reloadData()
            self?.scrollToBottom()
        })
    }
    
    // 开始语音输入
    func inputBarDidStartRecording(_ inputBar: MessageInputBar) {
        viewModel.onRecordingStart = { [weak inputBar]  in
//            inputBar?.startRecordingAnimation()
        }
        viewModel.onSpeechRecognized = { [weak self] text, url, duration in
            DispatchQueue.main.async {
                self?.viewModel.sendMessage("[语音] \(text)", url: url, duration: duration)
                self?.tableView.reloadData()
                self?.scrollToBottom()
                print("jiankai -- daiinle")
                self?.view.layoutIfNeeded()
            }
            
        }
        viewModel.onError = { [weak self] message in
            self?.showAlert(title: "错误", message: message)
        }
        viewModel.startRecording()
    }
    
    // 完成语音输入
    func inputBarDidFinishRecording(_ inputBar: MessageInputBar) {
        viewModel.stopRecording()
//        inputBar.stopRecordingAnimation()
    }
    
    // 取消语音输入
    func inputBarDidCancelRecording(_ inputBar: MessageInputBar) {
        viewModel.cancelRecording()
//        inputBar.stopRecordingAnimation()
    }
    
    // 点击表情按钮
    func inputBarDidTapEmojiButton(_ inputBar: MessageInputBar) {
        //        inputBar.textView.resignFirstResponder()
        //        showEmojiKeyboard()
    }
    
    // 点击更多按钮
    func inputBarDidTapMoreButton(_ inputBar: MessageInputBar) {
        //        inputBar.resignFirstResponder()
        //        showMoreOptions()
    }
    
    // 点击语音按钮（切换模式）
    func inputBarDidTapVoiceButton(_ inputBar: MessageInputBar) {
        inputBar.resignFirstResponder()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

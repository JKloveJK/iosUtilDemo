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
            
            // 修复1：保持原有约束锚点（superview），通过调整offset来包含安全区域
            let bottomOffset = isShowing ?
                -keyboardHeight + view.safeAreaInsets.bottom :
                -view.safeAreaInsets.bottom
            
            inputBar.snp.updateConstraints {
                $0.bottom.equalToSuperview().offset(bottomOffset)
            }
            
            // 修复2：同步更新表格视图约束
            tableView.snp.updateConstraints {
                $0.bottom.equalTo(inputBar.snp.top).offset(isShowing ? -view.safeAreaInsets.bottom : 0)
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
        view.backgroundColor = .white
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
        
        inputBar.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
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
        tableView.reloadData()
        scrollToBottom()
    }
    
    // 开始语音输入
    func inputBarDidStartRecording(_ inputBar: MessageInputBar) {
//        showRecordingIndicator()
    }
    
    // 完成语音输入
    func inputBarDidFinishRecording(_ inputBar: MessageInputBar) {
//        hideRecordingIndicator()
//        // 这里可以添加语音文件处理逻辑
//        let alert = UIAlertController(title: "语音消息", message: "已收到语音输入", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "确定", style: .default))
//        present(alert, animated: true)
    }
    
    // 取消语音输入
    func inputBarDidCancelRecording(_ inputBar: MessageInputBar) {
//        hideRecordingIndicator()
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
}

//
//  ChatDetailModel.swift
//  iosUtilDemo
//
//  Created by Jiankai Lei on 2025/2/24.
//

import Foundation
import Speech
import AVFoundation

class ChatDetailViewModel {
    private(set) var messages: [Message] = []
    let conversation: Conversation
    
    // 新增录音相关属性
    private var audioRecorder: AVAudioRecorder?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // 新增录音状态回调
    var onRecordingStart: (() -> Void)?
    var onRecordingStop: ((URL, TimeInterval) -> Void)?
    var onSpeechRecognized: ((String, URL, TimeInterval) -> Void)?
    var onError: ((String) -> Void)?
    
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
                type: .text("早上好！今天天气不错 ☀️"),
                isSelf: true,
                time: calendar.date(byAdding: .hour, value: -8, to: now)!,
                avatarUrl: UserInfo.shared.avatarUrl
            ),
            Message(
                id: "2",
                type: .text("是啊，适合出去走走"),
                isSelf: false,
                time: calendar.date(byAdding: .hour, value: -8, to: now)!.addingTimeInterval(120),
                avatarUrl: conversation.avatar
            ),
            
            // 上午的工作对话
            Message(
                id: "3",
                type: .text("关于下午的项目会议，我们需要准备哪些材料？"),
                isSelf: true,
                time: calendar.date(byAdding: .hour, value: -6, to: now)!,
                avatarUrl: UserInfo.shared.avatarUrl
            ),
            Message(
                id: "4",
                type: .text("主要是上周的项目进度报告和下一阶段的计划书，我已经整理好了一部分，待会发给你"),
                isSelf: false,
                time: calendar.date(byAdding: .hour, value: -6, to: now)!.addingTimeInterval(300),
                avatarUrl: conversation.avatar
            ),
            Message(
                id: "5",
                type: .text("好的，收到后我再补充一下技术方案部分"),
                isSelf: true,
                time: calendar.date(byAdding: .hour, value: -6, to: now)!.addingTimeInterval(500),
                avatarUrl: UserInfo.shared.avatarUrl
            ),
            
            // 中午休息时间
            Message(
                id: "6",
                type: .text("午饭时间到了，要一起去吃饭吗？🍱"),
                isSelf: false,
                time: calendar.date(byAdding: .hour, value: -4, to: now)!,
                avatarUrl: conversation.avatar
            ),
            Message(
                id: "7",
                type: .text("抱歉，我这边还在处理一个紧急问题，你们先去吧 😅"),
                isSelf: true,
                time: calendar.date(byAdding: .hour, value: -4, to: now)!.addingTimeInterval(180),
                avatarUrl: UserInfo.shared.avatarUrl
            ),
            
            // 下午的讨论
            Message(
                id: "8",
                type: .text("刚才会议讨论的新功能，我觉得可以这样实现..."),
                isSelf: true,
                time: calendar.date(byAdding: .hour, value: -2, to: now)!,
                avatarUrl: UserInfo.shared.avatarUrl
            ),
            Message(
                id: "9",
                type: .text("这个方案不错，但是我们需要考虑一下性能优化的问题"),
                isSelf: false,
                time: calendar.date(byAdding: .hour, value: -2, to: now)!.addingTimeInterval(400),
                avatarUrl: conversation.avatar
            ),
            Message(
                id: "10",
                type: .text("对的，我们可以先做一个性能测试，看看具体的数据表现"),
                isSelf: true,
                time: calendar.date(byAdding: .hour, value: -2, to: now)!.addingTimeInterval(600),
                avatarUrl: UserInfo.shared.avatarUrl
            ),
            
            // 最近的消息
            Message(
                id: "11",
                type: .text("今天辛苦了，项目进展很顺利 👍"),
                isSelf: false,
                time: calendar.date(byAdding: .minute, value: -30, to: now)!,
                avatarUrl: conversation.avatar
            ),
            Message(
                id: "12",
                type: .text("是的，团队配合得很好。明天继续加油！💪"),
                isSelf: true,
                time: calendar.date(byAdding: .minute, value: -25, to: now)!,
                avatarUrl: UserInfo.shared.avatarUrl
            )
        ]
        
        messages.sort { $0.time < $1.time }
    }
    
    func sendMessage(_ text: String, url: URL? = nil, duration: TimeInterval = 0) {
        var type: Message.MessageType = .text(text)
        if let url = url {
            type = .voice(duration: duration, url: url)
        }
        let newMessage = Message(
            id: UUID().uuidString,
            type: type,
            isSelf: true,
            time: Date(),
            avatarUrl: UserInfo.shared.avatarUrl
        )
        messages.append(newMessage)
    }
}

struct Message: Identifiable {
    enum MessageType {
        case text(String)
        case voice(duration: TimeInterval, url: URL)
    }
    
    let id: String
    let type: MessageType
    let isSelf: Bool
    let time: Date
    let avatarUrl: String
}

// asr 相关
extension ChatDetailViewModel {
    
    func startRecording() {
        setupAudioSession()
        requestSpeechAuthorization { [weak self] in
            self?.onError?("需要麦克风和语音识别权限")
        }
        
        let audioFilename = FileManager.default.temporaryDirectory
            .appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            onRecordingStart?()
        } catch {
            onError?("录音启动失败: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        guard let url = audioRecorder?.url else { return }
        let duration = audioRecorder?.currentTime ?? 0
        onRecordingStop?(url, duration)
        processAudioFile(url: url, duration: duration)
    }
    
    func cancelRecording() {
        audioRecorder?.stop()
        audioRecorder?.deleteRecording()
    }
    
    private func processAudioFile(url: URL, duration: TimeInterval) {
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh_CN"))
        let request = SFSpeechURLRecognitionRequest(url: url)
        
        recognitionTask = recognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let result = result else {
                self?.onError?(error?.localizedDescription ?? "识别失败")
                return
            }
            
            if result.isFinal {
                self?.onSpeechRecognized?(result.bestTranscription.formattedString, url, duration)
            }
        }
    }
    
    
    func setupAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth])
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    func requestSpeechAuthorization(denyCompletion: (() -> Void)? = nil) {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            switch status {
            case .authorized:
                AVAudioSession.sharedInstance().requestRecordPermission { allowed in
                    if !allowed {
                        denyCompletion?()
                    }
                }
            default:
                denyCompletion?()
            }
        }
    }
}

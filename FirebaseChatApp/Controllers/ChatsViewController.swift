//
//  ChatsViewController.swift
//  FirebaseChatApp
//
//  Created by Sanchita Lachke on 24/11/22.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType {
    public var sender: MessageKit.SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKit.MessageKind
}

extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender: SenderType {
    public var photoURL: String
    public var senderId: String
    public var displayName: String
}

class ChatsViewController: MessagesViewController {
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .long
        formatter.locale =  .current
        return formatter
    }()
    
    public let otherUserEmail: String
    public var isNewConversation = false
    
    private var messages = [Message]()
    
    private var selfSender: Sender?  {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        return Sender(photoURL: "",
               senderId: email,
               displayName: "Joe Smith")
    }
    
    init(with email: String) {
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cyan
        
        //        messages.append(Message(sender: selfSender,
        //                                messageId: "1",
        //                                sentDate: Date(),
        //                                kind: .text("Hello Joe")))
        //
        //        messages.append(Message(sender: selfSender,
        //                                messageId: "1",
        //                                sentDate: Date(),
        //                                kind: .text("A new version of the Google Sign-In iOS SDK is available: https://developers.google.com/identity/sign-in/ios/release")))
        
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
}

extension ChatsViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageID() else {
            return
        }
        
        print("Sending : \(text)")
        
        //Send Message
        if isNewConversation {
            //create convo in db
            let message = Message(sender: selfSender,
                                  messageId: messageId,
                                  sentDate: Date(),
                                  kind: .text(text))
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, firstMessage: message, completion: { [weak self] success in
                if success {
                    print("message sent")
                }else {
                    print("message failed")
                }
            })
        }else {
            //append to existing convo
        }
    }
    
    
    private func createMessageID() -> String? {
        //date, otherUserEmail, SenderEmail, randomInt
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        
        let newId = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        print("Created message Id: \(newId)")
        return newId
    }
}

extension ChatsViewController: MessagesDisplayDelegate, MessagesDataSource, MessagesLayoutDelegate {
    func currentSender() -> MessageKit.SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self sender is nil, email should be cached")
        return Sender(photoURL: "", senderId: "12", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
}

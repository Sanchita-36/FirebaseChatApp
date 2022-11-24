//
//  ChatsViewController.swift
//  FirebaseChatApp
//
//  Created by Sanchita Lachke on 24/11/22.
//

import UIKit
import MessageKit

struct Message: MessageType {
    var sender: MessageKit.SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKit.MessageKind
}

struct Sender: SenderType {
    var photoURL: String
    var senderId: String
    var displayName: String
}

class ChatsViewController: MessagesViewController {
    private var messages = [Message]()
    
    private let selfSender = Sender(photoURL: "",
                                    senderId: "1",
                                    displayName: "Joe Smith")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cyan
        
        messages.append(Message(sender: selfSender,
                                messageId: "1",
                                sentDate: Date(),
                                kind: .text("Hello Joe")))
        
        messages.append(Message(sender: selfSender,
                                messageId: "1",
                                sentDate: Date(),
                                kind: .text("A new version of the Google Sign-In iOS SDK is available: https://developers.google.com/identity/sign-in/ios/release")))
        
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
    }
}

extension ChatsViewController: MessagesDisplayDelegate, MessagesDataSource, MessagesLayoutDelegate {
    func currentSender() -> MessageKit.SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }

}
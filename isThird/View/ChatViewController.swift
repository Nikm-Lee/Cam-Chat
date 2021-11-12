import UIKit
import MessageKit
import FirebaseFirestore
import FirebaseAuth
import InputBarAccessoryView

class ChatViewController: UIViewController {
    
    //    @IBOutlet weak var messageInputBar: InputBarAccessoryView!
    @IBOutlet weak var messagesCollectionView: MessagesCollectionView!
    private var messages : [Message] = []
    private var messageListener : ListenerRegistration?
    var member : Member!
    
}
extension ChatViewController: MessagesDataSource {
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func currentSender() -> SenderType {
        return Sender(id: member.name, displayName: member.name)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return messages[indexPath.section]
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 12
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        return NSAttributedString(
            string: message.sender.displayName,
            attributes: [.font: UIFont.systemFont(ofSize: 12)])
    }
}
extension ChatViewController: MessagesLayoutDelegate,MessagesDisplayDelegate {
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
          let message = messages[indexPath.section]
          let color = message.member.color
          avatarView.backgroundColor = color
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func messageInputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
    
        let newMessage = Message(member: member, text: text, messageId: UUID().uuidString)
          
        messages.append(newMessage)
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(animated: true)
  }
}

//MARK: - LifeCycle
extension ChatViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        member = Member(name: "bluemoon", color: .blue)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
//        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
        let newMessage = Message(member: member, text: "HelloWorld", messageId: UUID().uuidString)
    
        messages.append(newMessage)
        messagesCollectionView.reloadData()
        //        insertNewMessage(testMessage)
        
    }
}



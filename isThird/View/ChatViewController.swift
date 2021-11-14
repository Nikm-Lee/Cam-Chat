import UIKit
import MessageKit
import FirebaseFirestore
import FirebaseAuth
import InputBarAccessoryView




class ChatViewController: MessagesViewController {
    
    let currentUser = Sender(senderId: "self", displayName: "이상네트웍스")
    
    let otherUser = Sender(senderId: "other", displayName: "메쎄이상")
    
    var messages = [MessageType]()
    
}

extension ChatViewController{
    func pageInit(){
        messages.append(Message(sender: currentUser, messageId: "1", sentDate: Date().addingTimeInterval(-86400), kind: .text("경영전략실")))
        messages.append(Message(sender: otherUser, messageId: "2", sentDate: Date().addingTimeInterval(-66400), kind: .text("정보전략실")))
        messages.append(Message(sender: currentUser, messageId: "3", sentDate: Date().addingTimeInterval(-56400), kind: .text("B2B사업본부")))
        messages.append(Message(sender: currentUser, messageId: "4", sentDate: Date().addingTimeInterval(-46400), kind: .text("건축전략실")))
        messages.append(Message(sender: otherUser, messageId: "5", sentDate: Date().addingTimeInterval(-26400), kind: .text("마지막 메시지")))
    }
}
extension ChatViewController : MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate{
    
    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
}

//MARK: - LifeCycle
extension ChatViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageInit()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
//        messagesCollectionView.
        
    }

}



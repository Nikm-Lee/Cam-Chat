import UIKit
import MessageKit
import FirebaseFirestore
import FirebaseAuth
import InputBarAccessoryView
import RxDataSources
import RxSwift
import RxCocoa
import Alamofire



extension InputBarButtonItem{
    
    fileprivate func cameraClickAction(_ currentVC : UIViewController){
        guard let cameraVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cameraVC") as? CameraVC else {return}
        currentVC.present(cameraVC, animated: true, completion: nil)
    }
    
    fileprivate func albumClickAction(){
        
    }
}

class ChatViewController: MessagesViewController {
    
    let currentUser = Sender(senderId: LoginUser.shared.senderId, displayName: LoginUser.shared.displayName)
    
    var messages = [MessageType]()
    
    
    lazy var db = Firestore.firestore()
    
    lazy var leftButtons : [InputItem] = {
       return [
        InputBarButtonItem()
            .configure{
                $0.setSize(CGSize(width: 40, height: 40), animated: false)
                $0.isEnabled = true
                $0.image = UIImage(systemName: "camera.fill")
                $0.tintColor = .gray
            }
            .onSelected{
                $0.cameraClickAction(self)
            }
        ,InputBarButtonItem()
            .configure{
                $0.setSize(CGSize(width: 40, height: 40), animated: false)
                $0.isEnabled = true
                $0.image = UIImage(systemName: "photo.artframe")
                $0.tintColor = .gray
            }
            .onSelected{
                $0.inputBarAccessoryView?.didSelectSendButton()
            }
       ]
    }()
    
    let picker = UIImagePickerController()
    
    let bag = DisposeBag()
    
    var logOutBtn : UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.title = "로그아웃"
        item.style = .plain
        item.target = item
        item.action = nil
        item.tintColor = .black
        return item
    }()
}


extension ChatViewController{
    
    func pageInit(){
        self.navigationItem.hidesBackButton = true
        connectDB()
    }
    
    func bind(){
        logOutBtn.rx.tap
            .subscribe(onNext : { _ in
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: bag)
    }
    
    func connectDB(){
        db.collection("message")
            .order(by: "date")
            .addSnapshotListener { querySnapshot, error in
                self.messages = []
                if let e = error{
                    print(e.localizedDescription)
                }else{
                    if let snapshotDocuments = querySnapshot?.documents{
                        snapshotDocuments.forEach { doc in
                            let data = doc.data()
                            if let sender = data["sender"] as? String, let body = data["body"] as? String, let name = data["name"] as? String, let date = data["date"] as? Double{
                                
                                let sender = Sender(senderId: sender, displayName: name)
                                self.messages.append(Message(sender: sender, messageId: "1", sentDate: Date(timeIntervalSinceNow: date), kind: .text(body)) )
                                
                                DispatchQueue.main.async {
                                    self.messagesCollectionView.reloadData()
                                    self.messagesCollectionView.scrollToLastItem()
                                }
                            }
                        }
                    }
                }
            }
    }
    
    func sendMessage(_ message : String?){
        
        if let messageBody = message, messageBody.count > 1{
            db.collection("message").addDocument(data: [
                "sender" : LoginUser.shared.senderId,
                "body" : messageBody,
                "name" : LoginUser.shared.displayName,
                "date" : Date().timeIntervalSince1970
            ]){ error in
                if let e = error{
                    print("sendMessage Error : \(e.localizedDescription)")
                }else{
                    DispatchQueue.main.async {
                        self.messageInputBar.inputTextView.text = ""
                    }
                }
            }
        }
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
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 14
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(
            string: message.sender.displayName,
            attributes: [.font: UIFont.systemFont(ofSize: 12)])
        
    }
}

extension ChatViewController : InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        print("Btn is Clicked")
        sendMessage(text)
    }
}

//MARK: - LifeCycle
extension ChatViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageInit()
        bind()
        messageInputBar.delegate = self
        messageInputBar.setStackViewItems(leftButtons, forStack: .left, animated: true)
        messageInputBar.inputTextView.placeholder = "   Message"
        messageInputBar.setLeftStackViewWidthConstant(to: 80, animated: true)
        messageInputBar.leftStackView.distribution = .fillEqually
        
        messageInputBar.sendButton.title = ""
        messageInputBar.sendButton.image = UIImage(systemName: "paperplane.fill")
        messageInputBar.sendButton.tintColor = .black
        messageInputBar.sendButton.isEnabled = true
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.rightBarButtonItem = logOutBtn
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        var basicRightBtnItems = navigationController?.navigationBar.topItem?.rightBarButtonItems
        
        if basicRightBtnItems!.contains(logOutBtn){
            basicRightBtnItems?.removeAll(where: {$0 == logOutBtn})
        }
    }
}

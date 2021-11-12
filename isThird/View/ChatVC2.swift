//
//  ChatVC2.swift
//  isThird
//
//  Created by esmnc1 on 2021/11/12.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import RxSwift
import RxCocoa
import RxGesture
class ChatVC2: UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var colView: UICollectionView!

    let bag = DisposeBag()
    var keyHeight : CGFloat?
    var isShowKeyBoard : Bool = false
    var viewHeight : BehaviorRelay<CGFloat> = BehaviorRelay<CGFloat>(value: 2000)
    var messages : [MessageModel] = []
    lazy var db = Firestore.firestore()
}
extension ChatVC2{
    func loginT(){
        
        Auth.auth().signIn(withEmail: "jokim.es@esgroup.net", password: "qwe123") { authResult, error in
            if let e = error{
                print("SignIn error =>\(e.localizedDescription)")
            }
            else{
                print("SignIn Result => \(authResult)")
            }
        }
    }
    func signUpT(){
        Auth.auth().createUser(withEmail: "lkm.es@esgroup.net", password: "qwe123") { authResult, error in
            if let e = error{
                print("SignUp error =>\(e.localizedDescription)")
            }
            else{
                print("SignUp Result => \(authResult)")
            }
        }
    }
    func messageT(){
        db.collection("message")
            .order(by: "date")
            .addSnapshotListener { (querySnapshot, error) in
                print("MessageT is Called")
                self.messages = []
                
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        snapshotDocuments.forEach { (doc) in
                            let data = doc.data()
                            if let sender = data["sender"] as? String, let body = data["body"] as? String {
                                print("E9mini data => \(data)")
                                self.messages.append(MessageModel(messageId: nil, content: body, created: nil, senderId: nil, senderName: sender))
                                DispatchQueue.main.async {
                                    self.colView.reloadData()
                                }
                            }
                        }
                    }
                }
        }
    }
    func sendMessage(){
        print("Message=> \(messages)")
        if let messageBody = inputField.text, let messageSender = Auth.auth().currentUser?.email{
            db.collection("message").addDocument(data: [
                "sender" : messageSender
                ,"body":messageBody
                ,"date":Date().timeIntervalSince1970
            ]){ error in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    DispatchQueue.main.async {
                        self.inputField.text = ""
                        let item = self.collectionView(self.colView, numberOfItemsInSection: 0) - 1
                        let lastItemIndex = NSIndexPath(item: item, section: 0)
                        self.colView.scrollToItem(at: lastItemIndex as IndexPath, at: .top, animated: true)
                    }
                }
            }
        }
        
    }
    
    func pageInit(){
        colView.register(UINib(nibName: "ChatUserCell", bundle: .main), forCellWithReuseIdentifier: "chatuserCell")
        colView.delegate = self
        colView.dataSource = self
        loginT()
        messageT()
        
    }
    func bind(){
        colView.rx
            .tapGesture(configuration: .none)
            .subscribe(onNext:{ _ in
                self.inputField.resignFirstResponder()
            })
            .disposed(by: bag)
        
        sendBtn.rx.tap
            .subscribe(onNext : { _ in
                self.sendMessage()
                self.inputField.resignFirstResponder()
            })
            .disposed(by: bag)
    }
}

extension ChatVC2 :UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let message = messages[indexPath.item]
        
        let messageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "chatuserCell", for: indexPath) as! ChatUserCell
        
        messageCell.userName.text = message.senderName
        messageCell.userMessage.text = message.content
//        messageCell.profileImage.isHidden = true
    
        return messageCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = view.frame.size
        
        return CGSize(width: size.width, height: size.height/20)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
}
extension ChatVC2{
    @objc func keyboardWillShow(_ sender : Notification){
        let userInfo:NSDictionary = sender.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        let tabBarHeight = tabBarController?.tabBar.frame.height

        
        if !isShowKeyBoard{
            if let _ = tabBarHeight{
                keyHeight = keyboardHeight - tabBarHeight! + 20
                self.view.frame.size.height -= keyHeight!
            }else{
                keyHeight = keyboardHeight
                self.view.frame.size.height -= keyHeight!
            }
        }
        
        isShowKeyBoard = true
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        
        self.view.frame.size.height += keyHeight!
        isShowKeyBoard = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
extension ChatVC2{
    override func viewDidLoad() {
        super.viewDidLoad()
        pageInit()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
//        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollView.contentSize.height-self.scrollView.bounds.height), animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

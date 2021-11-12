//
//  ChatLoginVC.swift
//  isThird
//
//  Created by esmnc1 on 2021/11/09.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth

class ChatLoginVC : UIViewController{
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    
//    let loginUser = UserModel()
    let bag = DisposeBag()
}

extension ChatLoginVC{
    func pageInit(){
        Auth.auth().signInAnonymously()
    }
    
    func bind(){
        loginBtn.rx.tap
            .subscribe(onNext: { _ in
                let chatVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatVC") as! ChatVC
                chatVC.modalPresentationStyle = .fullScreen
                self.present(chatVC, animated: true, completion: nil)
            })
            .disposed(by: bag)
    }
}
extension ChatLoginVC{
    
}
extension ChatLoginVC{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
//MARK: - LifeCycle
extension ChatLoginVC{
    override func viewDidLoad() {
        super.viewDidLoad()
        pageInit()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
}


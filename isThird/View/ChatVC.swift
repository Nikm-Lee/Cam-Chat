//
//  ChatVC.swift
//  isThird
//
//  Created by esmnc1 on 2021/11/05.
//

import UIKit
import FirebaseAuth
import Messages
import RxSwift
import RxCocoa

class ChatVC: UIViewController {

    let bag = DisposeBag()
}

extension ChatVC{
    func pageInit(){
        
    }
    
    func bind(){
        
    }
}

extension ChatVC{
    
}
extension ChatVC{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
//MARK: - LifeCycle
extension ChatVC{
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

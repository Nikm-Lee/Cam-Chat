//
//  LoginVC.swift
//  isThird
//
//  Created by esmnc1 on 2021/11/19.
//

import UIKit
import RxSwift
import RxCocoa
import Then

class LoginVC: UIViewController {

    @IBOutlet weak var nickNameField: UITextField!
    @IBOutlet weak var userIdField: UITextField!
    @IBOutlet weak var userPwField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    let bag = DisposeBag()
}

extension LoginVC{
    
    func pageInit(){
        
    }
    
    func bind(){
        userIdField.rx.controlEvent(.editingDidEnd)
            .asObservable()
            .subscribe(onNext: { _ in
                
            })
            .disposed(by: bag)
        
        userPwField.rx.controlEvent(.editingDidEnd)
            .asObservable()
            .subscribe(onNext : { _ in
                
            })
            .disposed(by: bag)
        
        nickNameField.rx.controlEvent(.editingDidEnd)
            .asObservable()
            .subscribe(onNext : { _ in
                
            })
            .disposed(by: bag)
        
        loginBtn.rx.tap
            .asObservable()
            .subscribe(onNext: { _ in
                let channelVC  = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "channelVC") as! ChannelVC
                self.navigationController?.pushViewController(channelVC, animated: true)
            })
            .disposed(by: bag)
    }
}

extension LoginVC{
    
}

extension LoginVC{
    override func viewDidLoad() {
        super.viewDidLoad()
        pageInit()
        bind()
    }
}


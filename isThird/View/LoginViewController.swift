//
//  LoginVieController.swift
//  isThird
//
//  Created by esmnc1 on 2021/11/15.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import CoreMedia
import FirebaseAuth

/*
 담에 만든다면 스크롤뷰로
 */
class LoginViewController: UIViewController {

    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var nicknameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var repasswordField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!

    private lazy var chatVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatVC3") as! ChatViewController
    let bag = DisposeBag()
    var keyHeight : CGFloat?
    var isShowKeyBoard : Bool = false
    
    let isNicknameValid = BehaviorRelay<Bool>(value: false)
    let isEmailValid = BehaviorRelay<Bool>(value: false)
    let isPasswordValid = BehaviorRelay<Bool>(value: false)
}

extension LoginViewController{
    func bind(){

        idField.rx.controlEvent(.editingDidEnd)
            .asObservable()
            .subscribe(onNext : { _ in
                print(self.idField.text)
                    
            })
            .disposed(by: bag)
     
        nicknameField.rx.text.orEmpty
            .map{text -> Bool in
                return text.count >= 2
            }
            .bind(to: self.isNicknameValid)
            .disposed(by: bag)

        idField.rx.text
            .throttle(.milliseconds(100), scheduler: MainScheduler.instance)
            .map{ [weak self] text -> Bool in
                guard let text = text , let isValid = self?.validateEmail(text) else { return false }
                return !text.isEmpty || isValid}
            .distinctUntilChanged()
            .bind(to:self.isEmailValid)
            .disposed(by: bag)
        
        repasswordField.rx.text.orEmpty
            .filter{$0.count > 0}
            .map{ [weak self] text -> Bool in
                    guard let self = self else {return false}
                    return text == self.passwordField.text
            }
            .bind(to: self.isPasswordValid)
            .disposed(by: bag)
        
        loginBtn.rx.tap
            .subscribe(onNext:{ _ in
                if self.isEmailValid.value && self.isNicknameValid.value && self.isPasswordValid.value{
                    self.tryFBLogin()
                }else{
                    print("Error")
                    print("isEmailValid : \(self.isEmailValid.value)")
                    print("isNicknameValid : \(self.isNicknameValid.value)")
                    print("isPasswordValid : \(self.isPasswordValid.value)")
                }
            })
            .disposed(by: bag)

    }
}

extension LoginViewController{

    private func pageInit(){
        autoLogin()
    }
    
    private func autoLogin(){
        if let userPw = UserDefaults.standard.value(forKey: "userPw") as? String,
           let userId = UserDefaults.standard.value(forKey: "userId") as? String,
           let displayName = UserDefaults.standard.value(forKey: "displayName") as? String{
            idField.text = userId
            nicknameField.text = displayName
            passwordField.text = userPw
            repasswordField.text = userPw
        }
    }
    private func validateEmail(_ string: String) -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return string.range(of: emailRegEx, options: .regularExpression) != nil
    }
    
    private func tryFBLogin(){
        Auth.auth().signIn(withEmail: self.idField.text!, password: self.passwordField.text!) { authResult, error in
            if let e = error{
                print(e.localizedDescription)
                print ("tryLogin Err")
            }else{
                LoginUser.shared.senderId = self.idField.text!
                LoginUser.shared.displayName = self.nicknameField.text!
                LoginUser.shared.userPw = self.passwordField.text!
                UserDefaults.standard.setValue(self.idField.text!, forKey: "userId")
                UserDefaults.standard.setValue(self.passwordField.text!, forKey: "userPw")
                UserDefaults.standard.setValue(self.nicknameField.text!, forKey: "displayName")
                
                self.navigationController?.pushViewController(self.chatVC, animated: true)
                self.idField.text = ""
                self.nicknameField.text = ""
                self.passwordField.text = ""
                self.repasswordField.text = ""
            }
        }
    }

}

extension LoginViewController{
    @objc func keyboardWillShow(_ sender : Notification){
        
        let userInfo:NSDictionary = sender.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        let tabBarHeight = tabBarController?.tabBar.frame.height
        
        if !isShowKeyBoard{
            if let _ = tabBarHeight{
                keyHeight = keyboardHeight - tabBarHeight!
                self.view.frame.origin.y -= keyHeight!
            }else{
                keyHeight = keyboardHeight
                self.view.frame.origin.y -= keyHeight!
            }
            isShowKeyBoard = true
        }
        
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        
        if isShowKeyBoard{
            self.view.frame.origin.y += keyHeight!
            isShowKeyBoard = false
        }
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}


//MARK: - LifeCycle
extension LoginViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        pageInit()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        autoLogin()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

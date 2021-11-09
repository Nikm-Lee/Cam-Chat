//
//  TabBarVC.swift
//  isThird
//
//  Created by esmnc1 on 2021/11/05.
//

import UIKit
import ESTabBarController_swift
import SideMenu
import RxSwift
import RxCocoa

class TabBarVC: ESTabBarController {

    @IBOutlet weak var cameraBtn: UIBarButtonItem!
    @IBOutlet weak var menuBtn: UIBarButtonItem!
    
    var sideMenu : SideMenuNavigationController?
    let sideVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sideVC") as? SideVC
    let bag = DisposeBag()
}

extension TabBarVC{
    func pageInit(){
        guard let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "homeVC") as? HomeVC else {return}
        guard let chatloginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatloginVC") as? ChatLoginVC else {return}
        guard let pickerResultVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pickerresultVC") as? PickerResultVC else {return}
        
        chatloginVC.tabBarItem = ESTabBarItem(ESCustomTabbar()
                                         , title: "Chat"
                                         , image: UIImage(named: "tab_ico2")
                                         , selectedImage: UIImage(named: "tab_ico2")
                                         , tag: 1)
        
        homeVC.tabBarItem = ESTabBarItem(ESCustomTabbar()
                                         , title: "Home"
                                         , image: UIImage(named: "tab_ico_home")
                                         , selectedImage: UIImage(named: "tab_ico_home")
                                         , tag: 2)
        
        pickerResultVC.tabBarItem = ESTabBarItem(ESCustomTabbar()
                                         , title: "Picker"
                                         , image: UIImage(named: "tab_ico3")
                                         , selectedImage: UIImage(named: "tab_ico3")
                                         , tag: 3)
        
        
        self.viewControllers = [chatloginVC,homeVC,pickerResultVC]
        selectedViewController = homeVC
    }
    
    func bind(){
        menuBtn.rx.tap
            .subscribe(onNext:{ _ in
                self.present(self.sideMenu!, animated: true, completion: nil)
            })
            .disposed(by: bag)
        
        cameraBtn.rx.tap
            .subscribe(onNext : {_ in
                guard let cameraVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cameraVC") as? CameraVC else {return}
                self.navigationController?.pushViewController(cameraVC, animated: true)
            })
            .disposed(by: bag)
    }
}

extension TabBarVC{
    func sideMenuInit(){
        sideMenu = SideMenuNavigationController(rootViewController: sideVC!)
        sideMenu?.leftSide = true
        sideMenu?.presentationStyle = .menuSlideIn
        sideMenu?.presentationStyle.presentingEndAlpha = 0.2
        sideMenu?.statusBarEndAlpha = 0
        sideMenu?.navigationBar.isHidden = true
        sideMenu?.menuWidth = self.view.frame.width * 0.8
    }
}

extension TabBarVC{
    
}

//MARK: - LifeCycle
extension TabBarVC{
    override func viewDidLoad() {
        super.viewDidLoad()
        sideMenuInit()
        pageInit()
        bind()
    }
}

class ESCustomTabbar : ESTabBarItemContentView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        textColor = UIColor.init(white: 175.0 / 255.0, alpha: 1.0)
        highlightTextColor = UIColor.init(red: 254/255.0, green: 73/255.0, blue: 42/255.0, alpha: 1.0)
        iconColor = UIColor.init(white: 175.0 / 255.0, alpha: 1.0)
        highlightIconColor = UIColor.init(red: 254/255.0, green: 73/255.0, blue: 42/255.0, alpha: 1.0)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

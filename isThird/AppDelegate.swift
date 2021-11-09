//
//  AppDelegate.swift
//  isThird
//
//  Created by esmnc1 on 2021/11/05.
//

import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var originImg : UIImage?
    var originImgFrame : CGRect?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "naviVC") as? UINavigationController else {return false}
        
        FirebaseApp.configure()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()

        
        return true
    }
    
}


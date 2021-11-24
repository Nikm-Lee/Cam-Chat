//
//  User.swift
//  isThird
//
//  Created by esmnc1 on 2021/11/09.
//

import Foundation
import MessageKit

struct User : SenderType, Equatable{
    var senderId : String
    var displayName : String
    var userId : String? = ""
    var userPw : String? = ""
    var userName : String? = ""
}
struct Member {
  let name: String
  let color: UIColor
}

struct LoginUser : SenderType, Equatable{
    
    static var shared = LoginUser()
    
    var senderId: String
    var displayName: String
    var userId : String?
    var userPw : String?
    private init(){ senderId = ""; displayName = "";}
}



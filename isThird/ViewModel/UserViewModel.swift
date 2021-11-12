//
//  UserViewModel.swift
//  isThird
//
//  Created by esmnc1 on 2021/11/09.
//

import Foundation

class UserViewModel{
    var userModel : User
    
    init(userModel : User){
        self.userModel = userModel
    }
    
    var userId : String {
        return userModel.userId ?? ""
    }
    var userName : String {
        return userModel.userName ?? ""
    }
    var userPw : String {
        return userModel.userPw ?? ""
    }
}

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

struct Message {
  let member: Member
  let text: String
  let messageId: String
}

extension Message : MessageType{
    
    var sender: SenderType {
      return Sender(id: member.name, displayName: member.name)
    }
    
    var sentDate: Date {
      return Date()
    }
    
    var kind: MessageKind {
      return .text(text)
    }
}

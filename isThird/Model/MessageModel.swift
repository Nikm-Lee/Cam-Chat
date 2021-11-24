//
//  Message.swift
//  isThird
//
//  Created by esmnc1 on 2021/11/09.
//

import Foundation
import UIKit
import MessageKit

struct Sender : SenderType{
    var senderId: String
    var displayName: String
    var nickName : String?
}

struct Message : MessageType{
    
    var sender : SenderType
    var messageId : String
    var sentDate : Date
    var kind : MessageKind
}


struct MessageModel{
    var messageId : String? = ""
    var content : String? = ""
    var created : String? = ""
    var senderId : String? = ""
    var senderName : String? = ""
}


class BaseCollectionViewCell : UICollectionViewCell{

    override init(frame: CGRect){
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder : NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    func setupViews(){
        
    }
}

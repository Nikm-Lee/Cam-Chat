//
//  ChatUserCell.swift
//  isThird
//
//  Created by esmnc1 on 2021/11/11.
//

import UIKit

class ChatUserCell: UICollectionViewCell {

    @IBOutlet weak var userMessage: UITextView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

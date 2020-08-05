//
//  UserAvatarTableViewCell.swift
//  GitUser
//
//  Created by Rey Sayas on 8/5/20.
//  Copyright © 2020 Rey Sayas. All rights reserved.
//

import UIKit

class UserAvatarTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var lblFollowersCount: UILabel!
    @IBOutlet weak var lblFollowingCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func instanceFromNib() -> UserAvatarTableViewCell{
        return UINib(nibName: "UserAvatarTableViewCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UserAvatarTableViewCell
    }
}

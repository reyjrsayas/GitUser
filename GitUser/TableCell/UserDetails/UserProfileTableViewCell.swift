//
//  UserProfileTableViewCell.swift
//  GitUser
//
//  Created by Rey Sayas on 8/5/20.
//  Copyright © 2020 Rey Sayas. All rights reserved.
//

import UIKit

class UserProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCompany: UILabel!
    @IBOutlet weak var lblBlog: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupUserProfile(user: User) {
        lblName.text = user.name
        lblCompany.text = user.company ?? "-- No company provided --"
        lblBlog.text = user.blog ?? "-- No blog url provided --"
    }
    
    class func instanceFromNib() -> UserProfileTableViewCell{
        return UINib(nibName: "UserProfileTableViewCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UserProfileTableViewCell
    }
    
}

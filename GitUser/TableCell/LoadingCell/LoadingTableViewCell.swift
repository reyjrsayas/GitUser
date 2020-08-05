//
//  LoadingTableViewCell.swift
//  GitUser
//
//  Created by Rey Sayas on 8/5/20.
//  Copyright © 2020 Rey Sayas. All rights reserved.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func instanceFromNib() -> LoadingTableViewCell{
        return UINib(nibName: "LoadingTableViewCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! LoadingTableViewCell
    }
    
}

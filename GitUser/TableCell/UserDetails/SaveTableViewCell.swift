//
//  SaveTableViewCell.swift
//  GitUser
//
//  Created by Rey Sayas on 8/5/20.
//  Copyright © 2020 Rey Sayas. All rights reserved.
//

import UIKit

class SaveTableViewCell: UITableViewCell {

    var btnSaveHandler: (()->())?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func btnTapped(_ sender: UIButton) {
        btnSaveHandler!();
    }
    
    class func instanceFromNib() -> SaveTableViewCell{
           return UINib(nibName: "SaveTableViewCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SaveTableViewCell
       }
    
}

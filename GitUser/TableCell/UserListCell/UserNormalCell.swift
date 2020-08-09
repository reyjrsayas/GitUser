//
//  UserNormalCell.swift
//  GitUser
//
//  Created by Ray Sayas on 8/9/20.
//  Copyright © 2020 Rey Sayas. All rights reserved.
//

import UIKit

class UserNormalCell: UITableViewCell {
    
    @IBOutlet weak var lblLogin: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lblLogin.text?.removeAll()
        imgAvatar.image = nil
    }
}

typealias UserNormalCellTapCompletion = (User) -> ()

class UserNormalCellWrapper:DynamicTVCRow {
    var user:User
    var completion: UserNormalCellTapCompletion?
    
    fileprivate let imgLoader = ImageLoader()
    
    init(user: User, completion: UserNormalCellTapCompletion?) {
        self.user = user
        self.completion = completion
    }
    
    func getCellFor(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UserNormalCell.self), for: indexPath) as! UserNormalCell
        
        cell.lblLogin.text = self.user.login
        cell.imgAvatar.makeRounded()
        imgLoader.obtainImageWithPath(imagePath: self.user.avatar_url!) { (image) in
            cell.imgAvatar.image = image
        }
        
        return cell
    }
    
    func selectRow() {
        completion?(user)
    }
}

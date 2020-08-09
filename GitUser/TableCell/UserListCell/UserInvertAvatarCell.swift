//
//  UserInvertAvatarCell.swift
//  GitUser
//
//  Created by Ray Sayas on 8/9/20.
//  Copyright © 2020 Rey Sayas. All rights reserved.
//

import UIKit

class UserInvertAvatarCell: UITableViewCell {
    @IBOutlet weak var lblLogin: UILabel!
    @IBOutlet weak var imgAvatar: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lblLogin.text?.removeAll()
        imgAvatar.image = nil
    }
}

typealias UserInvertAvatarTapCompletion = (User) -> ()

class UserInvertAvatarCellWrapper: DynamicTVCRow {
    var user: User
    var completion: UserInvertAvatarTapCompletion?
    
    fileprivate let imgLoader = ImageLoader()
    
    fileprivate var observation: NSKeyValueObservation?
    
    init(user: User, completion: UserInvertAvatarTapCompletion?) {
        self.user = user
        self.completion = completion
    }
    
    func getCellFor(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UserInvertAvatarCell.self), for: indexPath) as! UserInvertAvatarCell
        
        cell.lblLogin.text = self.user.login
        cell.imgAvatar.makeRounded()
        imgLoader.obtainImageWithPath(imagePath: self.user.avatar_url!) { (image) in
            cell.imgAvatar.image = image
            cell.imgAvatar.invertImage()
        }
        
        return cell
    }
    
    func selectRow() {
        completion?(user)
    }
}

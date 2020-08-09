//
//  UserInvertAvatarAndNoteCell.swift
//  GitUser
//
//  Created by Ray Sayas on 8/9/20.
//  Copyright © 2020 Rey Sayas. All rights reserved.
//

import UIKit

class UserInvertAvatarAndNoteCell: UITableViewCell {
    
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblLogin: UILabel!
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lblLogin.text?.removeAll()
        imgAvatar.image = nil
    }
}

typealias UserInvertAvatarAndNoteTapCompletion = (User) -> ()

class UserInverAvatarAndNoteCellWrapper: DynamicTVCRow {
    var user: User
    var completion: UserInvertAvatarAndNoteTapCompletion?
    
    fileprivate let imgLoader = ImageLoader()
    
    init(user: User, completion: UserInvertAvatarAndNoteTapCompletion?) {
        self.user = user
        self.completion = completion
    }
    
    func getCellFor(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UserInvertAvatarAndNoteCell.self), for: indexPath) as! UserInvertAvatarAndNoteCell
        
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

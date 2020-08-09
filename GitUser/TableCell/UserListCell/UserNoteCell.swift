//
//  UserNoteCell.swift
//  GitUser
//
//  Created by Ray Sayas on 8/9/20.
//  Copyright © 2020 Rey Sayas. All rights reserved.
//

import UIKit

class UserNoteCell: UITableViewCell {
    
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblLogin: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lblLogin.text?.removeAll()
        imgAvatar.image = nil
    }
}

typealias UserNoteCellTapCompletion = (User) -> ()

class UserNoteCellWrapper: DynamicTVCRow {
    var user: User
    var completion: UserNoteCellTapCompletion?
    
    fileprivate let imgLoader = ImageLoader()
    
    init(user: User, completion: UserNoteCellTapCompletion?) {
        self.user = user
        self.completion = completion
    }
    
    func getCellFor(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UserNoteCell.self), for: indexPath) as! UserNoteCell
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

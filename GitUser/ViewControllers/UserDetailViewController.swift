//
//  UserDetailViewController.swift
//  GitUser
//
//  Created by Rey Sayas on 7/27/20.
//  Copyright © 2020 Rey Sayas. All rights reserved.
//

import UIKit

class UserDetailViewController: UIViewController {

    var user:User?
    @IBOutlet weak var userTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initData()
        self.title = self.user?.login
    }
    
    func initData() {
        if let user = CoreDataService.sharedInstance.getUser(user: user!) {
            if user.name == nil || user.name!.isEmpty {
                ApiService.shared.getUserDetails(user: self.user!, dispatchPriority: .high) { (result) in
                    switch result {
                    case .success(let response):
                        var _updateUser = response.data;
                        _updateUser.avatarImage = user.avatarImage
                        _ = CoreDataService.sharedInstance.updateUser(user: _updateUser)
                        self.initData()
                    case .failure(let error):
                        print(error.localizedDescription);
                        self.showAlert(message: error.localizedDescription, title: "Error")
                        
                    }
                }
            } else {
                self.user = user
                self.userTableView.reloadData()
            }
        }
    }
    
    func showAlert(message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension UserDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let avatarCell = UserAvatarTableViewCell.instanceFromNib()
            if user?.avatarImage != nil {
                avatarCell.avatarImg.image = UIImage(data: (user?.avatarImage)!)
            }
            
            avatarCell.lblFollowersCount.text = "\(user?.followersCount ?? 0)"
            avatarCell.lblFollowingCount.text = "\(user?.followingCount ?? 0)"
            
            return avatarCell;
        case 1:
            let userProfileCell = UserProfileTableViewCell.instanceFromNib()
            userProfileCell.setupUserProfile(user: user!)
            
            return userProfileCell
        case 2:
            let userNotes = UserNoteTableViewCell.instanceFromNib()
            userNotes.txtNote.text = user?.note
            userNotes.updateNote = { note in
                self.user?.note = note
            }
            return userNotes;
        default:
            let saveBtn = SaveTableViewCell.instanceFromNib()
            saveBtn.btnSaveHandler = {
                let success = CoreDataService.sharedInstance.updateUser(user: self.user!)
                if (success) {
                    self.showAlert(message: "Save success!", title: "Success")
                }
            }
            return saveBtn
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 151
        case 1:
            return 168
        case 2:
            return 194
        default:
            return 53
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
}

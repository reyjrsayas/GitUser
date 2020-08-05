//
//  UserTableViewCell.swift
//  GitUser
//
//  Created by Rey Sayas on 8/5/20.
//  Copyright © 2020 Rey Sayas. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var noteImg: UIImageView!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    
    private var user:User?;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupUser(_ user:User,_ invertAvatarImg:Bool ) {
        self.user = user;
        lblUsername.text = self.user?.login
        avatarImg.makeRounded()
        if (user.avatarImage == nil) {
            avatarImg.setImageFromUrl(user: self.user!, shouldInvert: invertAvatarImg) { (data) in
                self.user?.avatarImage = data
                _ = CoreDataService.sharedInstance.updateUser(user: self.user!)
            }
        } else {
            avatarImg.image = UIImage(data: (self.user?.avatarImage)!)
            if invertAvatarImg {
                avatarImg.invertImage()
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension UIImageView {
    func makeRounded () {
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
    func setImageFromUrl(user:User, shouldInvert:Bool, completion: @escaping((Data)->())) {
        ApiService.shared.downloadImage(url: user.avatar_url!, dispatch: .low) { (result) in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.image = image
                    if shouldInvert {
                        self.invertImage()
                    }
                    completion(image.pngData()!)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func invertImage() {
        let beginImg = CIImage(image: self.image!)
        if let filter = CIFilter(name: "CIColorInvert") {
            filter.setValue(beginImg, forKey: kCIInputImageKey)
            let newImg = UIImage(ciImage: filter.outputImage!)
            self.image = newImg
        }
    }
}


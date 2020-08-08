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
    
    private var imgLoader = ImageLoader()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupUser(_ user:User,_ invertAvatarImg:Bool ) {
        self.user = user;
        lblUsername.text = self.user?.login
        if self.user?.note != nil {
            if !(self.user?.note!.isEmpty)! {
                noteImg.isHidden = false
            } else {
                noteImg.isHidden = true
            }
        } else {
            noteImg.isHidden = true
        }
        avatarImg.makeRounded()
        imgLoader.obtainImageWithPath(imagePath: (self.user?.avatar_url)!) { (image) in
            self.avatarImg.image = image
            if invertAvatarImg {
                self.avatarImg.invertImage()
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class ImageLoader {
    
    var task: URLSessionDownloadTask!
    var session: URLSession!
    var cache: NSCache<NSString, UIImage>!
    
    init() {
        session = URLSession.shared
//        task = NSURLSession()
        self.cache = NSCache()
    }
    
    func obtainImageWithPath(imagePath: String, completionHandler: @escaping (UIImage) -> ()) {
        let semaphore = DispatchSemaphore(value: 1)
        
        semaphore.wait()
        if let image = self.cache.object(forKey: imagePath as NSString) {
            DispatchQueue.main.async {
                completionHandler(image)
                semaphore.signal()
            }
        } else {
            let placeholder = #imageLiteral(resourceName: "github")
            DispatchQueue.main.async {
                completionHandler(placeholder)
                semaphore.signal()
            }
            let url: URL! = URL(string: imagePath)
            task = session.downloadTask(with: url, completionHandler: { (location, response, error) in
                if let data = try? Data(contentsOf: url) {
                    let img: UIImage! = UIImage(data: data)
                    self.cache.setObject(img, forKey: imagePath as NSString)
                    DispatchQueue.main.async {
                        completionHandler(img)
                        semaphore.signal()
                    }
                }
            })
            task.resume()
        }
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


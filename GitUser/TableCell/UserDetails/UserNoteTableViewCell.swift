//
//  UserNoteTableViewCell.swift
//  GitUser
//
//  Created by Rey Sayas on 8/5/20.
//  Copyright © 2020 Rey Sayas. All rights reserved.
//

import UIKit

class UserNoteTableViewCell: UITableViewCell {

    @IBOutlet weak var txtNote: UITextView!
    var updateNote: ((_ note:String)->())?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.txtNote.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func instanceFromNib() -> UserNoteTableViewCell{
        return UINib(nibName: "UserNoteTableViewCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UserNoteTableViewCell
    }
    
}

extension UserNoteTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("Begin Editing")
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        updateNote!(textView.text)
    }
}

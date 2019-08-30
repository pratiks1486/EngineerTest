//
//  PostCell.swift
//  Engineer
//
//  Created by Abhishek Dave on 30/08/19.
//  Copyright © 2019 Apple Developer. All rights reserved.
//

import UIKit

protocol PostCellDelegate: AnyObject {
    func postTableViewCell(cell: PostCell, didUpdatedSelectionFor post: Post)
}

class PostCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var postSelectionSwitch: UISwitch!
    
    weak var delegate: PostCellDelegate?
    
    var post: Post! {
        didSet{
            self.titleLabel.text = post.title
            self.createdAtLabel.text = post.created_at
            self.updateUIForSelection(animated: false)
        }
    }
    
    
    
    @IBAction func postSelectionSwitchValueDidChange(_ sender: UISwitch) {
        self.toggleCellSelection()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func toggleCellSelection(){
        self.post.isSelected = !self.post.isSelected
        self.updateUIForSelection(animated: true)
        self.delegate?.postTableViewCell(cell: self, didUpdatedSelectionFor: self.post)
    }
    
    func updateUIForSelection(animated: Bool = false){
        self.postSelectionSwitch.setOn(self.post.isSelected, animated: animated)
        UIView.animate(withDuration: animated ? 0.25 : 0) {
            self.contentView.backgroundColor = self.post.isSelected
                ? UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
                : UIColor.white
        }
    }
}

//
//  SwipeMenuTableViewCell.swift
//  2018.08.08_test_api
//
//  Created by Jetec-RD on 2018/8/23.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit

class SwipeMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var menuImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        var borderLength: CGFloat {
            let width = self.menuImageView.frame.size.width
            let height = self.menuImageView.frame.size.height
            return (width >= height) ? height : width
        }
        menuImageView.frame.size.height = borderLength
        menuImageView.frame.size.width = borderLength
        menuImageView.center.x = self.center.x
//        nameLabel.layer.borderWidth = 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

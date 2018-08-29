//
//  AddDashboardTableViewCell.swift
//  2018.08.08_test_api
//
//  Created by macos on 2018/8/13.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit

class AddDashboardTableViewCell: UITableViewCell {

    @IBOutlet weak var innerLabel: UILabel!
    @IBOutlet weak var typeTextLabel: UILabel!
    
    @IBOutlet weak var contextLabel: UILabel!
    
    @IBOutlet weak var innerImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        stackView.layer.borderWidth = 0.5
//        stackView.layer.cornerRadius = 5
//        innerView.layer.borderWidth = 0.5
//        innerView.layer.cornerRadius = 5
        innerImageView.layer.borderWidth = 0.5
        innerImageView.layer.cornerRadius = 5
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

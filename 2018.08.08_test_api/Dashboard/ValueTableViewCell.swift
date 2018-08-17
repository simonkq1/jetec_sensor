//
//  ValueTableViewCell.swift
//  2018.08.08_test_api
//
//  Created by Jetec-RD on 2018/8/17.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit

class ValueTableViewCell: UITableViewCell {

    @IBOutlet weak var valueTextLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//
//  PanelClassTextField.swift
//  2018.08.08_test_api
//
//  Created by macos on 2018/8/14.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit

class PanelClassTextField: UITextField {
    
    override func awakeFromNib() {
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
        self.layer.borderColor = UIColor.black.cgColor
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

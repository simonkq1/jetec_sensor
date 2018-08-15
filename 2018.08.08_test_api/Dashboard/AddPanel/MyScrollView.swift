//
//  MyScrollView.swift
//  2018.08.08_test_api
//
//  Created by macos on 2018/8/15.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit

class MyScrollView: UIScrollView {
    
    var optionalIsEditing: Bool!
    var innerTextField: [UITextField]!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for i in self.innerTextField {
            if i.isEditing {
                DispatchQueue.main.async {
                    i.endEditing(true)
                }
            }
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

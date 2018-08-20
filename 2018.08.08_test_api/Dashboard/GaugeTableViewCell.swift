//
//  GaugeTableViewCell.swift
//  2018.08.08_test_api
//
//  Created by Jetec-RD on 2018/8/20.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit

class GaugeTableViewCell: UITableViewCell {

    var nibIsLoad: Bool = false
    var circleIsDraw: Bool = false
    var valueNibIsLoad: Bool = false
    var valueCircleIsDraw: Bool = false
    var backgroundShapeLayer: CAShapeLayer!
    var valueCircleShapeLayer: CAShapeLayer!
    var gaugePointerShaprLayer: CAShapeLayer!
    var centerCircleShaprLayer: CAShapeLayer!
    let circleWidth: CGFloat = 25
    var valueLabel = UILabel()
    @IBOutlet weak var innerView: UIView!
    var radius: CGFloat {
        let width = innerView.bounds.size.width
        let height = innerView.bounds.size.height
        return (width > height) ? (height - (circleWidth * 2)) : (width - (circleWidth * 2))
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        valueLabel.text = " "
        self.innerView.addSubview(valueLabel)
        
        
        
        self.innerView.frame.size.width = self.innerView.frame.size.height
//        self.innerView.layer.borderWidth = 1
//        drawBackCircle()
        
    }
    
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}



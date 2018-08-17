//
//  GaugeTableViewCell.swift
//  2018.08.08_test_api
//
//  Created by Jetec-RD on 2018/8/17.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit

class GaugeTableViewCell: UITableViewCell {
    
    var backgroundShapeLayer: CAShapeLayer!
    var foregroundShaprLayer: CAShapeLayer!
    
    @IBOutlet weak var innerView: UIView!
    var radius: CGFloat {
        let width = innerView.bounds.size.width
        let height = innerView.bounds.size.height
        return (width > height) ? (height - (circleWidth * 2)) : (width - (circleWidth * 2))
    }
    
    
    var circleWidth: CGFloat = 15 {
        didSet {
            backgroundShapeLayer.lineWidth = circleWidth
            foregroundShaprLayer.lineWidth = circleWidth
        }
    }
    
    var foregroundCircleColor: CGColor = UIColor.green.cgColor {
        didSet {
            foregroundShaprLayer.strokeColor = foregroundCircleColor
            foregroundShaprLayer.fillColor = UIColor.clear.cgColor
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        drawBackCircle()
        
    }
    
    func drawBackCircle() {
        backgroundShapeLayer = CAShapeLayer()
        let linePath = UIBezierPath(
            arcCenter: CGPoint(x: self.contentView.frame.size.width / 2, y: self.bounds.size.height - 20),
            radius: radius,
            startAngle: 2 * CGFloat.pi * 0.5,
            endAngle: 2 * CGFloat.pi,
            clockwise: true)
        
//        backgroundShapeLayer.frame = innerView.frame
        backgroundShapeLayer.path = linePath.cgPath
        backgroundShapeLayer.strokeColor = UIColor.black.cgColor
        backgroundShapeLayer.fillColor = UIColor.clear.cgColor
        backgroundShapeLayer.lineWidth = circleWidth
        
        self.layer.addSublayer(backgroundShapeLayer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

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
    var innerScaleShapeLayer: CAShapeLayer!
    var minLabel: UILabel!
    var maxLabel: UILabel!
    let circleWidth: CGFloat = 23
    let centerCircleRadius: CGFloat = 10
    var valueLabel = UILabel()
    var unitLabel = UILabel()
    var unit: String = " "
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var nameTextLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    var radius: CGFloat {
        let width = innerView.bounds.size.width
        let height = innerView.bounds.size.height
        return (width >= height) ? (height - (circleWidth * 2)) : (width - (circleWidth * 2))
    }
    var sensorId: String = ""
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        valueLabel.text = " "
        self.innerView.addSubview(valueLabel)
        
        
        self.innerView.frame.size.width = self.innerView.frame.size.height
        setIcon()
//        self.innerView.layer.borderWidth = 1
//        drawBackCircle()
        
    }
    
    
    func setIcon() {
        if sensorId.contains("humidity") {
            iconImageView.image = UIImage(named: "humidity_icon") ?? nil
            unit = " %"
        }else if sensorId.contains("wind_direction") {
            iconImageView.image = UIImage(named: "wind_direction_icon") ?? nil
            unit = " °"
            
        }else if sensorId.contains("temperature") {
            iconImageView.image = UIImage(named: "temp_icon") ?? nil
            unit = " °C"
            
        }else if sensorId.contains("precipitation") {
            iconImageView.image = UIImage(named: "rain_icon") ?? nil
            unit = " mm"
            
        }else if sensorId.contains("wind_speed") {
            iconImageView.image = UIImage(named: "wind_speed_icon") ?? nil
            unit = " m/s"
            
        }else {
            iconImageView.image = nil
            unit = " "
        }
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}



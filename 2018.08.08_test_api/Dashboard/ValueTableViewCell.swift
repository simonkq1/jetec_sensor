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
    @IBOutlet weak var nameTextLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    var sensorId: String = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setIcon()
    }
    
    func setIcon() {
        if sensorId.contains("humidity") {
            iconImageView.image = UIImage(named: "humidity_icon") ?? nil
        }else if sensorId.contains("wind_direction") {
            iconImageView.image = UIImage(named: "wind_direction_icon") ?? nil
            
        }else if sensorId.contains("temperature") {
            iconImageView.image = UIImage(named: "temp_icon") ?? nil
            
        }else if sensorId.contains("precipitation") {
            iconImageView.image = UIImage(named: "rain_icon") ?? nil
            
        }else if sensorId.contains("wind_speed") {
            iconImageView.image = UIImage(named: "wind_speed_icon") ?? nil
            
        }else {
            iconImageView.image = nil
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

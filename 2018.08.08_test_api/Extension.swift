//
//  Extension.swift
//  2018.08.08_test_api
//
//  Created by macos on 2018/8/15.
//  Copyright © 2018年 macos. All rights reserved.
//

import Foundation
import UIKit
import Charts




extension UIScrollView {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesBegan(touches, with: event)
    }
}

extension UITableViewCell {
    func selectionFlashingStyleAction(animateColor: UIColor = UIColor.lightGray, endColor: UIColor = UIColor(red: 207/255, green: 207/255, blue: 207/255, alpha: 1), timeInterval: Double = 0.1) {
        
        self.layer.backgroundColor = animateColor.cgColor
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { (timer) in
            self.layer.backgroundColor = endColor.cgColor
        }
    }
}

extension UIView {
    
}

extension MarkerView {
     enum ArrowPosition {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
    
    
    func drawChatBallonBorder(shapeLayer: CAShapeLayer, highlight: Highlight, offset: CGPoint, cornerRadius: CGFloat = 0, side: ArrowPosition) {
        
        let linePath = UIBezierPath()
        var radius: CGFloat {
            let width = self.frame.size.width
            let height = self.frame.size.height
            if cornerRadius <= 2 {
                return (width > height) ? height / 3 : width / 3
            }else if cornerRadius <= ((width > height) ? height / 3 : width / 3){
                return cornerRadius
            }else {
                return (width > height) ? height / 3 : width / 3
            }
        }
        
        switch side {
        case .topLeft:
            self.offset = CGPoint(x: (offset.x >= 0) ? offset.x : -offset.x, y: (offset.y >= 0) ? offset.y : -offset.y)
            if cornerRadius <= 0 {
                linePath.move(to: CGPoint(x: 0, y: radius))
                linePath.addLine(to: CGPoint(x: -self.offset.x, y: -self.offset.y))
                linePath.addLine(to: CGPoint(x: radius, y: 0))
                linePath.addLine(to: CGPoint(x: self.frame.size.width, y: 0))
                linePath.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
                linePath.addLine(to: CGPoint(x: 0, y: self.frame.size.height))
                linePath.close()
            }else {
                linePath.move(to: CGPoint(x: 0, y: (radius * 2)))
                linePath.addLine(to: CGPoint(x: -self.offset.x, y: -self.offset.y))
                linePath.addLine(to: CGPoint(x: (radius * 2), y: 0))
                
                linePath.addLine(to: CGPoint(x: self.frame.size.width - radius, y: 0))
                linePath.addArc(
                    withCenter: CGPoint(x: self.frame.size.width - radius, y: radius),
                    radius: radius,
                    startAngle: 270 / 360 * CGFloat.pi * 2,
                    endAngle: 0,
                    clockwise: true)
                
                linePath.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height - radius))
                linePath.addArc(
                    withCenter: CGPoint(x: self.frame.size.width - radius, y: self.frame.size.height - radius),
                    radius: radius,
                    startAngle: 0,
                    endAngle: 90 / 360 * CGFloat.pi * 2,
                    clockwise: true)
                
                linePath.addLine(to: CGPoint(x: radius, y: self.frame.size.height))
                linePath.addArc(
                    withCenter: CGPoint(x: radius, y: self.frame.size.height - radius),
                    radius: radius,
                    startAngle: 90 / 360 * CGFloat.pi * 2,
                    endAngle: 180 / 360 * CGFloat.pi * 2,
                    clockwise: true)
                linePath.close()
            }
            break
        case .topRight:
            self.offset = CGPoint(x: (offset.x >= 0) ? -self.frame.size.width - offset.x : -self.frame.size.width + offset.x, y: (offset.y >= 0) ? offset.y : -offset.y)
            if cornerRadius <= 0 {
                linePath.move(to: CGPoint(x: self.frame.size.width - radius, y: 0))
                linePath.addLine(to: CGPoint(x: -self.offset.x, y: -self.offset.y))
                linePath.addLine(to: CGPoint(x: self.frame.size.width, y: radius))
                
                linePath.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
                linePath.addLine(to: CGPoint(x: 0, y: self.frame.size.height))
                linePath.addLine(to: CGPoint(x: 0, y: 0))
                linePath.close()
            }else {
                linePath.move(to: CGPoint(x: self.frame.size.width - ((cornerRadius > 2) ? (radius * 2) : radius), y: 0))
                linePath.addLine(to: CGPoint(x: -self.offset.x, y: -self.offset.y))
                linePath.addLine(to: CGPoint(x: self.frame.size.width, y: ((cornerRadius > 2) ? (radius * 2) : radius)))
                
                linePath.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height - radius))
                linePath.addArc(
                    withCenter: CGPoint(x: self.frame.size.width - radius, y: self.frame.size.height - radius),
                    radius: radius,
                    startAngle: 0,
                    endAngle: 90 / 360 * CGFloat.pi * 2,
                    clockwise: true)
                
                linePath.addLine(to: CGPoint(x: radius, y: self.frame.size.height))
                linePath.addArc(
                    withCenter: CGPoint(x: radius, y: self.frame.size.height - radius),
                    radius: radius,
                    startAngle: 90 / 360 * CGFloat.pi * 2,
                    endAngle: 180 / 360 * CGFloat.pi * 2,
                    clockwise: true)
                
                linePath.addLine(to: CGPoint(x: 0, y: radius))
                linePath.addArc(
                    withCenter: CGPoint(x: radius, y: radius),
                    radius: radius,
                    startAngle: 180 / 360 * CGFloat.pi * 2,
                    endAngle: 270 / 360 * CGFloat.pi * 2,
                    clockwise: true)
                linePath.close()
            }
            break
        case .bottomLeft:
            self.offset = CGPoint(x: (offset.x >= 0) ? offset.x : -offset.x, y: (offset.y >= 0) ? -self.frame.size.height - offset.y : -self.frame.size.height + offset.y)
            if cornerRadius <= 0 {
                linePath.move(to: CGPoint(x: radius, y: self.frame.size.height))
                linePath.addLine(to: CGPoint(x: -self.offset.x, y: -self.offset.y))
                linePath.addLine(to: CGPoint(x: 0, y: self.frame.size.height - radius))
                linePath.addLine(to: CGPoint(x: 0, y: 0))
                linePath.addLine(to: CGPoint(x: self.frame.size.width, y: 0))
                linePath.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
                linePath.close()
            }else {
                linePath.move(to: CGPoint(x: ((cornerRadius > 2) ? (radius * 2) : radius), y: self.frame.size.height))
                linePath.addLine(to: CGPoint(x: -self.offset.x, y: -self.offset.y))
                linePath.addLine(to: CGPoint(x: 0, y: self.frame.size.height - ((cornerRadius > 2) ? (radius * 2) : radius)))
                linePath.addLine(to: CGPoint(x: 0, y: radius))
                linePath.addArc(
                    withCenter: CGPoint(x: radius, y: radius),
                    radius: radius,
                    startAngle: 180 / 360 * CGFloat.pi * 2,
                    endAngle: 270 / 360 * CGFloat.pi * 2,
                    clockwise: true)
                linePath.addLine(to: CGPoint(x: self.frame.size.width - radius, y: 0))
                linePath.addArc(
                    withCenter: CGPoint(x: self.frame.size.width - radius, y: radius),
                    radius: radius,
                    startAngle: 270 / 360 * CGFloat.pi * 2,
                    endAngle: 0,
                    clockwise: true)
                linePath.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height - radius))
                linePath.addArc(
                    withCenter: CGPoint(x: self.frame.size.width - radius, y: self.frame.size.height - radius),
                    radius: radius,
                    startAngle: 0,
                    endAngle: 90 / 360 * CGFloat.pi * 2,
                    clockwise: true)
                linePath.close()
            }
            break
        case .bottomRight:
            self.offset = CGPoint(x: (offset.x >= 0) ? -self.frame.size.width - offset.x : -self.frame.size.width + offset.x, y: (offset.y >= 0) ? -self.frame.size.height - offset.y : -self.frame.size.height + offset.y)
            if cornerRadius <= 0 {
                linePath.move(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height - radius))
                linePath.addLine(to: CGPoint(x: -self.offset.x, y: -self.offset.y))
                linePath.addLine(to: CGPoint(x: self.frame.size.width - radius, y: self.frame.size.height))
                linePath.addLine(to: CGPoint(x: 0, y: self.frame.size.height))
                linePath.addLine(to: CGPoint(x: 0, y: 0))
                linePath.addLine(to: CGPoint(x: self.frame.size.width, y: 0))
                linePath.close()
            }else {
                linePath.move(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height - ((cornerRadius > 2) ? (radius * 2) : radius)))
                linePath.addLine(to: CGPoint(x: -self.offset.x, y: -self.offset.y))
                linePath.addLine(to: CGPoint(x: self.frame.size.width - ((cornerRadius > 2) ? (radius * 2) : radius), y: self.frame.size.height))
                
                linePath.addLine(to: CGPoint(x: radius, y: self.frame.size.height))
                linePath.addArc(
                    withCenter: CGPoint(x: radius, y: self.frame.size.height - radius),
                    radius: radius,
                    startAngle: 90 / 360 * CGFloat.pi * 2,
                    endAngle: 180 / 360 * CGFloat.pi * 2,
                    clockwise: true)
                linePath.addLine(to: CGPoint(x: 0, y: radius))
                linePath.addArc(
                    withCenter: CGPoint(x: radius, y: radius),
                    radius: radius,
                    startAngle: 180 / 360 * CGFloat.pi * 2,
                    endAngle: 270 / 360 * CGFloat.pi * 2,
                    clockwise: true)
                linePath.addLine(to: CGPoint(x: self.frame.size.width - radius, y: 0))
                linePath.addArc(
                    withCenter: CGPoint(x: self.frame.size.width - radius, y: radius),
                    radius: radius,
                    startAngle: 270 / 360 * CGFloat.pi * 2,
                    endAngle: 0,
                    clockwise: true)
                linePath.close()
            }
            break
        }
        shapeLayer.path = linePath.cgPath
        self.layer.addSublayer(shapeLayer)
        
    }
}



extension Array {
    func getJsonString() -> String {
        let json = try? JSONSerialization.data(withJSONObject: self, options: [])
        let jsonString = String(data: json!, encoding: .utf8) ?? ""
        return jsonString
    }
}

extension Array where Element == Int {
    var total: Int {return reduce(0, +)}
    var average: Double {return (Double(total) / Double(count))}
    
}


extension Array where Element == Double {
    
    var total: Double {return reduce(0, +)}
    var average: Double {return (total / Double(count))}
    
    
}





extension Dictionary {
    func getJsonString() -> String {
        let json = try? JSONSerialization.data(withJSONObject: self, options: [])
        let jsonString = String(data: json!, encoding: .utf8) ?? ""
        return jsonString
    }
}


extension Data {
    
    func getJsonData() -> Any {
        var jsonData: Any!
        do {
            jsonData = try JSONSerialization.jsonObject(with: self, options: .allowFragments)
        }catch {
            
        }
        return jsonData
    }
    
}

extension String {
    
    func getJsonData() -> Any {
        var jsonData: Any!
        do {
            jsonData = try JSONSerialization.jsonObject(with: self.data(using: .utf8)!, options: .allowFragments)
        }catch {
            
        }
        return jsonData
    }
    
    
    func firstCharacterUppercase() -> String {
        var str: String!
        var origin = self
        let firstCharacter = self.uppercased().first
        var stringWithoutFirst: String {
            var a = origin.lowercased()
            a.remove(at: a.startIndex)
            return a
        }
        str = String(firstCharacter!) + stringWithoutFirst
        
        return str
    }
    
}

extension Double {
    
    func roundTo(places:Int) -> Double {
        
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
        
    }
}



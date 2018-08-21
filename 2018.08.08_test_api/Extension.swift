//
//  Extension.swift
//  2018.08.08_test_api
//
//  Created by macos on 2018/8/15.
//  Copyright © 2018年 macos. All rights reserved.
//

import Foundation
import UIKit


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




extension UIScrollView {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesBegan(touches, with: event)
    }
}


extension UIView {
    //
    //    func changeContainreView(storyboard: UIStoryboard? = nil, vc: UIViewController) {
    //        let controller = storyboard!.instantiateViewController(withIdentifier: "Second")
    //        addChildViewController(controller)
    //        controller.view.translatesAutoresizingMaskIntoConstraints = false
    //        self.addSubview(controller.view)
    //    }
}

extension Array {
    func getJsonString() -> String {
        let json = try? JSONSerialization.data(withJSONObject: self, options: [])
        let jsonString = String(data: json!, encoding: .utf8) ?? ""
        return jsonString
    }
}

extension Dictionary {
    func getJsonString() -> String {
        let json = try? JSONSerialization.data(withJSONObject: self, options: [])
        let jsonString = String(data: json!, encoding: .utf8) ?? ""
        return jsonString
    }
}



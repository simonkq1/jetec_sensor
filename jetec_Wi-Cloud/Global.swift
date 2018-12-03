//
//  Global.swift
//  2018.08.08_test_api
//
//  Created by macos on 2018/8/8.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit
import Starscream





class Global: NSObject {
    
    
    static var dash_storyboard: UIStoryboard = {
        return UIStoryboard(name: "Dashboard", bundle: Bundle.main)
    }()
    static var main_storyboard: UIStoryboard = {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }()
    static var socket: WebSocket!
    static var receiveData: [String: Any] = [:]
    
    class memberData: Global {
        static var authData: [String:Any] = [:]
        static var userData: [String:Any] = [:]
        static var homesData: [[String:Any]] = []
        static var devicesData: [[String:Any]] = []
        static var devicesInfo: [[[String: Any]]] = []
        static var authToken: String!
        static var onlineDevices: [[String: Any]] = []
        static var dashboardData: [[String: Any]] = []
    }
    
    
    
    static func postToURL(url: String, body: String, auth: String? = nil, action: ((_ returnData: Data?, _ returnString: String?,_ returnResponse: Int?) -> Void)? = nil ) {
        let posturl = URL(string: url)
        var request = URLRequest(url: posturl!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        if auth != nil {
            request.setValue(auth, forHTTPHeaderField: "Authorization")
        }
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let html = String(data: data, encoding: .utf8)
                var status: Int!
                if let httpStatus = response as? HTTPURLResponse {
                    // check status code returned by the http server
                    status = httpStatus.statusCode
                    print("status code = \(httpStatus.statusCode)")
                    // process result
                }
                
                if action != nil {
                    action!(data, html, status)
                }
            }
        }
        
        dataTask.resume()
        
    }
    
    
    static func getFromURL(url: String, auth: String? = nil, action: ((_ returnData: Data?, _ returnString: String?, _ returnResponse: Int?) -> Void)? = nil ) {
        
        let geturl = URL(string: url)
        var request = URLRequest(url: geturl!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        request.httpMethod = "GET"
        
        if auth != nil {
            request.setValue(auth, forHTTPHeaderField: "Authorization")
        }
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let html = String(data: data, encoding: .utf8)
                var status: Int!
                if let httpStatus = response as? HTTPURLResponse {
                    // check status code returned by the http server
                    status = httpStatus.statusCode
                    print("status code = \(httpStatus.statusCode)")
                    // process result
                }
                
                if action != nil {
                    action!(data, html, status)
                }
            }
        }
        
        dataTask.resume()
        
    }
    
    static func getDevices (homeId: Int, action: (() -> Void)? = nil) {
        let url = Basic.api + "/devices?homeId=" + "\(homeId)"
        Global.memberData.devicesData = []
        Global.getFromURL(url: url, auth: Global.memberData.authToken) { (data, html, status) in
            if status == 200 {
                do {
                    Global.memberData.devicesData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [[String:Any]]
                    
                    getDevicesInfo()
                    getDevicesInfo(action: action)
                }catch {
                    print(error)
                }
            }
        }
    }
    
    
    static private func getDevicesInfo(action: (() -> Void)? = nil) {
        Global.memberData.devicesInfo = []
        for i in Global.memberData.devicesData {
            let deviceId = i["id"] as! Int
            let url = Basic.api + "/devices/\(deviceId)/kv"
            Global.getFromURL(url: url, auth: Global.memberData.authToken) { (data, html, status) in
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [[String: Any]]
                    Global.memberData.devicesInfo.append(jsonData)
                    Global.memberData.devicesInfo = Global.memberData.devicesInfo.sorted { (d1, d2) -> Bool in
                        return ((d1[0]["value"] as! [String:Any])["gatewayId"] as! String) < ((d2[0]["value"] as! [String:Any])["gatewayId"] as! String)
                    }
                }catch {
                    
                }
            }
        }
        DispatchQueue.global().async {
            while true {
                if Global.memberData.devicesData.count == Global.memberData.devicesInfo.count {
                    if action != nil {
                        action!()
                    }
                }
            }
        }
    }
    
    
    static func regexGetSub(pattern:String, str:String) -> [String] {
        
        var subStr = [String]()
        let regex = try! NSRegularExpression(pattern: pattern, options:[])
        let matches = regex.matches(in: str, options: [], range: NSRange(str.startIndex...,in: str))
        //解析出子串
        for  match in matches {
            //        subStr.append(String(str[Range(match.range(at: 1), in: str)!]))
            //        subStr.append(String(str[Range(match.range(at: 2), in: str)!]))
            subStr.append(contentsOf: [String(str[Range(match.range(at: 1), in: str)!]),String(str[Range(match.range(at: 2), in: str)!])])
        }
        return subStr
        
    }
    
    static func connectToWebSocket(delegate: WebSocketDelegate) -> WebSocket {
        var request = URLRequest(url: URL(string: "wss://api.tinkermode.com/userSession/websocket")!)
        request.timeoutInterval = 5
        request.setValue(Global.memberData.authToken, forHTTPHeaderField: "Authorization")
        let socket = WebSocket(request: request)
        socket.delegate = delegate
        if !socket.isConnected {
            socket.connect()
        }
        return socket
    }
    
    static func getDirectionAngel(x: Double, y: Double) -> Double {
        let value: Double!
        
        if x > 0, y > 0 {
            //第一象限
            value = (atan(y / x) * (180 / Double.pi)) + 0
        }else if x < 0, y > 0 {
            //第二象限
            value = (atan(y / x) * (180 / Double.pi)) + 180
            
        }else if x < 0, y < 0{
            //第三象限
            value = (atan(y / x) * (180 / Double.pi)) + 180
            
        }else if x > 0, y < 0 {
            //第四象限
            value = (atan(y / x) * (180 / Double.pi)) + 360
            
        }else {
            value = 0
        }
        
        return value
    }
    
    
    
}

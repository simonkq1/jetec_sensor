//
//  Global.swift
//  2018.08.08_test_api
//
//  Created by macos on 2018/8/8.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit

struct Basic {
    static let api = "https://api.tinkermode.com"
}

struct Member {
    static let email = "tohsakarc@gmail.com"
    static let password = "jetec0000"
    static let projectId = "1010"
    static let appId = "webapp"
}

class Global: NSObject {
    
    class memberData: Global {
       static var authData: [String:Any] = [:]
       static var userData: [String:Any] = [:]
       static var homesData: [[String:Any]] = []
       static var devicesData: [[String:Any]] = []
        static var devicesInfo: [[[String: Any]]] = []
       static var authToken: String!
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
    
    

}

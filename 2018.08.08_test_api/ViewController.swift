//
//  ViewController.swift
//  2018.08.08_test_api
//
//  Created by macos on 2018/8/8.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit
import Starscream

class ViewController: UIViewController, WebSocketDelegate {
    
    var authData: [String:Any] = [:]
    var userData: [String:Any] = [:]
    var homesData: [[String:Any]] = []
    var devicesData: [[String:Any]] = []
    var homesIsGet: Bool = false
    var authToken: String!
    var socket: WebSocket!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getauth()
        while authData.count <= 0 {
            usleep(100000)
        }
        getUserData()
        getHomes()
        while homesIsGet == false {
            usleep(100000)
        }
        getDevices()
        
        conncetWebSocket()
    }
    
    
    
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("did connect")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("did disconnect")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print(text)
        print("did ReceiveMessage")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("didReceiveData")
    }
    
    
    func getauth() {
        let authurl = "https://api.tinkermode.com/auth/user"
        let authbody = "email=\(Member.email)&password=\(Member.password)&projectId=\(Member.projectId)&appId=\(Member.appId)"
        Global.postToURL(url: authurl, body: authbody, auth: nil) { (data, html, status) in
            do {
                self.authData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
            }catch {
                print(error)
            }
            self.authToken = "ModeCloud " + (self.authData["token"] as! String)
//            print(self.authData["userId"] as! Int)
        }
    }
    
    func getUserData (){
        let url = "https://api.tinkermode.com/users/" + "\(authData["userId"] as! Int)"
        Global.getFromURL(url: url, auth: authToken) { (data, html, status) in
            do {
                self.userData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
            }catch {
                print(error)
            }
        }
    }
    
    func getHomes () {
        let url = Basic.api + "/homes?userId=" + "\(authData["userId"] as! Int)"
        Global.getFromURL(url: url, auth: authToken) { (data, html, status) in
            do {
                self.homesData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [[String:Any]]
            }catch {
                print(error)
            }
            self.homesIsGet = true
        }
    }
    
    func getDevices () {
        
        for i in homesData {
            let url = Basic.api + "/devices?homeId=" + "\(i["id"] as! Int)"
            Global.getFromURL(url: url, auth: authToken) { (data, html, status) in
                do {
                    self.devicesData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [[String:Any]]
                }catch {
                    print(error)
                }
            }
        }
    }
    
    func conncetWebSocket () {

        var request = URLRequest(url: URL(string: "wss://api.tinkermode.com/userSession/websocket")!)
        request.timeoutInterval = 5
        request.setValue(authToken, forHTTPHeaderField: "Authorization")
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


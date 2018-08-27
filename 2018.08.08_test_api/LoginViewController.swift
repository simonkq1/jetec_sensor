//
//  LoginViewController.swift
//  2018.08.08_test_api
//
//  Created by macos on 2018/8/9.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    
    
    var authData: [String:Any] = [:]
    var userData: [String:Any] = [:]
    var homesData: [[String:Any]] = []
    var devicesData: [[String:Any]] = []
    var homesIsGet: Bool = false
    var authIsGet: Bool = false
    var userIsGet: Bool = false
    var devicesIsGet: Bool = false
    var dataIsReady: Bool = false
    var dataIsError: Bool = false
    var infoIsGet: Bool = false
    var authToken: String!
    let user = UserDefaults()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBAction func login(_ sender: Any) {
        self.dataIsReady = false
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        
        if email != "", password != "" {
            
            self.dataIsReady = false
            loginCheck(email: email, password: password, projectId: Basic.projectId)
            
            DispatchQueue.main.async {
                
                while true {
                    self.dataCheck()
                    if self.dataIsReady == true {
                        break
                    }
                    usleep(100000)
                    
                }
            }
            
            if dataIsError == false {
                user.setValue(email, forKey: "email")
                user.setValue(password, forKey: "password")
                user.synchronize()
                let vc = storyboard?.instantiateViewController(withIdentifier: "main_vc") as! MainViewController
                DispatchQueue.main.async {
                    self.show(vc, sender: nil)
//                    self.dismiss(animated: true, completion: nil)
                }
            }else {
                print("data is error")
            }
        }else {
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.text = "tohsakarc@gmail.com"
        passwordTextField.text = "jetec0000"
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    
    
    func loginCheck(email: String, password: String, projectId: String, appId: String = Basic.appId) {
        let authurl = "https://api.tinkermode.com/auth/user"
        let authbody = "email=\(email)&password=\(password)&projectId=\(projectId)&appId=\(appId)"
        Global.postToURL(url: authurl, body: authbody, auth: nil) { (data, html, status) in
            if status == 200 {
                do {
                    Global.memberData.authData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
                    Global.memberData.authToken = "ModeCloud " + (Global.memberData.authData["token"] as! String)
                    self.authIsGet = true
                    
                    self.getUserData()
                    self.getHomes()
                }catch {
                    print(error)
                }
            }else {
                self.dataIsReady = true
                self.dataIsError = true
                print("connect error")
            }
        }
    }
    
    
    func getUserData (){
        print("\(Global.memberData.authData["userId"] as! Int)")
        let url = "https://api.tinkermode.com/users/" + "\(Global.memberData.authData["userId"] as! Int)"
        Global.getFromURL(url: url, auth: Global.memberData.authToken) { (data, html, status) in
            if status == 200 {
                do {
                    Global.memberData.userData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
                    self.userIsGet = true
                }catch {
                    print(error)
                }
            }else {
                self.dataIsReady = true
                self.dataIsError = true
                print("userdata error")
            }
        }
    }
    
    func getHomes () {
        let url = Basic.api + "/homes?userId=" + "\(Global.memberData.authData["userId"] as! Int)"
        Global.getFromURL(url: url, auth: Global.memberData.authToken) { (data, html, status) in
            do {
                Global.memberData.homesData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [[String:Any]]
                self.homesIsGet = true
                
                let homeId = Global.memberData.homesData[0]["id"] as! Int
                self.getDevices(homeId: homeId)
            }catch {
                print(error)
            }
        }
    }
    
    func getDevices (homeId: Int, action: (() -> Void)? = nil) {
        let url = Basic.api + "/devices?homeId=" + "\(homeId)"
        Global.getFromURL(url: url, auth: Global.memberData.authToken) { (data, html, status) in
            if status == 200 {
                do {
                    Global.memberData.devicesData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [[String:Any]]
                    if action != nil {
                        action!()
                    }
                    self.getDevicesInfo()
                    self.devicesIsGet = true
                }catch {
                    print(error)
                }
            }
        }
    }
    
    func getDevicesInfo() {
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
        
        while Global.memberData.devicesInfo.count != Global.memberData.devicesData.count{
            usleep(150000)
        }
        self.getOnlineDevice()
        self.infoIsGet = true
    }
    
    
    func getOnlineDevice() {
        var check = true
        Global.memberData.onlineDevices = []
        for i in 0..<Global.memberData.devicesData.count {
            var devices: [String: Any] = [:]
            let isConnect: Bool = ((Global.memberData.devicesData[i]["isConnected"] as! Int) == 1) ? true : false
            if isConnect {
                for j in 0..<Global.memberData.devicesInfo[i].count {
                    let deviceValue = Global.memberData.devicesInfo[i][j]["value"] as! [String:Any]
                    Global.memberData.onlineDevices.append(deviceValue)
                }
                check = false
            }
        }
        while check {
            usleep(150000)
        }
        
    }
    
    func dataCheck() {
        if self.authIsGet == true, self.userIsGet == true, self.homesIsGet == true, self.devicesIsGet == true, self.infoIsGet == true {
            self.dataIsReady = true
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

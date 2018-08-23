//
//  AppDelegate.swift
//  2018.08.08_test_api
//
//  Created by macos on 2018/8/8.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let user = UserDefaults()
    
    var homesIsGet: Bool = false
    var authIsGet: Bool = false
    var userIsGet: Bool = false
    var devicesIsGet: Bool = false
    var dataIsReady: Bool = false
    var dataIsError: Bool = false
    var infoIsGet: Bool = false


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        
        
        let auto_vc = (UIStoryboard(name: "Main", bundle: Bundle.main)).instantiateViewController(withIdentifier: "main_vc") as! MainViewController
        let login_vc = (UIStoryboard(name: "Main", bundle: Bundle.main)).instantiateViewController(withIdentifier: "login_vc") as! LoginViewController
        if let email = user.string(forKey: "email"), let password = user.string(forKey: "password") {
            //if email and password is not nil
            if email != "", password != "" {
                // if email and password is not nil, and not empty
                
                autoLogin(email, password) {
                    if dataIsError == false {
                        // if login success
                        window?.rootViewController = auto_vc
                    }else {
                        // if login faild
                        window?.rootViewController = login_vc
                    }
                }
            }else {
                // if email and password is empty
                window?.rootViewController = login_vc
            }
            
        }else {
            // if email and password is nil
            window?.rootViewController = login_vc
        }
        window?.makeKeyAndVisible()
        return true
    }
    
    func autoLogin(_ email: String, _ password: String, action: () -> Void) {
        
        self.dataIsReady = false
        loginCheck(email: email, password: password, projectId: Basic.projectId)
        
        while true {
            dataCheck()
            if dataIsReady == true {
                break
            }
            usleep(100000)
        }
        
        if dataIsError == false {
            action()
        }
        
        
    }
    
    
    func loginCheck(email: String, password: String, projectId: String, appId: String = "webapp") {
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
    
    
    
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


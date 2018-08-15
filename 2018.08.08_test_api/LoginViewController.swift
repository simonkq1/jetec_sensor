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
    var authToken: String!
    let user = UserDefaults()
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBAction func login(_ sender: Any) {
        self.dataIsReady = false
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        
        if email != "", password != "" {
            
            loginCheck(email: email, password: password, projectId: Basic.projectId)
            
            while true {
                dataCheck()
                if dataIsReady == true {
                    break
                }
            }
            
            if dataIsError == false {
                user.setValue(email, forKey: "email")
                user.setValue(password, forKey: "password")
                
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
    
    
    var subStr = [String]()
    
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
                    self.devicesIsGet = true
                }catch {
                    print(error)
                }
            }
        }
    }
    
    
    
    func dataCheck() {
        if self.authIsGet == true, self.userIsGet == true, self.homesIsGet == true, self.devicesIsGet == true {
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

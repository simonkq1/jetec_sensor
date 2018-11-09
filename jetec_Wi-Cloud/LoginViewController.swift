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
    var dataIsError: Bool = true
    var infoIsGet: Bool = false
    var authToken: String!
    let user = UserDefaults()
    var originY: CGFloat!
    var isNotEmpty: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.loginButton.backgroundColor = self.isNotEmpty ? Color.loginButtonColor : UIColor.lightGray
                self.loginButton.isEnabled = self.isNotEmpty
            }
        }
    }
    
    
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loadingAction: UIActivityIndicatorView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBAction func login(_ sender: Any) {
        self.dataIsReady = false
        self.dataIsError = true
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if email != "", password != "" {
            DispatchQueue.main.async {
                self.loadingAction.startAnimating()
                self.loadingAction.alpha = 1
                usleep(100000)
                for i in self.view.subviews {
                    if i is UIButton {
                        (i as! UIButton).isEnabled = false
                    }
                    if i is UITextField {
                        (i as! UITextField).isEnabled = false
                    }
                }
            }
            self.dataIsReady = false
            loginCheck(email: email, password: password, projectId: Basic.projectId)
            
//            DispatchQueue.main.async {
            
                while true {
                    self.dataCheck()
                    if self.dataIsReady == true {
                        break
                    }
                    usleep(100000)
                    
                }
//            }
            
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
                for i in self.view.subviews {
                    if i is UIButton {
                        (i as! UIButton).isEnabled = true
                    }
                    if i is UITextField {
                        (i as! UITextField).isEnabled = true
                    }
                }
                if self.loadingAction.isAnimating {
                    self.loadingAction.stopAnimating()
                    self.loadingAction.alpha = 0
                }
            }
        }else {
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.text = "tohsakarc@gmail.com"
        passwordTextField.text = "jetec0000"
        loadingAction.stopAnimating()
        loadingAction.alpha = 0
        isNotEmpty = false
        passwordTextField.isSecureTextEntry = true
        emailTextField.borderStyle = .none
        passwordTextField.borderStyle = .none
        emailTextField.placeholder = "login_email_placeholder".localized
        passwordTextField.placeholder = "login_password_placeholder".localized
        loginButton.setTitle("login_button_title".localized, for: UIControl.State.normal)
        loginButton.layer.cornerRadius = 5
        
        
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillRise(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillFall(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        emailTextField.addTarget(self, action: #selector(keyboardReturnAction(sender:)), for: UIControl.Event.editingDidEndOnExit)
        passwordTextField.addTarget(self, action: #selector(keyboardReturnAction(sender:)), for: UIControl.Event.editingDidEndOnExit)
        
        checkTextFieldIsNotEmpty()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.originY = self.view.frame.origin.y
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if emailTextField.isEditing {
            emailTextField.endEditing(true)
        }
        if passwordTextField.isEditing {
            passwordTextField.endEditing(true)
        }
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
                
                let alert = UIAlertController(title: "login_error_alert_title".localized, message: "login_error_alert_message".localized, preferredStyle: .alert)
                let ok = UIAlertAction(title: "logout_alert_ok".localized, style: UIAlertAction.Style.default, handler: { (action) in
                    DispatchQueue.main.async {
                        
                        alert.dismiss(animated: true, completion: nil)
                        if self.loadingAction.isAnimating {
                            self.loadingAction.stopAnimating()
                            self.loadingAction.alpha = 0
                            self.passwordTextField.text?.removeAll()
                            for i in self.view.subviews {
                                if i is UITextField {
                                    if !(i as! UITextField).isEnabled {
                                        (i as! UITextField).isEnabled = true
                                    }
                                }
                                if i is UIButton {
                                    if !(i as! UIButton).isEnabled {
                                        (i as! UIButton).isEnabled = true
                                    }
                                }
                            }
                        }
                    }
                })
                alert.addAction(ok)
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
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
            self.dataIsError = false
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func checkTextFieldIsNotEmpty() {
        DispatchQueue.global().async {
            while true {
                DispatchQueue.main.async {
                    if self.passwordTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count != 0, self.emailTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count != 0 {
                        self.isNotEmpty = true
                    }else {
                        self.isNotEmpty = false
                    }
                }
                usleep(100000)
            }
        }
    }
    
    @objc func keyboardReturnAction(sender: UITextField) {
        DispatchQueue.main.async {
            sender.endEditing(true)
        }
    }
    
    
    @objc func keyboardWillRise(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        
        if self.view.frame.origin.y == originY {
            UIView.animate(withDuration: 0.1, animations: {
                self.view.frame.origin.y -= keyboardFrame.height / 3
            })
        }
        
    }
    @objc func keyboardWillFall(notification: NSNotification) {
        if self.view.frame.origin.y != originY {
            
            UIView.animate(withDuration: 0.1, animations: {
                self.view.frame.origin.y = self.originY
            })
        }
        
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

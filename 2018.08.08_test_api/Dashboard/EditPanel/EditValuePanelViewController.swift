//
//  EditValuePanelViewController.swift
//  2018.08.08_test_api
//
//  Created by Jetec-RD on 2018/8/21.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit
import DropDown

class EditValuePanelViewController: UIViewController {
    
    // MARK: IBOutlet
    @IBOutlet weak var nameTextField: PanelClassTextField!
    @IBOutlet weak var sensorModuleButton: PanelClassButton!
    @IBOutlet weak var typeButton: PanelClassButton!
    
    
    // MARK: Variables
    lazy var sensorList: [String] = {
        var list: [String] = []
        for i in Global.memberData.onlineDevices {
            let deviceName = i["name"] as! String
            list.append(deviceName)
        }
        if list.count <= 0 {
            list = ["No module is online"]
        }
        return list
    }()
    
    var typeList: [String: Any] = [:]
    var sensorTypeList: [String]!
    
    var selectModuleIndex: Int?
    var selectSensorIndex: Int?
    var isShow: Bool = false
    var originY: CGFloat!
    var addPanelButton = UIBarButtonItem()
    var dataIsReady: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.addPanelButton.isEnabled = self.dataIsReady
            }
        }
    }
    var panelData: [String: Any] = [:]
    let user = UserDefaults()
    var dashboard_vc: DashboardTableViewController!
    var dashboardIndex: Int!
    
    
    
    
    
    //MARK: - IBAction
    
    @IBAction func sensorModuleButtonAction(_ sender: Any) {
        selectModuleIndex = nil
        selectSensorIndex = nil
        dataIsReady = false
        typeList["show"] = ["Select a sensor"]
        typeButton.titleLabel?.text = "Select a sensor"
        dropDownAction(list: sensorList, anchorView: sensorModuleButton) { (sender, item, index) in
            self.sensorModuleButton.titleLabel?.text = self.sensorList[index]
            self.selectModuleIndex = index
        }
    }
    @IBAction func typeButtonAction(_ sender: Any) {
        selectSensorIndex = nil
        dataIsReady = false
        typeList = [:]
        var list: [String] = []
        var trueList: [String] = []
        if let index = selectModuleIndex {
            let a: [String] = Global.memberData.onlineDevices[index]["sensors"] as! [String]
            for i in 0..<a.count {
                var sensor = (a[i].replacingOccurrences(of: ":0", with: "")).replacingOccurrences(of: "_", with: " ")
                let sensorFirst = sensor.first
                sensor.remove(at: sensor.startIndex)
                let sensortitle = "\(String(sensorFirst!).uppercased())\(sensor.lowercased())"
                trueList.append(a[i])
                list.append(sensortitle)
                
            }
            typeList["show"] = list
            typeList["true"] = trueList
        }else {
            typeList["show"] = ["Select a sensor"]
        }
        dropDownAction(list: (typeList["show"] as! [String]), anchorView: typeButton) { (sender, item, index) in
            if (self.typeList["show"] as! [String])[0] != "Select a sensor" {
                self.typeButton.titleLabel?.text = (self.typeList["show"] as! [String])[index]
                self.dataIsReady = true
                self.selectSensorIndex = index
                
            }
        }
    }
    
    //MARK: - System Function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        sensorModuleButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        typeButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillRise(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillFall(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        nameTextField.addTarget(self, action: #selector(nameReturnAction), for: UIControlEvents.editingDidEndOnExit)
        
        addPanelButton.target = self
        addPanelButton.style = .plain
        addPanelButton.action = #selector(addPanelBarButtonAction)
        addPanelButton.title = "Add"
        let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelBarButtonAction))
        self.navigationItem.rightBarButtonItem = addPanelButton
        self.navigationItem.leftBarButtonItem = cancelBarButton
        dataIsReady = false
        
        print(panelData)
        
        
        DispatchQueue.global().async {
            while true {
                DispatchQueue.main.async {
                    self.addPanelButton.isEnabled = self.checkDataIsReady()
                }
                usleep(200000)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getBaseData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        originY = self.view.frame.origin.y
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameTextField.endEditing(true)
    }
    
    //MARK: - Custom Function
    
    
    
    func getBaseData() {
        
        let moduleIndex = Global.memberData.onlineDevices.index { (data) -> Bool in
            return (data["id"] as! String) == (panelData["sensorModule"] as! String)
        }
        selectModuleIndex = moduleIndex
        if selectModuleIndex != nil {
            DispatchQueue.main.async {
                print(self.selectModuleIndex)
                self.sensorModuleButton.titleLabel?.text = self.sensorList[self.selectModuleIndex!]
                self.typeButton.titleLabel?.text = self.panelData["sensorType"] as! String
                
            }
            
            var list: [String] = []
            var trueList: [String] = []
            
            if let index = self.selectModuleIndex {
                let a: [String] = Global.memberData.onlineDevices[index]["sensors"] as! [String]
                for i in 0..<a.count {
                    var sensor = (a[i].replacingOccurrences(of: ":0", with: "")).replacingOccurrences(of: "_", with: " ")
                    let sensorFirst = sensor.first
                    sensor.remove(at: sensor.startIndex)
                    let sensortitle = "\(String(sensorFirst!).uppercased())\(sensor.lowercased())"
                    trueList.append(a[i])
                    list.append(sensortitle)
                    
                }
                self.typeList["show"] = list
                self.typeList["true"] = trueList
            }else {
                self.typeList["show"] = ["Select a sensor"]
            }
            var typeIndex: Int? {
                var tmpindex: Int? = nil
                if let showList = self.typeList["show"] {
                    let tmplist = (showList as! [String])
                    let a = (tmplist.index { (data) -> Bool in
                        return data == (panelData["sensorType"] as! String)
                    })
                    tmpindex = a
                }
                return tmpindex
            }
            selectSensorIndex = typeIndex
            nameTextField.text = (panelData["name"] as! String)
            
        }
    }
    
    func checkDataIsReady() -> Bool {
        var bol: Bool = false
        if selectSensorIndex != nil, selectModuleIndex != nil {
            bol = true
        }
        return bol
    }
    
    
    
    
    @objc func addPanelBarButtonAction() {
        
        if self.dataIsReady {
            if let moduleIndex = self.selectModuleIndex, let sensorIndex = self.selectSensorIndex {
                var sensorType: String {
                    let a = ((typeList["true"] as! [String])[sensorIndex]).replacingOccurrences(of: ":0", with: "")
                    let b = a.replacingOccurrences(of: "_", with: " ")
                    return b.firstCharacterUppercase()
                }
                var name: String {
                    let a = String((nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!)
                    return a
                }
                
                self.panelData = [
                    "name":name,
                    "sensorType":sensorType,
                    "sensorId":(typeList["true"] as! [String])[sensorIndex],
                    "sensorModule":Global.memberData.onlineDevices[moduleIndex]["id"] as! String,
                    "panelType":"VALUE"
                ]
                print("--------------------")
                Global.memberData.dashboardData[dashboardIndex] = panelData
                
                
                let json = try? JSONSerialization.data(withJSONObject: Global.memberData.dashboardData, options: [])
                
                let dashboardJson = String(data: json!, encoding: .utf8)
                user.setValue(dashboardJson, forKey: "dashboardJson")
                user.synchronize()
                
                for i in self.view.subviews {
                    if i is UITextField {
                        if (i as! UITextField).isEditing {
                            (i as! UITextField).endEditing(true)
                        }
                    }
                }
                self.dashboard_vc.viewDidLoad()
                self.dashboard_vc.tableView.reloadData()
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        
        
    }
    
    
    
    @objc func cancelBarButtonAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func nameReturnAction() {
        nameTextField.endEditing(true)
    }
    
    @objc func keyboardWillRise(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y == originY {
            
            UIView.animate(withDuration: 0.1, animations: {
                self.view.frame.origin.y -= keyboardFrame.height
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
    
    func dropDownAction(list: [String], anchorView: AnchorView, action: ((_ sender: DropDown, _ item: String, _ index: Int) -> Void)? = nil) {
        let dropdown = DropDown()
        if dropdown.isHidden {
            dropdown.anchorView = anchorView
            dropdown.dataSource = list
            dropdown.direction = .bottom
            dropdown.bottomOffset = CGPoint(x: 0, y: (dropdown.anchorView?.plainView.bounds.height)!)
            if list[0] == "Select a sensor" || list[0] == "No module is online" {
                dropdown.textColor = UIColor.gray
            }
            dropdown.selectionAction = { [unowned self] (index: Int, item: String) in
                print("Selected item: \(item) at index: \(index)")
                if action != nil {
                    action!(dropdown, item, index)
                }
            }
            dropdown.show()
        }else {
            dropdown.hide()
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

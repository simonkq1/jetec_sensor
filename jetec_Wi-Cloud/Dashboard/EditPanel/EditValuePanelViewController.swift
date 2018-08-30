//
//  EditValuePanelViewController.swift
//  2018.08.08_test_api
//
//  Created by Jetec-RD on 2018/8/21.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit
import iOSDropDown

class EditValuePanelViewController: UIViewController {
    
    // MARK: IBOutlet
    @IBOutlet weak var nameTextField: PanelClassTextField!
    
    @IBOutlet weak var moduleDropDownTextField: DropDown!
    @IBOutlet weak var sensorDropDownTextField: DropDown!
    @IBOutlet weak var moduleTitleLabel: UILabel!
    @IBOutlet weak var sensorTitleLabel: UILabel!
    @IBOutlet weak var nameTitleLabel: UILabel!
    
    
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
    
    lazy var typeList: [String: Any] =  {
        self.typeList = [:]
        var returnList: [String: Any] = [:]
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
            returnList["show"] = list
            returnList["true"] = trueList
            return returnList
        }else {
            returnList["show"] = ["Select a sensor"]
            return returnList
        }
    }()
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
    
    
    //MARK: - System Function
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Localize
        moduleTitleLabel.text = "panel_configure_module".localized
        sensorTitleLabel.text = "panel_configure_sensor".localized
        nameTitleLabel.text = "panel_configure_name".localized
        nameTextField.placeholder = "panel_configure_placeholder_name".localized
        // Do any additional setup after loading the view.
        
        moduleDropDownTextField.placeholder = "panel_configure_placeholder_module".localized
        sensorDropDownTextField.placeholder = "panel_configure_placeholder_sensor".localized
        
        moduleDropDownTextField.borderWidth = 1
        sensorDropDownTextField.borderWidth = 1
        moduleDropDownTextField.cornerRadius = 5
        sensorDropDownTextField.cornerRadius = 5
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillRise(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillFall(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        nameTextField.addTarget(self, action: #selector(nameReturnAction), for: UIControlEvents.editingDidEndOnExit)
        
        addPanelButton.target = self
        addPanelButton.style = .plain
        addPanelButton.action = #selector(addPanelBarButtonAction)
        addPanelButton.title = "bar_button_done".localized
        let cancelBarButton = UIBarButtonItem(title: "bar_button_cancel".localized, style: .plain, target: self, action: #selector(cancelBarButtonAction))
        self.navigationItem.rightBarButtonItem = addPanelButton
        self.navigationItem.leftBarButtonItem = cancelBarButton
        dataIsReady = false
        
        print(panelData)
        
        self.dropDownSetting()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getBaseData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        originY = self.view.frame.origin.y
        DispatchQueue.global().async {
            while true {
                self.checkDataIsReady()
                usleep(100000)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameTextField.endEditing(true)
    }
    
    //MARK: - Custom Function
    
    
    func dropDownSetting() {
        
        moduleDropDownTextField.isSearchEnable = false
        sensorDropDownTextField.isSearchEnable = false
        moduleDropDownTextField.rowHeight = 44
        sensorDropDownTextField.rowHeight = 44
        moduleDropDownTextField.selectedRowColor = UIColor(red: 161/255, green: 217/255, blue: 229/255, alpha: 1)
        sensorDropDownTextField.selectedRowColor = UIColor(red: 161/255, green: 217/255, blue: 229/255, alpha: 1)
        moduleDropDownTextField.dropDown(list: sensorList) { (text, index, id) in
            print("text: \(text), index: \(index)")
            if let _ = self.selectModuleIndex {
                if self.selectModuleIndex != index {
                    self.sensorDropDownTextField.text = ""
                    self.selectSensorIndex = nil
                    self.sensorDropDownTextField.selectedIndex = nil
                    self.sensorDropDownTextField.optionArray = ["Select a sensor"]
                }
            }
            self.selectModuleIndex = index
            
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
            self.sensorDropDownTextField.optionArray = self.typeList["show"] as! [String]
            
            
        }
        
        
        sensorDropDownTextField.dropDown(list: typeList["show"] as! [String]) { (text, index, id) in
            self.selectSensorIndex = index
        }
        
        
        
        moduleDropDownTextField.listWillAppear {
            if self.sensorDropDownTextField.isSelected {
                self.sensorDropDownTextField.hideList()
            }
            if self.nameTextField.isEditing {
                self.nameTextField.endEditing(true)
            }
        }
        
        
        
        sensorDropDownTextField.listWillAppear {
            if self.moduleDropDownTextField.isSelected {
                self.moduleDropDownTextField.hideList()
            }
            if self.nameTextField.isEditing {
                self.nameTextField.endEditing(true)
            }
        }
        
    }
    
    
    
    func getBaseData() {
        
        let moduleIndex = Global.memberData.onlineDevices.index { (data) -> Bool in
            return (data["id"] as! String) == (panelData["sensorModule"] as! String)
        }
        selectModuleIndex = moduleIndex
        moduleDropDownTextField.selectedIndex = selectModuleIndex
        
        
        if selectModuleIndex != nil {
            DispatchQueue.main.async {
                print(self.selectModuleIndex)
                self.moduleDropDownTextField.text = self.sensorList[self.selectModuleIndex!]
                self.sensorDropDownTextField.text = self.panelData["sensorType"] as! String
                
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
            sensorDropDownTextField.optionArray = typeList["show"] as! [String]
            sensorDropDownTextField.selectedIndex = selectSensorIndex
            nameTextField.text = (panelData["name"] as! String)
            
        }
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
        
        for i in self.view.subviews {
            if i is DropDown {
                if (i as! DropDown).isSelected {
                    (i as! DropDown).hideList()
                }
            }
        }
        
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
    
    func checkDataIsReady() {
        if self.selectModuleIndex != nil, self.selectSensorIndex != nil {
            DispatchQueue.main.async {
                self.dataIsReady = true
            }
        }else {
            DispatchQueue.main.async {
                self.dataIsReady = false
            }
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

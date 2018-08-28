//
//  TimeSeriesGraphViewController.swift
//  2018.08.08_test_api
//
//  Created by macos on 2018/8/14.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit
import DropDown

class TimeSeriesGraphViewController: UIViewController {
    
    
    @IBOutlet weak var nameTextField: PanelClassTextField!
    @IBOutlet weak var sensorModuleButton: PanelClassButton!
    
    @IBOutlet weak var dateRangeButton: PanelClassButton!
    @IBOutlet weak var typeButton: PanelClassButton!
    
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
    var dateList: [String] = ["1 day","7 days","30 days","90 days"]
    
    var selectModuleIndex: Int?
    var selectSensorIndex: Int?
    var selectDateIndex: Int = 0
    var isShow: Bool = false
    var originY: CGFloat!
    var addPanelButton = UIBarButtonItem()
    var dataIsReady: Bool = false {
        didSet {
            if selectModuleIndex != nil, selectSensorIndex != nil{
                DispatchQueue.main.async {
                    self.addPanelButton.isEnabled = self.dataIsReady
                }
            }
        }
    }
    var panelData: [String: Any] = [:]
    
    let user = UserDefaults()
    var dashboard_vc: DashboardTableViewController!

    @IBAction func sensorModuleButtonAction(_ sender: Any) {
        selectModuleIndex = nil
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
                self.selectSensorIndex = index
                self.dataIsReady = true
                
            }
        }
    }
    
    @IBAction func dateRangeButtonAction(_ sender: Any) {
        
        dropDownAction(list: dateList, anchorView: dateRangeButton) { (sender, item, index) in
            
                self.dateRangeButton.titleLabel?.text = self.dateList[index]
                self.selectDateIndex = index
        }
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        sensorModuleButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        typeButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        dateRangeButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillRise(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillFall(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        nameTextField.addTarget(self, action: #selector(nameReturnAction), for: UIControlEvents.editingDidEndOnExit)
        
        addPanelButton.target = self
        addPanelButton.style = .plain
        addPanelButton.action = #selector(addPanelBarButtonAction)
        addPanelButton.title = "Add"
        self.navigationItem.rightBarButtonItem = addPanelButton
        dataIsReady = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        originY = self.view.frame.origin.y
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameTextField.endEditing(true)
    }
    
    
    //MARK: - Function Area
    
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
                var duration: String {
                    var a: String!
                    switch selectDateIndex {
                    case 0:
                        a = "1d"
                        break
                    case 1:
                        a = "7d"
                        break
                    case 2:
                        a = "30d"
                        break
                    case 3:
                        a = "90d"
                        break
                    default:
                        a = "1d"
                        break
                    }
                    return a
                }
                self.panelData = [
                    "duration":duration, 
                    "name":name,
                    "sensorType":sensorType,
                    "sensorId":(typeList["true"] as! [String])[sensorIndex],
                    "sensorModule":Global.memberData.onlineDevices[moduleIndex]["id"] as! String,
                    "panelType":"GRAPH"
                ]
                print("--------------------")
                Global.memberData.dashboardData.append(self.panelData)
                
                
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

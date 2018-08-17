//
//  DashboardTableViewController.swift
//  2018.08.08_test_api
//
//  Created by macos on 2018/8/13.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit
import Starscream

class DashboardTableViewController: UITableViewController, WebSocketDelegate {
    
    
    
    
    
    var dashboardData: [String: Any] = [:]
    var userDashboard: [[String:Any]] = []
    var dashboardIsGet: Bool = false
    let user = UserDefaults()
    var editingButton: UIBarButtonItem!
    var addButton: UIBarButtonItem!
    lazy var leftBarItems: [UIBarButtonItem] = {
        return [editingButton, addButton]
    }()
    var timeSeriesData: [[String:Any]] = []
    
    var selectIndexPath: IndexPath!
    
    let textLabel = UILabel()
    var socket: WebSocket!
    var receiveData: [String: Any] = [:]
    
    //MARK: - System Function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        
        if let myDashboard = user.object(forKey: "dashboardJson") {
            do {
                let data = (myDashboard as! String).data(using: .utf8)
                Global.memberData.dashboardData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [[String: Any]]
            }catch {
                
            }
        }
        
        
        
        drawNoDataMessage()
        print("********************")
        getTimeSeriesData()
        self.timeSeriesData = self.timeSeriesData.sorted(by: { (d1, d2) -> Bool in
            return (d1["order"] as! Int) < (d2["order"] as! Int)
        })
        
        
        editingButton = UIBarButtonItem(image: UIImage(named: "edit_icon"), style: .plain, target: self, action: #selector(editingBarButtonAction(sender:)))
        addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addBarButtonAction(_:)))
        self.navigationItem.rightBarButtonItems = leftBarItems
        tableView.register(UINib(nibName: "GaugeTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "gauge_cell")
        
        tableView.register(UINib(nibName: "ValueTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "value_cell")
        
        
        socket = Global.connectToWebSocket(delegate: self)
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        if socket != nil {
            if socket.isConnected {
                socket.disconnect()
            }
        }
    }
    
    //MARK: - Socket Event Action
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("Connect Socket")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        
        print("disConnect Socket")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("************************")
        DispatchQueue.main.async {
            self.receiveData = text.getJsonData() as! [String: Any]
            self.tableView.reloadData()
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
    
    
    
    
    
    
    // MARK:- Function Area
    
    func drawNoDataMessage() {
        
        if Global.memberData.dashboardData.count <= 0 {
            textLabel.center = view.center
            textLabel.frame.origin = CGPoint(x: self.view.center.x, y: self.view.center.y)
            textLabel.frame.size = CGSize(width: self.view.bounds.size.width - 30, height: self.view.bounds.size.height - 30)
            textLabel.center.x = view.center.x
            textLabel.center.y = view.center.y - ((self.navigationController?.navigationBar.frame.size.height) ?? 44)
            textLabel.textAlignment = .center
            textLabel.font = UIFont.systemFont(ofSize: 50)
            textLabel.textColor = UIColor.lightGray
            textLabel.numberOfLines = 0
            textLabel.alpha = 1
            textLabel.text = "You have no panel, add one!"
            DispatchQueue.main.async {
                self.view.addSubview(self.textLabel)
            }
            
        }else {
            
            textLabel.alpha = 0
        }
    }
    
    
    func getTimeSeriesData() {
        
        if Global.memberData.dashboardData.count > 0 {
            timeSeriesData = []
            let formatter = DateFormatter()
            formatter.dateFormat = Basic.dateFormate
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            let now = formatter.string(from: (Date() - 60))
            print("AAA")
            print(now)
            let target = formatter.string(from: (Date() - 60 - (60 * 60 * 24)))
            print(target)
            for i in 0..<Global.memberData.dashboardData.count {
                var check = true
                let panelType = Global.memberData.dashboardData[i]["panelType"] as! String
                let moduleId = Global.memberData.dashboardData[i]["sensorModule"] as! String
                let sensorId = (Global.memberData.dashboardData[i]["sensorId"] as! String).lowercased()
                let moduleSensorID = moduleId + "-\(sensorId)"
                var seriesdata: [String: Any] = [:]
                
                
                print("----------------")
                print(moduleSensorID)
                var url = "https://api.tinkermode.com/homes/744/smartModules/tsdb/timeSeries/\(moduleSensorID)/data?begin=\(target)&end=\(now)&aggregation="
                
                
                if sensorId.lowercased().contains("precipitation") {
                    url = url + "sum"
                }else {
                    url = url + "avg"
                }
                
                switch panelType {
                case "VALUE":
                    timeSeriesData.append(["order":i, "data":seriesdata])
                    check = false
                    break
                case "GAUGE":
                    timeSeriesData.append(["order":i, "data":seriesdata])
                    check = false
                    
                    break
                case "GRAPH":
                    Global.getFromURL(url: url, auth: Global.memberData.authToken) { (data, html, respond) in
                        seriesdata = html?.getJsonData() as! [String: Any]
                        self.timeSeriesData.append(["order":i, "data":seriesdata])
                        check = false
                    }
                    break
                case "DATA":
                    Global.getFromURL(url: url, auth: Global.memberData.authToken) { (data, html, respond) in
                        seriesdata = html?.getJsonData() as! [String: Any]
                        self.timeSeriesData.append(["order":i, "data":seriesdata])
                        check = false
                    }
                    break
                case "ALERT":
                    check = false
                    break
                default:
                    break
                }
                while check {
                    usleep(200000)
                }
            }
            // quit loop
            
        }
    }
    
    
    
    
    
    
    @objc func editingBarButtonAction(sender: UIBarButtonItem) {
        selectIndexPath = nil
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneBarButtonAction(_:)))
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = doneButton
            self.tableView.setEditing(true, animated: true)
        }
    }
    
    @objc func doneBarButtonAction(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.rightBarButtonItems = self.leftBarItems
            self.tableView.setEditing(false, animated: true)
        }
    }
    
    @objc func addBarButtonAction(_ sender: UIBarButtonItem) {
        let vc = Global.dash_storyboard.instantiateViewController(withIdentifier: "adddashboard_vc") as! AddDashboardTableViewController
        vc.dashboard_vc = self
        let navigation = UINavigationController(rootViewController: vc)
        self.present(navigation, animated: true, completion: nil)
        //        self.show(vc, sender: self)
        print("add")
    }
    
    @objc func editIconBarButtonAction(_ sender: UIBarButtonItem) {
        print("EditIcon \(selectIndexPath)")
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.rightBarButtonItems = self.leftBarItems
            self.tableView.setEditing(false, animated: true)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Global.memberData.dashboardData.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: ValueTableViewCell!
        var gauge_cell: GaugeTableViewCell!
        //        print((dashboardData["value"] as! [[String: Any]])[indexPath.row])
        var title = Global.memberData.dashboardData[indexPath.row]["name"] as? String ?? "沒有標題"
        
        var receiveSeriesData: [[String: Any]] {
            if let eventData: [String: Any] = receiveData["eventData"] as? [String: Any] {
                if let series = eventData["timeSeriesData"] as? [[String:Any]] {
                    return series
                }else {
                    return []
                }
            }else {
                return []
            }
        }
        let panelType = Global.memberData.dashboardData[indexPath.row]["panelType"] as! String
        let moduleId = Global.memberData.dashboardData[indexPath.row]["sensorModule"] as! String
        let sensorId = (Global.memberData.dashboardData[indexPath.row]["sensorId"] as! String).lowercased()
        let localSeriesId = moduleId + "-\(sensorId)"
        if panelType != "GAUGE" {
            cell = tableView.dequeueReusableCell(withIdentifier: "value_cell", for: indexPath) as! ValueTableViewCell
        }else {
            gauge_cell = tableView.dequeueReusableCell(withIdentifier: "gauge_cell", for: indexPath) as! GaugeTableViewCell
        }
        
//        cell.accessoryType = .none
        
        
//        cell.textLabel?.textColor = UIColor.black
//        if title.count <= 0 {
//            cell.textLabel?.textColor = UIColor.lightGray
//            title = "沒有標題"
//        }
//        cell.textLabel?.text = title
        
        
        switch panelType {
        case "VALUE":
            if receiveSeriesData.count > 0 {
                for i in receiveSeriesData {
                    if (i["seriesId"] as! String) == localSeriesId {
                        let value = i["value"]
                        let numFormatter = NumberFormatter()
                        if value != nil {
                            if value is String {
                                let num = numFormatter.number(from: i["value"] as! String)
                                cell.valueTextLabel.text = String(format: "%.2f", (num?.doubleValue)!)
                            }else if value is Int {
                                cell.valueTextLabel.text = numFormatter.string(for: (i["value"] as! Int))
                            }else if value is Double {
                                cell.valueTextLabel.text = String(format: "%.2f", i["value"] as! Double)
                            }else {
                                
                            }
                        }
                    }
                }
            }
            break
        case "GAUGE":
//            cell.detailTextLabel?.text = ""
            break
        case "GRAPH":
//            cell.detailTextLabel?.text = ""
            break
        case "DATA":
//            cell.detailTextLabel?.text = ""
//            cell.accessoryType = .disclosureIndicator
            break
        case "ALERT":
//            cell.detailTextLabel?.text = ""
            break
        default:
            break
        }
    
        // Configure the cell...
        return (panelType == "GAUGE") ? gauge_cell : cell
    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var actionArray: [UITableViewRowAction] = [UITableViewRowAction]()
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, index) in
            
            print("Delete \(indexPath)")
            Global.memberData.dashboardData.remove(at: index.row)
            let json = try? JSONSerialization.data(withJSONObject: Global.memberData.dashboardData, options: [])
            self.user.setValue(String(data: json!, encoding: .utf8), forKey: "dashboardJson")
            DispatchQueue.main.async {
                self.viewDidLoad()
                self.tableView.reloadData()
            }
        }
        
        let editAction = UITableViewRowAction(style: .destructive, title: "Edit") { (action, index) in
            
            print("Edit \(indexPath)")
        }
        editAction.backgroundColor = UIColor.blue
        
        actionArray.append(editAction)
        actionArray.append(deleteAction)
        return actionArray
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let panelType = Global.memberData.dashboardData[indexPath.row]["panelType"] as! String
        switch panelType {
        case "VALUE":
            break
        case "GAUGE":
            break
        case "GRAPH":
            break
        case "DATA":
            let dataLog = (timeSeriesData[indexPath.row]["data"] as! [String: Any])["data"] as! [[Any]]
            
            print(dataLog)
            let show_vc = Global.dash_storyboard.instantiateViewController(withIdentifier: "showDataLog_vc") as! ShowDataLogTableViewController
            show_vc.dataLog = dataLog
            if Global.memberData.dashboardData[indexPath.row]["name"] is String {
                show_vc.title = Global.memberData.dashboardData[indexPath.row]["name"] as! String
            }
            
            self.show(show_vc, sender: self)
            
            break
        default:
            print("NoData")
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.size.height / 3
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print(sourceIndexPath.row)
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

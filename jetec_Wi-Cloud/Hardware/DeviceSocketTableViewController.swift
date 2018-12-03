//
//  DeviceSocketTableViewController.swift
//  2018.08.08_test_api
//
//  Created by macos on 2018/8/9.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit
import Starscream

class DeviceSocketTableViewController: UITableViewController, WebSocketDelegate {
    
    
    var deviceSettingList = ["hardware_socket_device_setting_connectstate", "hardware_socket_device_setting_avaliable_sensors", "hardware_socket_device_setting_alerts", "hardware_socket_device_setting_interval", "hardware_socket_device_setting_duration"]
    var deviceData: [String: Any] = [:]
//    var socket: WebSocket!
    var sensorData: [String:String] = [:]
    
//    var receiveData: [String: Any] = [:]
    var isConnected: Bool = false
    var connectStatusImage: UIImageView!
    var connectImageIsAdd: Bool = false
    var loadingAction: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
//        isConnected = UIBarButtonItem(image: UIImage(named: "disconnected_icon"), style: .done, target: self, action: nil)
//        self.navigationItem.rightBarButtonItem = isConnected
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        loadingAction = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        loadingAction.color = UIColor.black
        loadingAction.frame.size = CGSize(width: 50, height: 50)
        loadingAction.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        loadingAction.center = self.tableView.center
        
        loadingAction.startAnimating()
        
        conncetWebSocket()
        
        self.tableView.separatorStyle = .singleLineEtched
                print(deviceData)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.addSubview(loadingAction)
        if !Global.socket.isConnected {
            Global.socket.connect()
        }else {
            Global.socket.delegate = self
        }
    }
    
    /*
    override func viewDidDisappear(_ animated: Bool) {
        if Global.socket.isConnected {
            Global.socket.disconnect()
        }
    }*/
    
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("did connect")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("did disconnect")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        sensorData = [:]
        print("***********************************")
        //        print(text)
        Global.receiveData = text.getJsonObject() as! [String: Any]
        let eventType = Global.receiveData["eventType"] as? String
        if eventType == "timeSeriesData" {
            if let data = (Global.receiveData["eventData"] as! [String:Any])["timeSeriesData"] {
                let originDeviceId = String(Global.receiveData["originDeviceId"] as! Int)
                let deviceId = (deviceData["value"] as! [String:Any])["gatewayId"] as! String
                if deviceId == originDeviceId {
                    //                    print(self.receiveData)
                    for i in (data as! [[String:Any]]) {
                        let sensorKey = (Global.regexGetSub(pattern: Basic.dataPattern, str: (i["seriesId"] as! String)))[1]
                        let sensorValue = String(format: "%.0f", i["value"] as! Double)
                        sensorData[sensorKey] = sensorValue
                    }
                    DispatchQueue.main.async {
                        if self.loadingAction.isAnimating {
                            self.loadingAction.stopAnimating()
                            self.loadingAction.alpha = 0
                        }
                        self.connectStatusImage.image = UIImage(named: "ok_icon")
                        self.tableView.reloadData()
                    }
                }
                
            }
        }else if eventType == "_deviceDisconnected_" {
            if let eventData = Global.receiveData["eventData"] {
                let deviceId = (deviceData["value"] as! [String:Any])["gatewayId"] as! String
                if let receiveDeviceId: Int = (eventData as! [String: Any])["deviceId"] as? Int {
                    if deviceId == String(receiveDeviceId) {
                        DispatchQueue.main.async {
//                            self.isConnected.image = UIImage(named: "disconnected_icon")
                            self.connectStatusImage.image = UIImage(named: "cancel_icon")
                        }
                    }
                }
            }
            
        }else if eventType == "_deviceConnected_" {
            if let eventData = Global.receiveData["eventData"] {
                let deviceId = (deviceData["value"] as! [String:Any])["gatewayId"] as! String
                if let receiveDeviceId: Int = (eventData as! [String: Any])["deviceId"] as? Int {
                    if deviceId == String(receiveDeviceId) {
                        DispatchQueue.main.async {
                            if self.loadingAction.isAnimating {
                                self.loadingAction.stopAnimating()
                                self.loadingAction.alpha = 0
                            }
//                            self.isConnected.image = UIImage(named: "connected_icon")
                            self.connectStatusImage.image = UIImage(named: "ok_icon")
                        }
                    }
                }
            }
            
        }
        //        print(sensorData)
        print("did ReceiveMessage")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("didReceiveData")
    }
    
    
    @objc func applicationDidBecomeActive() {
        if !Global.socket.isConnected {
            Global.socket.connect()
        }
    }
    
    
    
    func conncetWebSocket () {
        
        var request = URLRequest(url: URL(string: "wss://api.tinkermode.com/userSession/websocket")!)
        request.timeoutInterval = 5
        request.setValue(Global.memberData.authToken, forHTTPHeaderField: "Authorization")
        Global.socket = WebSocket(request: request)
        Global.socket.delegate = self
        Global.socket.connect()
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return (section == 1) ? ((deviceData["value"] as! [String:Any])["sensors"] as! [String]).count : deviceSettingList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let values = self.deviceData["value"] as! [String: Any]
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = deviceSettingList[indexPath.row].localized
            cell.detailTextLabel?.text = " "
            
            switch indexPath.row {
            case 0:
                connectStatusImage = UIImageView()
//                connectStatusImage.image = UIImage(named: (isConnected) ? "ok_icon" : "cancel_icon")
                connectStatusImage.image = UIImage(named: (Global.socket.isConnected) ? "ok_icon" : "cancel_icon")
                connectStatusImage.frame.size = CGSize(width: 30, height: 30)
                connectStatusImage.frame.origin = CGPoint(x: self.tableView.frame.size.width - connectStatusImage.frame.size.width - 7, y: 0)
                connectStatusImage.center.y = cell.center.y
                connectStatusImage.alpha = 1
                if !connectImageIsAdd {
                    cell.contentView.addSubview(connectStatusImage)
                    connectImageIsAdd = true
                }
                break
            case 1:
                let numbers = NumberFormatter()
                if let sensorsNum = (values["sensors"] as? [String])?.count {
                    cell.detailTextLabel?.text = numbers.string(from: NSNumber(value: sensorsNum))
                }
                break
            case 2:
                break
            case 3:
                let interval = values["interval"] as! Int
                    switch interval {
                    case let x where x < 60:
                        cell.detailTextLabel?.text = String(describing: interval) + "s"
                        break
                    case 60..<3600:
                        cell.detailTextLabel?.text = String(describing: interval / 60) + "m"
                        break
                    case 3600..<86400:
                        cell.detailTextLabel?.text = String(describing: interval / 3600) + "h"
                        break
                    case let x where x >= 86400:
                        cell.detailTextLabel?.text = String(describing: interval / 86400) + "d"
                        break
                    default:
                        break
                    }
                
                break
            case 4:
                cell.detailTextLabel?.text = "24h"
                break
            default:
                break
            }
            break
        case 1:
            
            var sensor = ((((deviceData["value"] as! [String:Any])["sensors"] as! [String])[indexPath.row]).split(separator: ":"))[0].replacingOccurrences(of: "_", with: " ")
            let sensorFirst = sensor.first
            sensor.remove(at: sensor.startIndex)
            let sensortitle = "\(String(sensorFirst!).uppercased())\(sensor.lowercased())"
            if sensorData.count <= 0 {
                cell.detailTextLabel?.text = ""
            }else {
                if sensortitle.lowercased().contains("wind"), sensortitle.lowercased().contains("speed") {
                    cell.detailTextLabel?.text = sensorData["wind_speed"]
                }
                if sensortitle.lowercased().contains("wind"), sensortitle.lowercased().contains("direction") {
                    cell.detailTextLabel?.text = sensorData["wind_direction"]
                }
                if sensortitle.lowercased().contains("temperature") {
                    cell.detailTextLabel?.text = sensorData["temperature"]
                }
                if sensortitle.lowercased().contains("humidity") {
                    cell.detailTextLabel?.text = sensorData["humidity"]
                }
                if sensortitle.lowercased().contains("precipitation") {
                    cell.detailTextLabel?.text = sensorData["precipitation"]
                }
            }
            
            cell.textLabel?.text = sensortitle
            break
        default:
            break
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let fv = view as? UITableViewHeaderFooterView
        fv?.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (section == 0) ? "hardware_socket_device_header_setting".localized : "hardware_socket_device_header_values".localized
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

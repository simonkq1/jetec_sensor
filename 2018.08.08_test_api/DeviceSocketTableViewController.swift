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
    
    var deviceData: [String: Any] = [:]
    var socket: WebSocket!
    
    var sensorData: [String:String] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        conncetWebSocket()
//        print(deviceData)
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        socket.disconnect()
    }
    
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("did connect")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("did disconnect")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        sensorData = [:]
        let revceiveData = text.getJsonData() as! [String: Any]
        let data = (revceiveData["eventData"] as! [String:Any])["timeSeriesData"] as! [[String:Any]]
        for i in data {
            let sensorKey = (Global.regexGetSub(pattern: Basic.dataPattern, str: (i["seriesId"] as! String)))[1]
            let sensorValue = String(format: "%.0f", i["value"] as! Double)
            sensorData[sensorKey] = sensorValue
//            print(sensorKey + " : \(sensorValue)")
            
        }
//        print(sensorData)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        print("did ReceiveMessage")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("didReceiveData")
    }
    
    
    
    func conncetWebSocket () {
        
        let deviceId = (deviceData["value"] as! [String:Any])["gatewayId"] as! String
        var request = URLRequest(url: URL(string: "wss://api.tinkermode.com/userSession/websocket?deviceId=\(deviceId)")!)
        request.timeoutInterval = 5
        request.setValue(Global.memberData.authToken, forHTTPHeaderField: "Authorization")
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
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
        return ((deviceData["value"] as! [String:Any])["sensors"] as! [String]).count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var sensor = ((((deviceData["value"] as! [String:Any])["sensors"] as! [String])[indexPath.row]).replacingOccurrences(of: ":0", with: "")).replacingOccurrences(of: "_", with: " ")
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
//        sensor = sensor.first + sensor.lowercased().removeFirst()
        cell.textLabel?.text = sensortitle
        

        return cell
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

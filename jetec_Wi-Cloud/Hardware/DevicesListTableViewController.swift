//
//  DevicesListTableViewController.swift
//  2018.08.08_test_api
//
//  Created by macos on 2018/8/9.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit

class DevicesListTableViewController: UITableViewController {

    var infoIsGet: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.title = "navigation_title_hardware".localized
        print(Global.memberData.devicesData.count)
        print(Global.memberData.devicesInfo.count)
        tableView.tableFooterView = UIView()
        
        
//            if Global.memberData.devicesInfo.count <= 0 {
//                self.getDevicesInfo()
////                while self.infoIsGet == false {
////                    usleep(150000)
////                }
//            }
//        
//        getOnlineDevice()
        
        
        
    }
    
    
    func getOnlineDevice() {
        
        Global.memberData.onlineDevices = []
        for i in 0..<Global.memberData.devicesData.count {
            var devices: [String: Any] = [:]
            let isConnect: Bool = ((Global.memberData.devicesData[i]["isConnected"] as! Int) == 1) ? true : false
            if isConnect {
                for j in 0..<Global.memberData.devicesInfo[i].count {
                    let deviceValue = Global.memberData.devicesInfo[i][j]["value"] as! [String:Any]
                    Global.memberData.onlineDevices.append(deviceValue)
                }
            }
        }
//        print(Global.memberData.onlineDevices)
        
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
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return Global.memberData.devicesInfo.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Global.memberData.devicesInfo[section].count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let deviceValue = Global.memberData.devicesInfo[indexPath.section][indexPath.row]["value"] as! [String:Any]
        let deviceName = deviceValue["name"] as! String
        
        
        cell.textLabel?.text = deviceName
        // Configure the cell...
        
        return cell
    }
    

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let deviceClass = Global.memberData.devicesData[section]["deviceClass"] as! String
        let devicesId = Global.memberData.devicesData[section]["id"] as! Int
        let isConnected = Global.memberData.devicesData[section]["isConnected"] as! Int
        var title: String {
            return (isConnected == 1) ? (deviceClass + " \(devicesId)") : (deviceClass + " \(devicesId) (Disconnected)")
        }
        return title
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "\(Global.memberData.devicesInfo[section].count) 個裝置"
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let deviceValue = Global.memberData.devicesInfo[indexPath.section][indexPath.row]["value"] as! [String:Any]
        let deviceName = deviceValue["name"] as! String
        let vc = storyboard?.instantiateViewController(withIdentifier: "showinfo_vc") as! DeviceSocketTableViewController
        vc.deviceData = Global.memberData.devicesInfo[indexPath.section][indexPath.row]
        vc.title = deviceName
        let isConnected = Global.memberData.devicesData[indexPath.section]["isConnected"] as! Int
//        if isConnected == 1 {
            DispatchQueue.main.async {
                self.show(vc, sender: self)
            }
//        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 0) ? 40 : 60
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
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
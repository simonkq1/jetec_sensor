//
//  DashboardTableViewController.swift
//  2018.08.08_test_api
//
//  Created by macos on 2018/8/13.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit

class DashboardTableViewController: UITableViewController {
    
    
    var dashboardData: [String: Any] = [:]
    var userDashboard: [[String:Any]] = []
    var dashboardIsGet: Bool = false
    let user = UserDefaults()
    var editingButton: UIBarButtonItem!
    var addButton: UIBarButtonItem!
    lazy var leftBarItems: [UIBarButtonItem] = {
        return [editingButton, addButton]
    }()
    lazy var dashboard_storyboard: UIStoryboard = {
        return UIStoryboard(name: "Dashboard", bundle: Bundle.main)
    }()
    var selectIndexPath: IndexPath!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        if let myDashboard = user.object(forKey: "myDashboard") {
            do {
                let data = (myDashboard as! String).data(using: .utf8)
                userDashboard = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [[String: Any]]
            }catch {
                
            }
        }
        Global.getFromURL(url: "https://api.tinkermode.com/homes/744/kv/dashboard", auth: Global.memberData.authToken) { (data, string, respond) in
            do {
                self.dashboardData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
                self.dashboardIsGet = true
                print(self.dashboardData)
                
            }catch {
                
            }
            //            print(string)
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSS'Z'"
        let date = Date()
        let datestr = formatter.string(from: date)
        
        while dashboardIsGet == false {
            usleep(1000000)
        }
        
        editingButton = UIBarButtonItem(image: UIImage(named: "edit_icon"), style: .plain, target: self, action: #selector(editingBarButtonAction(sender:)))
        addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addBarButtonAction(_:)))
        self.navigationItem.rightBarButtonItems = leftBarItems
//        tableView.allowsSelectionDuringEditing = true
//        tableView.allowsMultipleSelectionDuringEditing = true
        
        
    }
    
    @objc func editingBarButtonAction(sender: UIBarButtonItem) {
        print(sender.title)
        selectIndexPath = nil
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteBarButtonAction(_:)))
        let edit = UIBarButtonItem(image: UIImage(named: "edit_icon"), style: .plain, target: self, action: #selector(editIconBarButtonAction(_:)))
        let add = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addBarButtonAction(_:)))
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneBarButtonAction(_:)))
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = doneButton
            self.tableView.setEditing(true, animated: true)
        }
    }
    
    @objc func doneBarButtonAction(_ sender: UIBarButtonItem) {
        print(sender.title)
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.rightBarButtonItems = self.leftBarItems
            self.tableView.setEditing(false, animated: true)
        }
    }
    
    @objc func addBarButtonAction(_ sender: UIBarButtonItem) {
        let vc = dashboard_storyboard.instantiateViewController(withIdentifier: "adddashboard_vc") as! AddDashboardTableViewController
        self.show(vc, sender: self)
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
    
    @objc func deleteBarButtonAction(_ sender: UIBarButtonItem) {
        print("Delete \(selectIndexPath)")
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
        return (dashboardData["value"] as! [[String: Any]]).count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        print((dashboardData["value"] as! [[String: Any]])[indexPath.row])
        let title = (dashboardData["value"] as! [[String: Any]])[indexPath.row]["name"] as? String ?? "沒有標題"
        if title.contains("沒有標題") {
            cell.textLabel?.textColor = UIColor.lightGray
        }
        cell.textLabel?.text = title
        // Configure the cell...
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var actionArray: [UITableViewRowAction] = [UITableViewRowAction]()
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, index) in
            
            print("Delete \(indexPath)")
        }
        
        let editAction = UITableViewRowAction(style: .destructive, title: "Edit") { (action, index) in
            
            print("Edit \(indexPath)")
        }
        editAction.backgroundColor = UIColor.blue
        
        actionArray.append(editAction)
        actionArray.append(deleteAction)
        return actionArray
    }
//
//    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        selectIndexPath = indexPath
//        if let selectedRowIndexPath = tableView.indexPathForSelectedRow {
//            tableView.deselectRow(at: selectedRowIndexPath, animated: true)
//        }
//        return indexPath
//    }
    
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

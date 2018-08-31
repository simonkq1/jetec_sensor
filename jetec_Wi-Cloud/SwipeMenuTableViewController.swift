//
//  SwipeMenuTableViewController.swift
//  2018.08.08_test_api
//
//  Created by macos on 2018/8/10.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit
import SafariServices

class SwipeMenuTableViewController: UITableViewController {
    
    let list = ["menu_dashboard", "menu_hardware", "menu_notifications", "menu_logout", "menu_consultation"]
    
    
    
    var main_vc: MainViewController!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView.tableFooterView = UIView()
//        print(String(describing: parent))
//        main_vc = parent as! MainViewController
        tableView.register(UINib(nibName: "SwipeMenuTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "Cell")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func tapGestureAction(sender: UITapGestureRecognizer) {
        main_vc.swipeMenuConstraint.constant = -main_vc.swipeMenuWidthConstraint.constant
        main_vc.backgroundConstraint.constant = -400
        UIView.animate(withDuration: 0.5) {
            self.main_vc.view.layoutIfNeeded()
        }
        let safari = SFSafariViewController(url: URL(string: "http://www.jetec.com.tw/wicloud/support.html")!)
        self.main_vc.show(safari, sender: self.main_vc)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return list.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeMenuTableViewCell
        cell.nameLabel?.text = list[indexPath.row].localized
        cell.menuImageView.image = nil
        cell.nameLabel.textColor = UIColor.white
        cell.nameLabel.gestureRecognizers = []
        cell.nameLabel.isUserInteractionEnabled = false
        switch indexPath.row {
        case 0:
            cell.menuImageView.image = UIImage(named: "nav-icon-dashboard")
            break
        case 1:
            cell.menuImageView.image = UIImage(named: "nav-icon-hardware")
            break
        case 2:
            cell.menuImageView.image = UIImage(named: "nav-icon-notifications")
            break
        case 3:
            cell.menuImageView.image = UIImage(named: "nav-icon-logout")
            break
        case 4:
            cell.menuImageView.image = nil
            cell.nameLabel.isUserInteractionEnabled = true
            cell.nameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(sender:))))
            break
        default:
            break
        }
        // Configure the cell...

        return cell
    }
    
    func celldidSelectAnimate(_ cell: UITableViewCell) {
        cell.contentView.backgroundColor = UIColor.lightGray
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
            cell.contentView.backgroundColor = UIColor.darkGray
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        celldidSelectAnimate(tableView.cellForRow(at: indexPath)!)
        
        DispatchQueue.main.async {
            
            switch indexPath.row {
            case 0:
                self.main_vc.changePage(to: self.main_vc.dashboard_nc)
                break
            case 1:
                self.main_vc.changePage(to: self.main_vc.hardware_nc)
                break
            case 2:
                break
            case 3:
                
                let alert = UIAlertController(title: "logout_alert_title".localized, message: "logout_alert_context".localized, preferredStyle: UIAlertControllerStyle.alert)
                let ok = UIAlertAction(title: "logout_alert_ok".localized, style: UIAlertActionStyle.default, handler: { (action) in
                    let user = UserDefaults()
                    user.removeObject(forKey: "email")
                    user.removeObject(forKey: "password")
                    user.synchronize()
                    Global.memberData.authData.removeAll()
                    Global.memberData.devicesData.removeAll()
                    Global.memberData.devicesInfo.removeAll()
                    Global.memberData.homesData.removeAll()
                    Global.memberData.userData.removeAll()
                    Global.memberData.onlineDevices.removeAll()
                    let login_vc = Global.main_storyboard.instantiateViewController(withIdentifier: "login_vc") as! LoginViewController
                    self.showDetailViewController(login_vc, sender: nil)
                    print("OK")
                })
                let cancel = UIAlertAction(title: "logout_alert_cancel".localized, style: UIAlertActionStyle.cancel, handler: { (action) in
                    alert.dismiss(animated: false, completion: nil)
                    print("cancel")
                })
                alert.addAction(ok)
                alert.addAction(cancel)
                self.main_vc.present(alert, animated: false, completion: nil)
                
                break
            case 4:
                break
            default:
                break
            }
        }
        
        main_vc.swipeMenuConstraint.constant = -150
        main_vc.backgroundConstraint.constant = -400
        UIView.animate(withDuration: 0.5) {
            self.main_vc.view.layoutIfNeeded()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height / 5
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

//
//  SettingTableViewController.swift
//  2018.08.08_test_api
//
//  Created by Jetec-RD on 2018/8/27.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit

class SettingTableViewController: UITableViewController {
    let list: [String] = ["Language", "Logout"]
    var main_vc: MainViewController {
        return parent as! MainViewController
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        print(String(describing: main_vc))
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
        return list.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.detailTextLabel?.text = " "
        cell.detailTextLabel?.textColor = UIColor.lightGray
        cell.textLabel?.text = list[indexPath.row]
        
        switch indexPath.row {
        case 0:
            
            break
        case 1:
            break
        default:
            break
        }

        // Configure the cell...

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.selectionFlashingStyleAction(animateColor: UIColor.lightGray, endColor: UIColor.white, timeInterval: 0.08)
        
        switch indexPath.row {
        case 0:
            let language_vc = Global.main_storyboard.instantiateViewController(withIdentifier: "language_vc") as! SelectLanguageViewController
            self.present(language_vc, animated: false, completion: nil)
            break
        case 1:
            
             let alert = UIAlertController(title: "Logout", message: "Do you sure you want to logout?", preferredStyle: UIAlertControllerStyle.alert)
             let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
             let user = UserDefaults()
             user.removeObject(forKey: "email")
             user.removeObject(forKey: "password")
             user.synchronize()
             let login_vc = Global.main_storyboard.instantiateViewController(withIdentifier: "login_vc") as! LoginViewController
             self.showDetailViewController(login_vc, sender: nil)
             print("OK")
             })
             let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
             print("cancel")
             })
             alert.addAction(ok)
             alert.addAction(cancel)
             self.main_vc.present(alert, animated: false, completion: nil)
            break
        default:
            break
        }
        
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

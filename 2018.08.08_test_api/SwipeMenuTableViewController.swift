//
//  SwipeMenuTableViewController.swift
//  2018.08.08_test_api
//
//  Created by macos on 2018/8/10.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit

class SwipeMenuTableViewController: UITableViewController {
    
    let list = ["Dashboard", "Hardware", "Notifications", "Support", "MyAccount"]
    
    
    
    var main_vc: MainViewController!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        main_vc = (parent as! UINavigationController).parent as! MainViewController
//        main_vc = parent as! MainViewController
        
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
        cell.textLabel?.text = list[indexPath.row]
        
        // Configure the cell...

        return cell
    }
    
    func celldidSelectAnimate(_ cell: UITableViewCell) {
        cell.contentView.backgroundColor = UIColor.lightGray
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
            cell.contentView.backgroundColor = UIColor.white
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        celldidSelectAnimate(tableView.cellForRow(at: indexPath)!)
        
        let dash_board = UIStoryboard(name: "Dashboard", bundle: nil)
        DispatchQueue.main.async {
            
            switch self.list[indexPath.row] {
            case "Dashboard":
                self.main_vc.changePage(to: self.main_vc.dashboard_nc)
                break
            case "Hardware":
                self.main_vc.changePage(to: self.main_vc.firstViewController)
                break
            case "Notifications":
                break
            case "Support":
                break
            case "MyAccount":
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

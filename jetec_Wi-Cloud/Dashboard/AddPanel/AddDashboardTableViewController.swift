//
//  AddDashboardTableViewController.swift
//  2018.08.08_test_api
//
//  Created by macos on 2018/8/13.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit

class AddDashboardTableViewController: UITableViewController {
    
    let titleList = ["panel_title_value", "panel_title_gauge"]
    let contextList = ["panel_context_value",
                       "panel_context_gauge"]
    
    var selectedCell: Int!
    var nextBarButton: UIBarButtonItem!
    var dashboard_vc: DashboardTableViewController!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.title = "navigation_title_panel".localized
        tableView.register(UINib(nibName: "AddDashboardTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "Cell")
        nextBarButton = UIBarButtonItem(title: "bar_button_next".localized, style: UIBarButtonItem.Style.plain, target: self, action: #selector(nextBarButtonAction))
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "bar_button_cancel".localized, style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancelBarButtonAction))
        self.navigationItem.rightBarButtonItem = nextBarButton
        
        if selectedCell == nil{
            nextBarButton.isEnabled = false
        }
        
        
    }
    
    @objc func cancelBarButtonAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func nextBarButtonAction() {
        print(titleList[selectedCell])
        switch titleList[selectedCell] {
        case "panel_title_value":
            let value_vc = Global.dash_storyboard.instantiateViewController(withIdentifier: "value_panel_vc") as! ValueViewController
            value_vc.title = "panel_configure_title_value".localized
            value_vc.dashboard_vc = self.dashboard_vc
            self.show(value_vc, sender: self)
            break
        case "panel_title_gauge":
            let gauge_vc = Global.dash_storyboard.instantiateViewController(withIdentifier: "gauge_panel_vc") as! GaugeViewController
            gauge_vc.title = "panel_configure_title_gauge".localized
            gauge_vc.dashboard_vc = self.dashboard_vc
            self.show(gauge_vc, sender: self)
            break
            
        default:
            break
        }
        
        let backItem = UIBarButtonItem()
        backItem.title = "bar_back_button_panel".localized
        navigationItem.backBarButtonItem = backItem
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return titleList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AddDashboardTableViewCell
        cell.typeTextLabel.text = titleList[indexPath.section].localized
        cell.contextLabel.text = contextList[indexPath.section].localized
//        cell.innerView.backgroundColor = UIColor.white
        switch indexPath.section {
        case 0:
            cell.innerLabel.alpha = 1
            cell.innerLabel.text = "50.4"
            cell.innerImageView.image = nil
            break
        case 1:
            cell.innerLabel.alpha = 0
            cell.innerImageView.image = UIImage(named: "gauge")
            break
            
        default:
            break
        }
        // Configure the cell...

        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height / 2.3
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCell = indexPath.section
        if selectedCell != nil {
            nextBarButton.isEnabled = true
            DispatchQueue.main.async {
                self.title = self.titleList[indexPath.section].localized
            }
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

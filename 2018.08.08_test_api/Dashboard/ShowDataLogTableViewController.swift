//
//  ShowDataLogTableViewController.swift
//  2018.08.08_test_api
//
//  Created by Jetec-RD on 2018/8/17.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit

class ShowDataLogTableViewController: UITableViewController {
    
    var dataLog: [[Any]]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
//        print(dataLog)
        dataLog = dataLog.sorted(by: { (d1, d2) -> Bool in
            return (d1[0] as! String) > (d2[0] as! String)
        })
        
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
        return dataLog.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            let numFormatter = NumberFormatter()
            let numToStr = String(format: "%.2f", dataLog[indexPath.row][1] as! Double)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss'Z'"
            let strToDate = dateFormatter.date(from: dataLog[indexPath.row][0] as! String)
            let strFormatter = DateFormatter()
            strFormatter.dateFormat = "YYYY-MM-dd hh:mm:ss a"
            let dateString = strFormatter.string(from: strToDate! + (60 * 60 * 8))
            
            cell.textLabel?.text = dateString
            cell.detailTextLabel?.text = numToStr
        
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Date"
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let fv = view as! UITableViewHeaderFooterView
        let label = UILabel()
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        
//        fv.textLabel?.bounds.origin.x += 80
        label.frame.size = CGSize(width: 80, height: 28)
        label.frame.origin = CGPoint(x: fv.frame.size.width - label.frame.size.width, y: 0)
        label.font = fv.textLabel?.font
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.text = "Value"
        fv.addSubview(label)
        
        print(fv.textLabel?.text)
        print("SHOW HEIGHT")
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

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
    
    
    private lazy var dashboard_vc: DashboardViewController = {
        let dash_board = UIStoryboard(name: "Dashboard", bundle: Bundle.main)
        var vc = dash_board.instantiateViewController(withIdentifier: "dashboard_vc") as! DashboardViewController
        
        self.add(asChildViewController: vc)
        
        return vc
    }()
    
    var selectedViewController: UIViewController!
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
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        main_vc.addChildViewController(viewController)
        
        // Add Child View as Subview
        main_vc.view.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    
    func changePage(to newViewController: UIViewController) {
        // 2. Remove previous viewController
        selectedViewController.willMove(toParentViewController: nil)
        selectedViewController.view.removeFromSuperview()
        selectedViewController.removeFromParentViewController()
        
        // 3. Add new viewController
        addChildViewController(newViewController)
        main_vc.mainContainerView.addSubview(newViewController.view)
        newViewController.view.frame = main_vc.mainContainerView.bounds
        newViewController.didMove(toParentViewController: self)
        
        // 4.
        self.selectedViewController = newViewController
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
        switch list[indexPath.row] {
        case "Dashboard":
            
            
            break
        case "Hardware":
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

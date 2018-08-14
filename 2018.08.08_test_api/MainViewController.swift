//
//  MainViewController.swift
//  2018.08.08_test_api
//
//  Created by macos on 2018/8/10.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var backgroundConstraint: NSLayoutConstraint!
    @IBOutlet weak var swipeMenuConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mainContainerView: UIView!
    
    
    
    var selectedViewController: UIViewController!
    var firstViewController: FirstNavigationController!
    lazy var dashboard_nc: DashboardNavigationController = {
        let dash_board = UIStoryboard(name: "Dashboard", bundle: Bundle.main)
        var nc = dash_board.instantiateViewController(withIdentifier: "dashboard_nc") as! DashboardNavigationController
        
        self.add(asChildViewController: nc)
        
        return nc
    }()
    
    
    var menuIsShow: Bool = false
    var menu_vc: SwipeMenuTableViewController!
    @IBAction func ScreenEdgePanGesture(_ sender: UIScreenEdgePanGestureRecognizer) {
        var originX: CGFloat!
        var position = sender.location(in: sender.view)
        switch sender.state {
        case .began:
            print("begin")
            originX = position.x
//            print(originX)
            break
        case .changed:
            let posX = position.x
            if swipeMenuConstraint.constant < 0 {
                swipeMenuConstraint.constant = -150 + posX
            }
        case .ended:
            
            if swipeMenuConstraint.constant > 0 {
                swipeMenuConstraint.constant = 0
                menuIsShow = true
            }
            if swipeMenuConstraint.constant > -50 {
                swipeMenuConstraint.constant = 0
                menuIsShow = true
            }else {
                swipeMenuConstraint.constant = -150
                menuIsShow = false
            }
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
            
            if menuIsShow {
                backgroundConstraint.constant = 0
            }else {
                backgroundConstraint.constant = -400
            }
            
            break
        default:
            break
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        selectedViewController = firstViewController
        
        for i in childViewControllers {
            if i.restorationIdentifier == "menu_vc" {
                menu_vc = i as! SwipeMenuTableViewController
            }
        }
        
        
        
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "containerView_segue" {
            firstViewController = segue.destination as! FirstNavigationController
            
        }
    }
    
    
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        self.addChildViewController(viewController)
        
        // Add Child View as Subview
        self.view.addSubview(viewController.view)
        
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
        self.mainContainerView.addSubview(newViewController.view)
        newViewController.view.frame = self.mainContainerView.bounds
        newViewController.didMove(toParentViewController: self)
        
        // 4.
        self.selectedViewController = newViewController
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

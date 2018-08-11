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
        
        for i in childViewControllers {
            if i.restorationIdentifier == "menu_vc" {
                menu_vc = i as! SwipeMenuTableViewController
            }
        }
        
        
        
        
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

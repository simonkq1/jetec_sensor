//
//  BackgroundViewController.swift
//  2018.08.08_test_api
//
//  Created by macos on 2018/8/10.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit

class BackgroundViewController: UIViewController {

    var originX: CGFloat!
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        let main_vc = parent as! MainViewController
//        print(main_vc.swipeMenuConstraint.constant)
        let position = sender.location(in: sender.view)
        switch sender.state {
        case .began:
            originX = position.x
            break
        case .changed:
//            print(originX)
            if main_vc.menuIsShow {
                if main_vc.swipeMenuConstraint.constant <= 0 {
                    main_vc.swipeMenuConstraint.constant = 0 - (originX - position.x)
                }
            }
            break
        case .ended:
            if originX - position.x > 0 {
                main_vc.swipeMenuConstraint.constant = -150
                main_vc.menuIsShow = false
                main_vc.backgroundConstraint.constant = -400
            }else {
                main_vc.swipeMenuConstraint.constant = 0
            }
            UIView.animate(withDuration: 0.5) {
                main_vc.view.layoutIfNeeded()
            }
            break
        default:
            break
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

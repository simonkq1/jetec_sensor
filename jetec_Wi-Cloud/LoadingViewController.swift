//
//  LoadingViewController.swift
//  2018.08.08_test_api
//
//  Created by macos on 2018/8/9.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    
    
    
    @IBOutlet weak var loadingActive: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadingActive.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        loadingActive.startAnimating()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        loadingActive.stopAnimating()
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

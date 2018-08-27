//
//  SelectLanguageViewController.swift
//  2018.08.08_test_api
//
//  Created by Jetec-RD on 2018/8/27.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit
import LocaleManager

class SelectLanguageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let list = ["English", "繁體中文", "简体中文"]

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(Locale.current.languageCode!)
//        print(Locale.preferredLanguages[0])
//        print(LocaleManager.availableLocalizations)
        // Do any additional setup after loading the view.
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backViewTouchesBegin)))
        tableView.layer.borderWidth = 0.5
        tableView.layer.cornerRadius = 5
        tableView.tableFooterView = UIView()
    }
    
    
    @objc func backViewTouchesBegin() {
        self.dismiss(animated: false, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Tableview Setting
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.text = list[indexPath.row]
        
        
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: false, completion: nil)
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

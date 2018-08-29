//
//  DashboardTableViewController.swift
//  2018.08.08_test_api
//
//  Created by macos on 2018/8/13.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit
import Starscream

class DashboardTableViewController: UITableViewController, WebSocketDelegate {
    
    
    
    var dashboardData: [String: Any] = [:]
    var userDashboard: [[String:Any]] = []
    var dashboardIsGet: Bool = false
    let user = UserDefaults()
    var editingButton: UIBarButtonItem!
    var addButton: UIBarButtonItem!
    lazy var leftBarItems: [UIBarButtonItem] = {
        return [editingButton, addButton]
    }()
    var selectIndexPath: IndexPath!
    
    let textLabel = UILabel()
    var socket: WebSocket!
    var receiveData: [String: Any] = [:]
    var cellText: [NSMutableAttributedString] = []
    var pointerIsDraw: Bool = false
    
    
    //MARK: - System Function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        cellText = []
        
        self.title = "navigation_title_dashboard".localized
        if let myDashboard = user.object(forKey: "dashboardJson") {
            do {
                let data = (myDashboard as! String).data(using: .utf8)
                Global.memberData.dashboardData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [[String: Any]]
            }catch {
                
            }
        }
        
        for _ in 0..<Global.memberData.dashboardData.count {
            let s1 = NSMutableAttributedString(string: "--")
            cellText.append(s1)
        }
        
        drawNoDataMessage()
        print("********************")
        
        editingButton = UIBarButtonItem(image: UIImage(named: "edit_icon"), style: .plain, target: self, action: #selector(editingBarButtonAction(sender:)))
        addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addBarButtonAction(_:)))
        self.navigationItem.rightBarButtonItems = leftBarItems
        tableView.register(UINib(nibName: "GaugeTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "gauge_cell")
        
        tableView.register(UINib(nibName: "ValueTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "value_cell")
        socket = Global.connectToWebSocket(delegate: self)
        
        self.tableView.estimatedRowHeight = 0
        self.tableView.estimatedSectionFooterHeight = 0
        self.tableView.estimatedSectionHeaderHeight = 0
        
        sleep(1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
            self.tableView.reloadData()
        }
        if !socket.isConnected {
            socket.connect()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        if socket != nil {
            if socket.isConnected {
                socket.disconnect()
            }
        }
    }
    
    //MARK: - Socket Event Action
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("Connect Socket")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        
        print("Disconnect Socket")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("************************")
//        print(text)
        DispatchQueue.main.async {
            let json = text.getJsonObject() as! [String: Any]
            if let eventType = json["eventType"] {
                if eventType as! String == "timeSeriesData" {
                    self.receiveData = text.getJsonObject() as! [String: Any]
                    if !self.tableView.isEditing {
                        self.tableView.reloadData()
                    }
                }else {
                    if self.pointerIsDraw == false {
                        if !self.tableView.isEditing {
                        self.tableView.reloadData()
                        }
                    }
                }
            }
        }
        //        print(self.receiveData)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
    
    
    
    
    // MARK:- Function Area
    
    func drawNoDataMessage() {
        
        if Global.memberData.dashboardData.count <= 0 {
            textLabel.center = view.center
            textLabel.frame.origin = CGPoint(x: self.view.center.x, y: self.view.center.y)
            textLabel.frame.size = CGSize(width: self.view.bounds.size.width - 30, height: self.view.bounds.size.height - 30)
            textLabel.center.x = view.center.x
            textLabel.center.y = view.center.y - ((self.navigationController?.navigationBar.frame.size.height) ?? 44)
            textLabel.textAlignment = .center
            textLabel.font = UIFont.systemFont(ofSize: 50)
            textLabel.textColor = UIColor.lightGray
            textLabel.numberOfLines = 0
            textLabel.alpha = 1
            textLabel.text = "dashboard_nodata_message".localized
            DispatchQueue.main.async {
                self.view.addSubview(self.textLabel)
            }
            
        }else {
            
            textLabel.alpha = 0
        }
    }
    
    
    
    
    
    
    
    @objc func editingBarButtonAction(sender: UIBarButtonItem) {
        selectIndexPath = nil
        socket.disconnect()
        let doneButton = UIBarButtonItem(title: "bar_button_done".localized, style: .plain, target: self, action: #selector(doneBarButtonAction(_:)))
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.rightBarButtonItem = doneButton
            self.tableView.setEditing(true, animated: true)
        }
    }
    
    @objc func doneBarButtonAction(_ sender: UIBarButtonItem) {
        
        let json = Global.memberData.dashboardData.getJsonString()
        user.setValue(json, forKey: "dashboardJson")
        user.synchronize()
        
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.rightBarButtonItems = self.leftBarItems
            self.tableView.setEditing(false, animated: true)
            self.viewDidLoad()
            self.tableView.reloadData()
        }
        
    }
    
    @objc func addBarButtonAction(_ sender: UIBarButtonItem) {
        let vc = Global.dash_storyboard.instantiateViewController(withIdentifier: "adddashboard_vc") as! AddDashboardTableViewController
        vc.dashboard_vc = self
        let navigation = UINavigationController(rootViewController: vc)
        self.present(navigation, animated: true, completion: nil)
        //        self.show(vc, sender: self)
        print("add")
    }
    
    @objc func editIconBarButtonAction(_ sender: UIBarButtonItem) {
        print("EditIcon \(selectIndexPath)")
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.rightBarButtonItems = self.leftBarItems
            self.tableView.setEditing(false, animated: true)
        }
    }
    
    
    //MARK:- Draw gauge
    
    func drawBackCircle(gauge_cell: GaugeTableViewCell, min: String, max: String) {
        
        var radius: CGFloat {
            let width = gauge_cell.innerView.bounds.size.width
            let height = gauge_cell.innerView.bounds.size.height
            return (width > height) ? (height - (gauge_cell.circleWidth * 4)) : (width - (gauge_cell.circleWidth * 4))
        }
        
        if gauge_cell.circleIsDraw {
            gauge_cell.backgroundShapeLayer.removeFromSuperlayer()
        }
        
        gauge_cell.backgroundShapeLayer = CAShapeLayer()
        let linePath = UIBezierPath(
            arcCenter: CGPoint(x: gauge_cell.innerView.layer.bounds.size.width / 2, y: gauge_cell.innerView.bounds.size.height * 0.8),
            radius: radius,
            startAngle: 2 * CGFloat.pi * 0.5,
            endAngle: 2 * CGFloat.pi,
            clockwise: true)
        
        //        backgroundShapeLayer.frame = innerView.frame
        gauge_cell.backgroundShapeLayer.path = linePath.cgPath
        gauge_cell.backCircleColor = UIColor(red: 161/255, green: 217/255, blue: 229/255, alpha: 1).cgColor
        gauge_cell.backgroundShapeLayer.lineWidth = gauge_cell.circleWidth
        
//        if gauge_cell.nibIsLoad {
            gauge_cell.innerView.layer.addSublayer(gauge_cell.backgroundShapeLayer)
            drawMinText(gauge_cell, size: CGSize(width: gauge_cell.circleWidth * 2, height: gauge_cell.innerView.bounds.size.height * 0.2), position: CGPoint(x: ((gauge_cell.innerView.layer.bounds.size.width / 2) - radius - gauge_cell.circleWidth ), y: gauge_cell.innerView.bounds.size.height * 0.8), text: min)
            drawMaxText(gauge_cell, size: CGSize(width: gauge_cell.circleWidth * 2, height: gauge_cell.innerView.bounds.size.height * 0.2), position: CGPoint(x: ((gauge_cell.innerView.layer.bounds.size.width / 2) + radius - gauge_cell.circleWidth ), y: gauge_cell.innerView.bounds.size.height * 0.8), text: max)
            
            gauge_cell.circleIsDraw = true
//        }
        gauge_cell.nibIsLoad = true
    }
    
    func drawMinText(_ cell: GaugeTableViewCell, size: CGSize, position: CGPoint, text: String) {
        if let _ = cell.minLabel {
            cell.minLabel.removeFromSuperview()
        }
        cell.minLabel = UILabel()
        cell.minLabel.frame.size = size
        cell.minLabel.frame.origin = position
        cell.minLabel.textColor = .black
        cell.minLabel.textAlignment = .center
        
//        cell.minLabel.text = text
        cell.innerView.addSubview(cell.minLabel)
        
    }
    
    func drawMaxText(_ cell: GaugeTableViewCell, size: CGSize, position: CGPoint, text: String) {
        if let _ = cell.maxLabel {
            cell.maxLabel.removeFromSuperview()
        }
        cell.maxLabel = UILabel()
        cell.maxLabel.frame.size = size
        cell.maxLabel.frame.origin = position
        cell.maxLabel.textColor = .black
        cell.maxLabel.textAlignment = .center
//        cell.maxLabel.text = text
        cell.innerView.addSubview(cell.maxLabel)
        
    }
    
    
    func drawValueCircle(_ gauge_cell: GaugeTableViewCell, min: NSNumber, max: NSNumber, value: Double? = nil, index: Int) {
        if receiveData.count != 0 {
            gauge_cell.valueCircleShapeLayer = CAShapeLayer()
            var radius: CGFloat {
                let width = gauge_cell.innerView.bounds.size.width
                let height = gauge_cell.innerView.bounds.size.height
                return (width > height) ? (height - (gauge_cell.circleWidth * 4)) : (width - (gauge_cell.circleWidth * 4))
            }
            if pointerIsDraw {
                if let _ = gauge_cell.gaugePointerShaprLayer {
                    gauge_cell.gaugePointerShaprLayer.removeFromSuperlayer()
                }
                if let _ = gauge_cell.centerCircleShaprLayer {
                    gauge_cell.centerCircleShaprLayer.removeFromSuperlayer()
                }
            }
            if let _ = gauge_cell.valueCircleShapeLayer {
                gauge_cell.valueCircleShapeLayer.removeFromSuperlayer()
            }
            print("------------")
            print(max.doubleValue - min.doubleValue)
            
            var circlePosition: CGFloat {
                if let val = value {
                    var percent = ((val - min.doubleValue) / (max.doubleValue - min.doubleValue)) / 2
                    if percent >= 0.5 {
                        percent = 0.5
                    }
                    if percent <= 0 {
                        percent = 0
                    }
                    return CGFloat(percent)
                }else {
                    return 0
                }
            }
//            print(circlePosition)
            gauge_cell.valueCircleShapeLayer = CAShapeLayer()
            let linePath = UIBezierPath(
                arcCenter: CGPoint(x: gauge_cell.innerView.layer.bounds.size.width / 2, y: gauge_cell.innerView.bounds.size.height * 0.8),
                radius: radius,
                startAngle: 2 * CGFloat.pi * 0.5,
                endAngle: 2 * CGFloat.pi * (0.5 + circlePosition) ,
                clockwise: true)
            
            gauge_cell.valueCircleShapeLayer.path = linePath.cgPath
            gauge_cell.valueCircleColor = UIColor(red: 13/255, green: 76/255, blue: 142/255, alpha: 1).cgColor
            gauge_cell.valueCircleShapeLayer.lineWidth = gauge_cell.circleWidth
            
            
            gauge_cell.valueLabel.frame.size = CGSize(width: 120, height: 50)
            gauge_cell.valueLabel.frame.origin = CGPoint(x: (gauge_cell.innerView.layer.bounds.size.width / 2) - (gauge_cell.valueLabel.frame.size.width / 2), y: gauge_cell.innerView.bounds.size.height * 0.8)
            gauge_cell.valueLabel.center.x = gauge_cell.innerView.layer.bounds.size.width / 2
            gauge_cell.valueLabel.textAlignment = .center
            let valueText = UIFont.systemFont(ofSize: 25)
            let unitText = UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote)
            let s1 = NSMutableAttributedString(string: String(format: "%.2f", (value != nil) ? value! : "--"), attributes: [NSAttributedStringKey.font : valueText])
            let s2 = NSMutableAttributedString(string: (value != nil) ? gauge_cell.unit : " ", attributes: [NSAttributedStringKey.font : unitText])
            gauge_cell.valueLabel.textColor = UIColor.black
            s1.append(s2)
            
            cellText[index] = s1
//            gauge_cell.valueLabel.attributedText = s1
            gauge_cell.innerView.layer.addSublayer(gauge_cell.valueCircleShapeLayer)
            drawGaugePointer(gauge_cell, angel: circlePosition)
            gauge_cell.valueCircleIsDraw = true
            
            gauge_cell.valueNibIsLoad = true
        }
    }
    
    
    func drawGaugePointer(_ gauge_cell: GaugeTableViewCell, angel: CGFloat){
        gauge_cell.gaugePointerShaprLayer = CAShapeLayer()
        
        let linePath = UIBezierPath()
        var lineLength: CGFloat {
            let width = gauge_cell.innerView.bounds.size.width
            let height = gauge_cell.innerView.bounds.size.height
            return (width > height) ? ((height - (gauge_cell.circleWidth * 4)) * 0.7) : ((width - (gauge_cell.circleWidth * 4)) * 0.7)
        }
        
        let originPosition = CGPoint(x: gauge_cell.innerView.layer.bounds.size.width / 2, y: gauge_cell.innerView.bounds.size.height * 0.8)
        let lineTarget = CGPoint(x: originPosition.x + (lineLength * cos((1 + (angel * 2)) * CGFloat.pi)), y: originPosition.y + (lineLength * sin((1 + (angel * 2)) * CGFloat.pi)))
        
        linePath.addArc(withCenter: originPosition, radius: gauge_cell.centerCircleRadius, startAngle: 2 * CGFloat.pi * (0.5 + angel + 0.25), endAngle: 2 * CGFloat.pi * (1 + angel + 0.25), clockwise: true)
        linePath.addLine(to: lineTarget)
        linePath.close()
        
        gauge_cell.gaugePointerShaprLayer.lineWidth = 1
        gauge_cell.pointerCircleColor = UIColor(red: 13/255, green: 76/255, blue: 142/255, alpha: 1).cgColor
        gauge_cell.gaugePointerShaprLayer.path = linePath.cgPath
        gauge_cell.innerView.layer.addSublayer(gauge_cell.gaugePointerShaprLayer)
        drawCenterCircle(gauge_cell)
        pointerIsDraw = true
    }
    
    
    
    func drawCenterCircle(_ gauge_cell: GaugeTableViewCell) {
        gauge_cell.centerCircleShaprLayer = CAShapeLayer()
        let linePath = UIBezierPath(
            arcCenter: CGPoint(x: gauge_cell.innerView.layer.bounds.size.width / 2, y: gauge_cell.innerView.bounds.size.height * 0.8),
            radius: gauge_cell.centerCircleRadius / 2,
            startAngle: 0,
            endAngle: 2 * CGFloat.pi,
            clockwise: true)
        gauge_cell.centerCircleShaprLayer.fillColor = UIColor.white.cgColor
        gauge_cell.centerCircleShaprLayer.strokeColor = gauge_cell.pointerCircleColor
        gauge_cell.centerCircleShaprLayer.lineWidth = 1
        gauge_cell.centerCircleShaprLayer.path = linePath.cgPath
        gauge_cell.innerView.layer.addSublayer(gauge_cell.centerCircleShaprLayer)
    }
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return Global.memberData.dashboardData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: ValueTableViewCell!
        var gauge_cell: GaugeTableViewCell!
        //        print((dashboardData["value"] as! [[String: Any]])[indexPath.section])
        var title = Global.memberData.dashboardData[indexPath.section]["name"] as? String ?? "沒有標題"
        
        
        var receiveSeriesData: [[String: Any]] {
            if let eventData: [String: Any] = receiveData["eventData"] as? [String: Any] {
                if let series = eventData["timeSeriesData"] as? [[String:Any]] {
                    return series
                }else {
                    return []
                }
            }else {
                return []
            }
        }
        let panelType = Global.memberData.dashboardData[indexPath.section]["panelType"] as! String
        let moduleId = Global.memberData.dashboardData[indexPath.section]["sensorModule"] as! String
        let sensorId = (Global.memberData.dashboardData[indexPath.section]["sensorId"] as! String).lowercased()
        let localSeriesId = moduleId + "-\(sensorId)"
        if panelType != "GAUGE" {
            cell = tableView.dequeueReusableCell(withIdentifier: "value_cell", for: indexPath) as! ValueTableViewCell
            
            if sensorId.contains("humidity") {
                cell.unit = " %"
            }else if sensorId.contains("wind_direction") {
                cell.unit = " °"
                
            }else if sensorId.contains("temperature") {
                cell.unit = " ℃"
                
            }else if sensorId.contains("precipitation") {
                cell.unit = " mm"
                
            }else if sensorId.contains("wind_speed") {
                cell.unit = " m/s"
                
            }else {
                cell.unit = " "
            }
        }else {
            gauge_cell = tableView.dequeueReusableCell(withIdentifier: "gauge_cell", for: indexPath) as! GaugeTableViewCell
            
            if sensorId.contains("humidity") {
                gauge_cell.unit = " %"
            }else if sensorId.contains("wind_direction") {
                gauge_cell.unit = " °"
                
            }else if sensorId.contains("temperature") {
                gauge_cell.unit = " ℃"
                
            }else if sensorId.contains("precipitation") {
                gauge_cell.unit = " mm"
                
            }else if sensorId.contains("wind_speed") {
                gauge_cell.unit = " m/s"
                
            }else {
                gauge_cell.unit = " "
            }
        }
        
        
        
        
        
        
        switch panelType {
        case "VALUE":
            cell.sensorId = sensorId
            cell.setIcon()
            cell.nameTextLabel.text = title
            if title.count <= 0 {
                cell.nameTextLabel.textColor = UIColor.lightGray
            }else {
                cell.nameTextLabel.textColor = UIColor.black
            }
            if receiveSeriesData.count > 0 {
                for i in receiveSeriesData {
                    if (i["seriesId"] as! String) == localSeriesId {
                        let value = i["value"]
                        let numFormatter = NumberFormatter()
                        if value != nil {
                            let valueText = UIFont.systemFont(ofSize: 50)
                            let unitText = UIFont.systemFont(ofSize: 25)
                            if value is String {
                                let num = numFormatter.number(from: i["value"] as! String)
                                let s1 = NSMutableAttributedString(string: String(format: "%.2f", (num?.doubleValue)!), attributes: [NSAttributedStringKey.font : valueText])
                                let s2 = NSMutableAttributedString(string: cell.unit, attributes: [NSAttributedStringKey.font : unitText])
                                s1.append(s2)
                                cell.valueTextLabel.attributedText = s1
                            }else if value is Int {
                                let num = numFormatter.string(for: (i["value"] as! Int))
                                let s1 = NSMutableAttributedString(string: num!, attributes: [NSAttributedStringKey.font : valueText])
                                let s2 = NSMutableAttributedString(string: cell.unit, attributes: [NSAttributedStringKey.font : unitText])
                                s1.append(s2)
                                cell.valueTextLabel.attributedText = s1
                            }else if value is Double {
                                
                                let s1 = NSMutableAttributedString(string: String(format: "%.2f", i["value"] as! Double), attributes: [NSAttributedStringKey.font : valueText])
                                let s2 = NSMutableAttributedString(string: cell.unit, attributes: [NSAttributedStringKey.font : unitText])
                                s1.append(s2)
                                cell.valueTextLabel.attributedText = s1
                            }else {
                                
                            }
                            cell.valueTextLabel.textColor = UIColor.black
                        }
                    }
                }
            }else {
                cell.valueTextLabel.text = "connecting"
                cell.valueTextLabel.textColor = UIColor.lightGray
            }
            break
        case "GAUGE":
            let min = Global.memberData.dashboardData[indexPath.section]["min"] as! NSNumber
            let max = Global.memberData.dashboardData[indexPath.section]["max"] as! NSNumber
//            if let inner_view = gauge_cell.innerView {
//                inner_view.frame = gauge_cell.innerView.frame
//                gauge_cell.innerView.removeFromSuperview()
//                gauge_cell.addSubview(inner_view)
//            }
            if let _ = gauge_cell.valueCircleShapeLayer {
                gauge_cell.removeFromSuperview()
            }
            
            gauge_cell.sensorId = sensorId
            gauge_cell.setIcon()
            gauge_cell.nameTextLabel.text = title
            if title.count <= 0 {
                gauge_cell.nameTextLabel.textColor = UIColor.lightGray
            }else {
                gauge_cell.nameTextLabel.textColor = UIColor.black
            }
            if receiveSeriesData.count > 0, let _ = gauge_cell.backgroundShapeLayer {
                var val: NSNumber = 0
                for i in receiveSeriesData {
                    if (i["seriesId"] as! String) == localSeriesId {
                        if let value = i["value"] {
                            let numFormatter = NumberFormatter()
                            let valueText = UIFont.systemFont(ofSize: 25)
                            let unitText = UIFont.preferredFont(forTextStyle: UIFontTextStyle.footnote)
                            if value is String {
                                let num = numFormatter.number(from: i["value"] as! String)
                                val = num!
                            }else if value is Int {
                                val = NSNumber(value: (i["value"] as! Int))
                            }else if value is Double {
                                val = NSNumber(value: (i["value"] as! Double))
                            }else {
                                val = 0
                            }
                            
                            drawBackCircle(gauge_cell: gauge_cell, min: min.stringValue, max: max.stringValue)
                            if let _ = gauge_cell.backgroundShapeLayer {
                                drawValueCircle(gauge_cell, min: min, max: max, value: val.doubleValue, index: indexPath.section)
                            }
                            gauge_cell.valueLabel.textColor = UIColor.black
                            
                        }
                    }
                }
            }else if receiveSeriesData.count <= 0, gauge_cell.nibIsLoad, !gauge_cell.circleIsDraw {
                drawBackCircle(gauge_cell: gauge_cell, min: min.stringValue, max: max.stringValue)
                drawGaugePointer(gauge_cell, angel: 0)
                gauge_cell.valueLabel.frame.size = CGSize(width: 120, height: 50)
                gauge_cell.valueLabel.frame.origin = CGPoint(x: (gauge_cell.innerView.layer.bounds.size.width / 2) - (gauge_cell.valueLabel.frame.size.width / 2), y: gauge_cell.innerView.bounds.size.height * 0.8)
                gauge_cell.valueLabel.center.x = gauge_cell.innerView.layer.bounds.size.width / 2
                gauge_cell.valueLabel.textAlignment = .center
                gauge_cell.valueLabel.text = "--"
            }else if receiveSeriesData.count > 0, gauge_cell.nibIsLoad{
                var val: NSNumber = 0
                for i in receiveSeriesData {
                    if (i["seriesId"] as! String) == localSeriesId {
                        if let value = i["value"] {
                            let numFormatter = NumberFormatter()
                            if value is String {
                                let num = numFormatter.number(from: i["value"] as! String)
                                val = num!
                            }else if value is Int {
                                val = NSNumber(value: (i["value"] as! Int))
                            }else if value is Double {
                                val = NSNumber(value: (i["value"] as! Double))
                            }else {
                                val = 0
                            }
                            
                            drawBackCircle(gauge_cell: gauge_cell, min: min.stringValue, max: max.stringValue)
                            drawValueCircle(gauge_cell, min: min, max: max, value: val.doubleValue, index: indexPath.section)
                            gauge_cell.valueLabel.textColor = UIColor.black
                            
                        }
                    }
                }
            }
            gauge_cell.valueLabel.attributedText = cellText[indexPath.section]
            gauge_cell.nibIsLoad = true
            if let _ = gauge_cell.minLabel {
                gauge_cell.minLabel.text = min.stringValue
            }
            if let _ = gauge_cell.maxLabel {
                gauge_cell.maxLabel.text = max.stringValue
            }
            
            break
        default:
            break
        }
        
        // Configure the cell...
        
//        cellIsAwake = true
        return (panelType == "GAUGE") ? gauge_cell : cell
    }
    
    
    // MARK: Cell Swipe Action
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var actionArray: [UITableViewRowAction] = [UITableViewRowAction]()
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, index) in
            
            print("Delete \(indexPath)")
            Global.memberData.dashboardData.remove(at: index.row)
            let json = try? JSONSerialization.data(withJSONObject: Global.memberData.dashboardData, options: [])
            self.user.setValue(String(data: json!, encoding: .utf8), forKey: "dashboardJson")
            DispatchQueue.main.async {
                self.viewDidLoad()
                self.tableView.reloadData()
            }
        }
        
        let editAction = UITableViewRowAction(style: .destructive, title: "Edit") { (action, index) in
            
            print("Edit \(indexPath)")
            let panelType = Global.memberData.dashboardData[indexPath.section]["panelType"] as? String
            let value_vc = Global.dash_storyboard.instantiateViewController(withIdentifier: "edit_value_panel_vc") as! EditValuePanelViewController
            let gauge_vc = Global.dash_storyboard.instantiateViewController(withIdentifier: "edit_gauge_panel_vc") as! EditGaugePanelViewController
            
            if let type = panelType {
                if type == "VALUE" {
                    value_vc.panelData = Global.memberData.dashboardData[indexPath.section]
                    value_vc.dashboardIndex = indexPath.section
                    value_vc.dashboard_vc = self
                    let nc = UINavigationController(rootViewController: value_vc)
                    self.present(nc, animated: true, completion: nil)
                }else if type == "GAUGE" {
                    gauge_vc.panelData = Global.memberData.dashboardData[indexPath.section]
                    gauge_vc.dashboardIndex = indexPath.section
                    gauge_vc.dashboard_vc = self
                    let nc = UINavigationController(rootViewController: gauge_vc)
                    self.present(nc, animated: true, completion: nil)
                }
                
            }
            
        }
        editAction.backgroundColor = UIColor.blue
        
        actionArray.append(editAction)
        actionArray.append(deleteAction)
        return actionArray
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = Global.dash_storyboard.instantiateViewController(withIdentifier: "showdetail_vc") as! ShowDetailDataViewController
        vc.panelData = Global.memberData.dashboardData[indexPath.section]
        self.show(vc, sender: nil)
        
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (self.tableView.frame.size.height / 3.25)
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    //MARK: TableViewCell DidMoved Action
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print(sourceIndexPath.section)
        print(destinationIndexPath.section)
        let tmpData = Global.memberData.dashboardData[sourceIndexPath.section]
        Global.memberData.dashboardData[sourceIndexPath.section] = Global.memberData.dashboardData[destinationIndexPath.section]
        Global.memberData.dashboardData[destinationIndexPath.section] = tmpData
        
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

//
//  ShowDetailDataViewController.swift
//  2018.08.08_test_api
//
//  Created by Jetec-RD on 2018/8/21.
//  Copyright © 2018年 macos. All rights reserved.
//

import UIKit
import Charts

class ShowDetailDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,ChartViewDelegate {
    
    var panelData: [String: Any] = [:]
    var dataLog: [String: Any] = [:]
    var dataLogForTableView: [[Any]] = []
    var chartData: [Double] = []
    var chartTitles: [String] = []
    var direction_x: [String: Any] = [:]
    var direction_y: [String: Any] = [:]
    var directionData: [[Any]] = []

    @IBOutlet weak var lineChartView: LineChartView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(panelData)
        
        self.title = panelData["name"] as? String ?? ""
        getDataLog()
        drawChart()
        lineChartView.delegate = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func getDataLog() {
        dataLog = [:]
        var check: Bool = true
        let homeId = Global.memberData.homesData[0]["id"] as! Int
        let sensorId = panelData["sensorId"] as! String
        let moduleId = panelData["sensorModule"] as! String
        let seriesId = moduleId + "-\(sensorId.lowercased())"
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let now = formatter.string(from: (Date()))
        let target = formatter.string(from: (Date() - (60 * 60 * 24)))
        let aggregation: String = ((panelData["sensorId"] as! String).lowercased().contains("precipitation")) ? "sum" : "avg"
        
        if ((panelData["sensorId"] as! String).lowercased().contains("wind_direction")) {
            let sensorId_x = (sensorId.split(separator: ":"))[0] + "_X:" + (sensorId.split(separator: ":"))[1]
            let sensorId_y = (sensorId.split(separator: ":"))[0] + "_Y:" + (sensorId.split(separator: ":"))[1]
            let seriesId_x = moduleId + "-\(sensorId_x.lowercased())"
            let seriesId_y = moduleId + "-\(sensorId_y.lowercased())"
            
            let url_x = Basic.api + "/homes/\(homeId)/smartModules/tsdb/timeSeries/\(seriesId_x)/data?begin=\(target)&end=\(now)&aggregation=\(aggregation)"
            let url_y = Basic.api + "/homes/\(homeId)/smartModules/tsdb/timeSeries/\(seriesId_y)/data?begin=\(target)&end=\(now)&aggregation=\(aggregation)"
            Global.getFromURL(url: url_x, auth: Global.memberData.authToken) { (data, string, response) in
                self.direction_x = data?.getJsonData() as! [String: Any]
                check = false
            }
            
            while check {
                usleep(150000)
            }
            
            check = true
            Global.getFromURL(url: url_y, auth: Global.memberData.authToken) { (data, string, response) in
                self.direction_y = data?.getJsonData() as! [String: Any]
                check = false
            }
            
            while check {
                usleep(150000)
            }
            
            let value_x = direction_x["data"] as! [[Any]]
            let value_y = direction_y["data"] as! [[Any]]
            
            for i in 0..<value_x.count {
                let x = value_x[i][1] as! Double
                let y = value_y[i][1] as! Double
                let ang = Global.getDirectionAngel(x: x, y: y)
                directionData.append([value_x[i][0], ang])
                
            }
            print("---------------")
            print(directionData)
            
            self.dataLogForTableView = (self.directionData).sorted(by: { (d1, d2) -> Bool in
                return (d1[0] as! String) > (d2[0] as! String)
            })
            
            
        }else {
            let url = Basic.api + "/homes/\(homeId)/smartModules/tsdb/timeSeries/\(seriesId)/data?begin=\(target)&end=\(now)&aggregation=\(aggregation)"
            
            Global.getFromURL(url: url, auth: Global.memberData.authToken) { (data, html, response) in
                self.dataLog = data?.getJsonData() as! [String: Any]
                self.dataLogForTableView = (self.dataLog["data"] as! [[Any]]).sorted(by: { (d1, d2) -> Bool in
                    return (d1[0] as! String) > (d2[0] as! String)
                })
                check = false
            }
            
            while check {
                usleep(150000)
            }
        }
//        print(dataLog)
        
        
    }
    
    
    func drawChart() {
        
        let values = ((panelData["sensorId"] as! String).lowercased().contains("wind_direction")) ? directionData : dataLog["data"] as! [[Any]]
        
        
        chartData = {
            var arr: [Double] = []
            for i in values {
                let value: Double = i[1] as! Double
                arr.append(value.roundTo(places: 2))
            }
            return arr
        }()
        chartTitles = {
            var arr: [String] = []
            for i in values {
                let formatter = DateFormatter()
                formatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss'Z'"
                let date1: Date = formatter.date(from: i[0] as! String)!
                let formatter2 = DateFormatter()
                formatter2.dateFormat = "HH:mm"
                let date2: String = formatter2.string(from: date1 + (60 * 60 * 8))
                arr.append(date2)
            }
            return arr
        }()
        setChart(chartTitles, values: chartData)
    }
    
    
    
    func setChart(_ dataPoints: [String], values: [Double]) {
        
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0 ..< dataPoints.count {
            dataEntries.append(ChartDataEntry(x: Double(i), y: values[i]))
        }
        
        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: panelData["sensorType"] as? String)
        
        lineChartDataSet.axisDependency = .left
        lineChartDataSet.setColor(UIColor.blue)
        lineChartDataSet.setCircleColor(UIColor.black) // our circle will be dark red
        lineChartDataSet.lineWidth = 1.0
        lineChartDataSet.circleRadius = 3.0 // the radius of the node circle
        lineChartDataSet.fillAlpha = 1
//        lineChartDataSet.drawFilledEnabled = true
        //折線顏色
        lineChartDataSet.fillColor = UIColor.blue
        //平均線顏色
        lineChartDataSet.highlightColor = UIColor.orange
//        lineChartDataSet.mode = LineChartDataSet.Mode.cubicBezier
        
        
        lineChartDataSet.drawCircleHoleEnabled = false
        lineChartDataSet.drawCirclesEnabled = false
        var dataSets = [LineChartDataSet]()
        dataSets.append(lineChartDataSet)
        
        
        let lineChartData = LineChartData(dataSets: dataSets)
        lineChartView.data = lineChartData
        lineChartView.maxVisibleCount = 0
        lineChartView.scaleYEnabled = false
        lineChartView.chartDescription?.enabled = false
        lineChartView.drawMarkers = true
        lineChartView.rightAxis.enabled = false
//        lineChartView.clipDataToContentEnabled = true
//        lineChartView.clipValuesToContentEnabled = true
        lineChartView.xAxis.drawGridLinesEnabled = true
        
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        
    }
    
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
//        print(highlight)
        let marker = MarkerView()
        marker.frame.size = CGSize(width: 80, height: 30)
        marker.backgroundColor = UIColor.white
        marker.layer.borderWidth = 0
        marker.layer.cornerRadius = 5
        marker.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.7)
        marker.layer.shadowColor = UIColor.lightGray.cgColor
        marker.layer.shadowPath = UIBezierPath(rect: marker.bounds).cgPath
        marker.layer.shadowRadius = 6
        marker.layer.shadowOpacity = 0.5
        marker.layer.shadowOffset = CGSize(width: (highlight.x <= (Double(chartTitles.count) / 2)) ? 10 : -10, height: 13)
        marker.refreshContent(entry: entry, highlight: highlight)
        let borderLayer = CAShapeLayer()
        borderLayer.fillColor = marker.backgroundColor?.cgColor
        borderLayer.strokeColor = UIColor.black.cgColor
        borderLayer.lineWidth = 0.5
        
        if highlight.x <= (Double(chartTitles.count) / 2), highlight.y <= chartData.average {
            marker.drawChatBallonBorder(shapeLayer: borderLayer, highlight: highlight, offset: CGPoint(x: 7, y: 7), cornerRadius: 5, side: .bottomLeft)
        }else if highlight.x >= (Double(chartTitles.count) / 2), highlight.y >= chartData.average {
            marker.drawChatBallonBorder(shapeLayer: borderLayer, highlight: highlight, offset: CGPoint(x: 7, y: 7), cornerRadius: 5, side: .topRight)
        }else if highlight.x <= (Double(chartTitles.count) / 2), highlight.y >= chartData.average {
            marker.drawChatBallonBorder(shapeLayer: borderLayer, highlight: highlight, offset: CGPoint(x: 7, y: 7), cornerRadius: 5, side: .topLeft)
        }else if highlight.x >= (Double(chartTitles.count) / 2), highlight.y <= chartData.average {
            marker.drawChatBallonBorder(shapeLayer: borderLayer, highlight: highlight, offset: CGPoint(x: 7, y: 7), cornerRadius: 5, side: .bottomRight)
        }else {
            
            marker.drawChatBallonBorder(shapeLayer: borderLayer, highlight: highlight, offset: CGPoint(x: 7, y: 7), cornerRadius: 5, side: .bottomLeft)
        }
        
        
        
        
        let valueLabel = UILabel()
        
        
        valueLabel.frame = CGRect(x: 0, y: 0, width: marker.frame.size.width, height: marker.frame.size.height )
//        print(date2)
        valueLabel.textAlignment = .center
        
//        dateLabel.text = date2
        valueLabel.text = String(format: "%.2f", entry.y)
        
//        marker.addSubview(dateLabel)
        marker.addSubview(valueLabel)
        
        lineChartView.marker = marker
        
    }
    
    
    
    
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataLogForTableView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        
        cell.detailTextLabel?.text = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss'Z'"
        let strToDate = dateFormatter.date(from: dataLogForTableView[indexPath.row][0] as! String)
        let strFormatter = DateFormatter()
        strFormatter.dateFormat = "YYYY-MM-dd hh:mm:ss a"
        let dateString = strFormatter.string(from: strToDate! + (60 * 60 * 8))
        
        
        cell.textLabel?.text = dateString
        
        let numToStr = String(format: "%.2f", dataLogForTableView[indexPath.row][1] as! Double)
        cell.detailTextLabel?.text = numToStr
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Date"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
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

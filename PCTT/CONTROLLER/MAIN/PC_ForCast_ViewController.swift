//
//  PC_ForCast_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/9/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit
import MarqueeLabel
import SkeletonView

class PC_ForCast_ViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 120.0
        }
    }
    
    var dataList: NSMutableArray!
    
    var tempPosition: CGRect!

    var dataMonitor: NSMutableDictionary!
    
    var dataMonitorExtra: NSMutableArray!
    
    @IBOutlet var bg: UIImageView!
    
    @IBOutlet var blurView: UIView!
    
    @IBOutlet var backBtn: UIButton!

    @IBOutlet var topCell: UITableViewCell!

    var stationCode: NSString! = nil
    
    var station: NSString! = nil
    
    var isDown: Bool = false
    
    @IBOutlet var titleLabel: MarqueeLabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.withCell("PC_ForeCast_Cell")
        
        tableView.withCell("PC_ForeCast_7_Cell")
        
        titleLabel.text = station as String?
        
        dataList = NSMutableArray.init()

        dataMonitor = NSMutableDictionary.init()
        
        self.didRequestBG()
        
        self.didRequestMonitorData()
        
        self.didRequestStationForeCast()
        
        backBtn.setImage(UIImage(named: self.isModal ? "xxxx" : "icon_back"), for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.layoutIfNeeded()
    }
    
    func didRequestBG() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getBackgroundByStation",
                                                    "station_code":stationCode ?? "",
                                                    "overrideAlert":"1",
                                                    ], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            if result.getValueFromKey("ERR_CODE") != "0" {
                self.showToast(response?.dictionize().getValueFromKey("ERR_MSG"), andPos: 0)
                return
            }
            
            let imageUrl = (response?.dictionize()["RESULT"] as! NSDictionary).getValueFromKey("image")
            
            self.bg.imageUrlNoCacheNoSave(url: imageUrl ?? "")
            
            self.tableView.reloadData()
        })
    }
    
    func didRequestMonitorData() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getStationMonitoringData",
                                                    "station_code": stationCode ?? "",
                                                    "overrideAlert":"1",
                                                    ], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            if result.getValueFromKey("ERR_CODE") != "0" {
                self.showToast(response?.dictionize().getValueFromKey("ERR_MSG"), andPos: 0)
                return
            }
            
            let monitor = (response?.dictionize()["RESULT"] as! NSDictionary)
            
//                {
//                    "color_monitoring" = "#AFB1B4";
//                    humidity = "<null>";
//                    precipitation = 0;
//                    "solar_radiation" = "<null>";
//                    temperature = "<null>";
//                    "time_value" = "13:00 17/09/2019";
//                    "water_depth" = "<null>";
//                    "wind_direction" = "<null>";
//                    "wind_speed" = "<null>";
//            }
            
            print(self.dataMonitorExtra)
            
            self.dataMonitor.removeAllObjects()
            
            self.dataMonitor.addEntries(from: monitor as! [AnyHashable : Any])
            
            for key in self.dataMonitor.allKeys {
                for value in self.dataMonitorExtra {
                    if key as! String == value as! String {
                        self.dataMonitor[key] = "--"
                    }
                }
            }
            
            print(self.dataMonitor)

            self.tableView.reloadData()
            
            self.tempPosition = self.tableView.frame
        })
    }
    
    func didRequestStationForeCast() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getStationForecastData",
                                                    "station_code": stationCode ?? "",
                                                    "overrideAlert":"1",
                                                    "host":self], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            if result.getValueFromKey("ERR_CODE") != "0" {
                self.showToast(response?.dictionize().getValueFromKey("ERR_MSG"), andPos: 0)
                return
            }

            let data = response?.dictionize()

            if let foreCast = data!["RESULT"] as? NSArray {
                self.dataList.removeAllObjects()
                self.dataList.addObjects(from: foreCast as! [Any])
                self.tableView.reloadData()
            }
        })
    }
    
    @IBAction func didPressBack() {
        if self.isModal {
            self.dismiss(animated: true) {
                
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    let conditions: NSArray = [["key":"solar_radiation", "image":"W/m2", "tag": 105],
                               ["key":"wind_direction", "image":"", "tag": 104],
                               ["key":"wind_speed", "image":"km/h", "tag": 103],
                               ["key":"humidity", "image":"%", "tag": 102],
                               ["key":"temperature", "image":"°C", "tag": 101],
                               ["key":"water_depth", "image":"m", "tag": 100],
    ]
    
    func condition(cell: UITableViewCell, data: NSDictionary) {
        let linear = [100, 101, 102, 103, 104, 105]
        var row = 0
        for tag in linear {
            for con in conditions {
                if ((con as! NSDictionary)["tag"] as! Int) == tag {
                    let parent = (self.withView(cell, tag: Int32(tag)) as! UIView)
                    if (data.getValueFromKey(((con as! NSDictionary)["key"] as! String))) == "-1" || (data.getValueFromKey(((con as! NSDictionary)["key"] as! String))) == "" {
                        parent.heightConstaint?.constant = 0
                        row += 1
                    } else {
                        let key = (con as! NSDictionary).getValueFromKey("key")
                        let value = data.getValueFromKey(key)
                        let parent = (self.withView(cell, tag: Int32(tag)) as! UIView)
                        let info = self.withView(parent, tag: 1) as! UILabel
                        if key == "wind_direction" {
                            info.text = value == "" || value == "--" ? "--" : value
                        } else {
                            info.text = value == "" || value == "--" ? "--" : "%.1f %@".format(parameters: Float(data.getValueFromKey(key)) as! CVarArg, (con as! NSDictionary).getValueFromKey("image"))
                        }
                        
                        parent.isHidden = false
                    }
                }
            }
        }
        
        (self.withView(cell, tag: 4000) as! MarqueeLabel).text = row == 6 ? "" : "Số liệu cập nhật lúc %@".format(parameters: data.getValueFromKey("time_value"))
        if row == 6 {
            (self.withView(cell, tag: 4000) as! MarqueeLabel).heightConstaint?.constant = 0
        }
        cell.layoutIfNeeded()
    }
    
    func configHeight () -> CGFloat {
        var row = 0
        for con in conditions {
            if (dataMonitor.getValueFromKey(((con as! NSDictionary)["key"] as! String))) != "-1" && (dataMonitor.getValueFromKey(((con as! NSDictionary)["key"] as! String))) != "" {
                row += 1
            }
        }
        return CGFloat(230 + (row * 60)) - (row == 0 ? 40 : 0)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -100 {
            if isDown {
                return
            }
            isDown = true
            UIView.animate(withDuration: 0.3, animations: {
                var frame = self.tableView.frame
                frame.origin.y = CGFloat(self.screenHeight() - (IS_IPHONE_X() ? 220 : 220))
                frame.size.height = 190
                self.tableView.frame = frame
                self.blurView.alpha = 0
            })
            tableView.reloadData()
        } else if scrollView.contentOffset.y > 20 {
            if !isDown {
                return
            }
            isDown = false
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.frame = self.tempPosition
                self.blurView.alpha = 0.3
            })
            tableView.reloadData()
        }
    }
}

extension PC_ForCast_ViewController: SkeletonTableViewDataSource, SkeletonTableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? dataMonitor.allKeys.count == 0 ? 0 : isDown ? 190 : self.configHeight() : dataList.count == 0 ? 0 : 535
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isDown ? 1 : 2
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "PC_ForeCast_Cell"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isDown {
            if dataMonitor.allKeys.count != 0 {
                let image = self.withView(topCell, tag: 1000) as! UIImageView
                
                image.image = UIImage(named: "icon_rain")
                
                image.imageColor(color: AVHexColor.color(withHexString: dataMonitor.getValueFromKey("color_monitoring")))
                
                let mm = self.withView(topCell, tag: 2000) as! UILabel
                
                let rain = dataMonitor.getValueFromKey("precipitation")
                
                mm.text = rain == "" ? "--" : rain == "0" ? "0" : "%.f".format(parameters: Float(dataMonitor.getValueFromKey("precipitation")) as! CVarArg)
                
                let unit = self.withView(topCell, tag: 5000) as! UILabel
                
                unit.alpha = rain == "" ? 0 : 1
                
                let time = self.withView(topCell, tag: 3000) as! MarqueeLabel
                
                let timer = dataMonitor.getValueFromKey("time_value")
                
                var dateTime = ""
                
                let date = (timer?.components(separatedBy: " ").last)?.components(separatedBy: "/")
                
                dateTime.append(date![0])
                
                dateTime.append("/")
                
                dateTime.append(date![1])
                
                let timeTime = timer?.components(separatedBy: " ").first
                
                time.text = "Lượng mưa cập nhật từ 00:00 %@ đến %@ %@".format(parameters: dateTime, timeTime!, dateTime)
            }
            return topCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: indexPath.row == 0 ? "PC_ForeCast_Cell" : "PC_ForeCast_7_Cell", for: indexPath)
        
        if indexPath.row == 0 {
            if dataMonitor.allKeys.count != 0 {
                let image = self.withView(cell, tag: 1000) as! UIImageView
                
                image.image = UIImage(named: "icon_rain")
                
                image.imageColor(color: AVHexColor.color(withHexString: dataMonitor.getValueFromKey("color_monitoring")))
                
                let mm = self.withView(cell, tag: 2000) as! UILabel
                
                let rain = dataMonitor.getValueFromKey("precipitation")
                
                mm.text = rain == "" ? "--" : rain == "0" ? "0" : "%.f".format(parameters: Float(dataMonitor.getValueFromKey("precipitation")) as! CVarArg)
                
                let unit = self.withView(cell, tag: 5000) as! UILabel

                unit.alpha = rain == "" ? 0 : 1
                
                let time = self.withView(cell, tag: 3000) as! MarqueeLabel
                
                let timer = dataMonitor.getValueFromKey("time_value")
                
                var dateTime = ""
                
                let date = (timer?.components(separatedBy: " ").last)?.components(separatedBy: "/")
                
                dateTime.append(date![0])
                
                dateTime.append("/")
                
                dateTime.append(date![1])
                
                let timeTime = timer?.components(separatedBy: " ").first
                
                time.text = "Lượng mưa cập nhật từ 00:00 %@ đến %@ %@".format(parameters: dateTime, timeTime!, dateTime)
                
                self.condition(cell: cell, data: dataMonitor)
            }
        } else {
            if dataList.count != 0 {
                (cell as! PC_ForeCast_7_Cell).dataList = dataList
                (self.withView(cell, tag: 999) as! UILabel).alpha = 1
                (cell as! PC_ForeCast_7_Cell).collectionView.reloadData()
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        for subView in cell.contentView.subviews {
            if subView.isKind(of: MarqueeLabel.self) {
                (subView as! MarqueeLabel).restartLabel()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isDown {
            isDown = false
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.frame = self.tempPosition
                self.blurView.alpha = 0.3
            })
            tableView.reloadData()
        }
    }
}

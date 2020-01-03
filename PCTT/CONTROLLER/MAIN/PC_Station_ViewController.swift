//
//  PC_Station_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/8/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit
import SkeletonView
import GoogleMaps
import MarqueeLabel

class PC_Station_ViewController: UIViewController, UITextFieldDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 100.0
        }
    }
    
    @IBOutlet var mapView: GMSMapView!
    
    @IBOutlet var bg: UIImageView!
    
    @IBOutlet var blurView : UIView!
        
    @IBOutlet var time: MarqueeLabel!
    
    @IBOutlet var titleLabel: MarqueeLabel!
    
    @IBOutlet var notification: UIButton!
    
    @IBOutlet var mapBtn: UIButton!
    
    @IBOutlet var global: UIButton!
    
    @IBOutlet var back: UIButton!
    
    @IBOutlet var setting: UIButton!
    
    @IBOutlet var search: UITextField!
    
    @IBOutlet var mapHeight: NSLayoutConstraint!
    
    var tempPosition: CGRect!
    
    var dataList: NSMutableArray!
    
    var tempList: NSMutableArray!
    
    var kb: KeyBoard!
    
    var isFullScreen: Bool = false
    
    let refreshControl = UIRefreshControl()
    
    var provinceId: NSString! = nil
    
    var station: NSString! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if station != nil && station != "" {
            titleLabel.text = station as String?
        }
        
        mapView.delegate = self
        
        if (Permission.shareInstance()?.isLocationEnable())! {
            let location = Permission.shareInstance()?.currentLocation()! as! NSDictionary
            let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees((location.getValueFromKey("lat") as NSString).floatValue), longitude: CLLocationDegrees((location.getValueFromKey("lng")! as NSString).floatValue), zoom: 5)
            mapView?.camera = camera
            mapView?.animate(to: camera)
        }
        
        dataList = NSMutableArray.init()
        tempList = NSMutableArray.init()
        
        kb = KeyBoard.shareInstance()
        
        tableView.withCell("PC_Station_Cell0")
        tableView.withCell("PC_Station_Cell1")
        tableView.withCell("PC_Station_Cell2")
        tableView.withCell("PC_Station_Cell3")
        tableView.withCell("PC_Station_Cell4")
        tableView.withCell("PC_Station_Cell5")
        tableView.withCell("PC_Station_Cell6")

        tableView.isSkeletonable = true
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        
        let gradient = SkeletonGradient.init(baseColor: UIColor.white, secondaryColor: UIColor.lightText)
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .topLeftBottomRight)
        view.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        
        search.setClearButton(color: UIColor.white)
        search.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
        self.hideAndSeek()
        blurView.topRadius()
    }
    
    func hideAndSeek() {
        notification.alpha = provinceId != "" && provinceId != nil ? 0 : 1
        global.alpha = provinceId != "" && provinceId != nil ? 0 : 1
        back.alpha = provinceId != "" && provinceId != nil ? 1 : 0
        setting.alpha = provinceId != "" && provinceId != nil ? 0 : 1
    }
    
    override func viewDidLayoutSubviews() {
        view.layoutSkeletonIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        kb.keyboardOff()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notification.badgeValue = Information.userInfo?.getValueFromKey("count_notification")
        notification.badgeOriginX = 20
        notification.badgeOriginY = 5
        self.didRequestStationByProvince()
        self.didRequestMaxDate()
        self.didRequestBG()
        
        kb.keyboard { (height, isOn) in
            self.mapHeight.constant = isOn ? 0 : 148
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: isOn ? (height - 0) : 0, right: 0)
            if #available(iOS 10.0, *) {
                self.tableView.refreshControl = isOn ? nil : self.refreshControl
            } else {
                if isOn {
                    self.refreshControl.removeFromSuperview()
                } else {
                    self.tableView.addSubview(self.refreshControl)
                }
            }
        }
    }
    
    func didRequestBG() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getBackgroundByProvince",
                                                    "company_id":Information.userInfo?.getValueFromKey("company_id") ?? "",              "province_code":provinceId ?? "",
                                                    "overrideAlert":"1",
                                                    ], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            if result.getValueFromKey("ERR_CODE") != "0" {
                self.showToast(response?.dictionize().getValueFromKey("ERR_MSG"), andPos: 0)
                return
            }
            
            let imageUrl = (response?.dictionize()["RESULT"] as! NSDictionary).getValueFromKey("image")
            
            if self.provinceId != nil && self.provinceId != "" {
                self.bg.imageUrlNoCacheNoSave(url: Information.bg ?? "")
            } else {
                self.bg.imageUrlNoCache(url: Information.bg ?? "")
                
                self.addValue(imageUrl, andKey: "bg")
                
                Information.saveBG()
            }
        })
    }
    
    func didRequestMaxDate() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getMaxCurrentDate",
                                                    "company_id":Information.userInfo?.getValueFromKey("company_id") ?? "",              "province_code": provinceId ?? "",
                                                    "overrideAlert":"1",
                                                    ], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            if result.getValueFromKey("ERR_CODE") != "0" {
                self.showToast(response?.dictionize().getValueFromKey("ERR_MSG"), andPos: 0)
                return
            }
            
            let timer = (response?.dictionize()["RESULT"] as! NSDictionary).getValueFromKey("current_date")
            
            var dateTime = ""
            
            let date = (timer?.components(separatedBy: " ").first)?.components(separatedBy: "-")
            
            dateTime.append(date![0])
            
            dateTime.append("/")
            
            dateTime.append(date![1])
            
            
            var timeTime = ""
            
            let dateDate = (timer?.components(separatedBy: " ").last)?.components(separatedBy: ":")
            
            timeTime.append(dateDate![0])
            
            timeTime.append(":")
            
            timeTime.append(dateDate![1])
            
            self.time.text = "Lượng mưa cập nhật từ 00:00 %@ đến %@ %@".format(parameters: dateTime, timeTime, dateTime)
            
            self.tempPosition = self.mapView.frame
        })
    }
    
//    getStationSensorByProvince
    
//    getStationColorForecastByProvince
    
//    getStationPercipitionByProvince
    
    
//    getListStationByProvince
    
    func didRequestStationByProvince() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getListStationByProvince",
                                                    "company_id":Information.userInfo?.getValueFromKey("company_id") ?? "",
                                                    "province_code":provinceId ?? "",
                                                    "overrideAlert":"1",
                                                ], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            self.refreshControl.endRefreshing()
            let result = response?.dictionize() ?? [:]
            if result.getValueFromKey("ERR_CODE") != "0" {
                self.showToast(response?.dictionize().getValueFromKey("ERR_MSG"), andPos: 0)
                return
            }
            
            let data = (response?.dictionize()["RESULT"] as! NSArray).withMutable()
            self.dataList.removeAllObjects()
            self.dataList.addObjects(from: data as! [Any])
            self.tempList.removeAllObjects()
            self.tempList.addObjects(from: data as! [Any])
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                self.view.hideSkeleton()
                self.tableView.reloadData()
            })
            self.didLayoutPoints()
            
            print(data)
//            self.didRequestColorStationByProvince()
//            self.didRequestSensorStationByProvince()
        })
    }
    
    func didRequestColorStationByProvince() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getStationColorForecastByProvince",
                                                    "company_id":Information.userInfo?.getValueFromKey("company_id") ?? "",
                                                    "province_code":provinceId ?? "",
                                                    "overrideAlert":"1",
            ], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            print("+++++>", result)

            if result.getValueFromKey("ERR_CODE") != "0" {
                return
            }
            
            let data = (response?.dictionize()["RESULT"] as! NSArray)
     
            
            print("--->", data)
        })
    }
    
    func didRequestSensorStationByProvince() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getStationSensorByProvince",
                                                    "company_id":Information.userInfo?.getValueFromKey("company_id") ?? "",
                                                    "province_code":provinceId ?? "",
                                                    "overrideAlert":"1",
            ], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            if result.getValueFromKey("ERR_CODE") != "0" {
                return
            }
            
            let data = (response?.dictionize()["RESULT"] as! NSArray)
            
            for dict in data {
                for innerDict in self.dataList {
                    if (innerDict as! NSDictionary).getValueFromKey("station_code") == (dict as! NSDictionary).getValueFromKey("station_code") {
                        (innerDict as! NSMutableDictionary).addEntries(from: dict as! [AnyHashable : Any])
                        break
                    }
                }
            }
            
            for dict in data {
                for innerDict in self.tempList {
                    if (innerDict as! NSDictionary).getValueFromKey("station_code") == (dict as! NSDictionary).getValueFromKey("station_code") {
                        (innerDict as! NSMutableDictionary).addEntries(from: dict as! [AnyHashable : Any])
                        break
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                self.view.hideSkeleton()
                self.tableView.reloadData()
            })
            self.didLayoutPoints()
            
            print("--->", data)
        })
    }
    
    @IBAction func didPressMap() {
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.3, animations: {

            var frameMap = self.mapView.frame
            
            frameMap.origin.y = 0
            
            frameMap.origin.x = 0
            
            frameMap.size.height = CGFloat(self.screenHeight())
            
            frameMap.size.width = CGFloat(self.screenWidth())
            
            self.mapView.frame = self.isFullScreen ? self.tempPosition : frameMap
            
            self.isFullScreen = !self.isFullScreen
            
            var frameMapBtn = self.mapBtn.frame
            
            frameMapBtn.origin.y = self.isFullScreen ? (IS_IPHONE_X() ? 40 : 20) : 20
            
            self.mapBtn.frame = frameMapBtn
            
        }) { (done) in
            self.mapBtn.setImage(UIImage(named: self.isFullScreen ? "ic_small_screen" : "ic_full_screen"), for: .normal)
        }
    }
    
    @IBAction func didPressBack() {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressSetting() {
        self.view.endEditing(true)
        self.navigationController?.pushViewController(PC_Setting_ViewController.init(), animated: true)
    }
    
    @IBAction func didPressForcast() {
        self.navigationController?.pushViewController(PC_Global_ViewController.init(), animated: true)
    }
    
    @IBAction func didPressNotification() {
        self.view.endEditing(true)
        self.navigationController?.pushViewController(PC_Notification_ViewController.init(), animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @objc func textIsChanging(_ textField:UITextField) {
        if textField.text == "" {
            dataList.removeAllObjects()
            dataList.addObjects(from: tempList as! [Any])
            tableView.reloadData()
            return
        }
        
        let filtered = NSMutableArray.init()
        
        for dict in tempList {
            if (strip((dict as! NSDictionary)["station_name"] as! String)).containsIgnoringCase(find: strip(textField.text!)) {
                filtered.add(dict)
            }
        }
        
        dataList.removeAllObjects()
        dataList.addObjects(from: filtered as! [Any])
        tableView.reloadData()
    }
    
    @objc private func refreshWeatherData(_ sender: Any) {
        search.text = ""
        self.didRequestStationByProvince()
        self.didRequestMaxDate()
        self.didRequestBG()
    }
    
    let strip: (String) -> String = {
        var mStringRef = NSMutableString(string: $0) as CFMutableString
        CFStringTransform(mStringRef, nil, kCFStringTransformStripCombiningMarks, Bool(truncating: 0))
        return String(mStringRef)
    }
    
    func didLayoutPoints() {
        var bounds = GMSCoordinateBounds()

        for data in dataList {
            
            let dict = data as! NSDictionary
            
            let marker = GMSMarker.init(position: CLLocationCoordinate2D.init(latitude: Double(dict.getValueFromKey("latitude")) ?? 0 , longitude: Double(dict.getValueFromKey("longtitude")) ?? 0))
            marker.iconView = UIImageView(image: UIImage(named: "trans"))
            marker.title = ""
            marker.map = mapView
            bounds = bounds.includingCoordinate(marker.position)
            marker.accessibilityLabel = dict.bv_jsonString(withPrettyPrint: true)
            
            let mark = Bundle.main.loadNibNamed("PC_Marker_View", owner: nil, options: nil)?[0] as! UIView
            
            let arrow = self.withView(mark, tag: 15) as! UIView
            
            arrow.transform = CGAffineTransform(rotationAngle: 150);

            let image = self.withView(mark, tag: 11) as! UIImageView
            
            image.image = UIImage(named: "icon_rain")
            
            if dict.getValueFromKey("color_monitoring") != "" {
                image.imageColor(color: AVHexColor.color(withHexString: dict.getValueFromKey("color_monitoring")))
            }
            
            //            image.imageColor(color: AVHexColor.color(withHexString: dict.getValueFromKey("color_monitoring")))
            
            let number = self.withView(mark, tag: 12) as! UILabel

            let rain = (dict as AnyObject).getValueFromKey("preciptation")
            
            number.text = rain == "" ? "--" : rain == "0" ? "0 mm" : "%.1f mm".format(parameters: Float(dict.getValueFromKey("preciptation")) as! CVarArg)
            
            var frame = mark.frame

            frame.size.width = number.intrinsicContentSize.width + 60

            mark.frame = frame
            
            if rain != "" {
                marker.iconView = mark
            }
        }
        let update = GMSCameraUpdate.fit(bounds, withPadding: 30)
        self.mapView.animate(with: update)
        self.mapView.bringSubviewToFront(mapBtn)
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        let data = (marker.accessibilityLabel as! NSString).objectFromJSONString() as! NSDictionary
        
        let foreCast = PC_ForCast_ViewController.init()
        
        foreCast.stationCode = data.getValueFromKey("station_code") as NSString?
        
        foreCast.station = data.getValueFromKey("station_name") as NSString?
        
        self.navigationController?.pushViewController(foreCast, animated: true)
        
        return true
    }
    
    let conditions: NSArray = [["key":"solar_radiation_sensor", "image":"icon_uv_to", "forcast": "solar_radiation"],
                               ["key":"wind_direction_sensor", "image":"icon_huong_gio_to", "forcast": "wind_direction"],
                               ["key":"wind_speed_sensor", "image":"icon_gio_to", "forcast": "wind_speed"],
                               ["key":"humidity_sensor", "image":"icon_do_am", "forcast": "humidity"],
                               ["key":"temperature_sensor", "image":"icon_nhiet_do_to", "forcast": "temperature"],
                               ["key":"water_depth_sensor", "image":"icon_muc_nuoc_to", "forcast": "water_depth"],
    ]
    
    func condition(cell: UITableViewCell, data: NSDictionary, number: String) {
        let total: Int = Int(number)!
        let linear = total == 0 ? []
            : total == 1 ? [21] : total == 2 ? [21, 22] : total == 3 ? [21, 22, 23] : total == 4 ? [21, 22, 23, 24] : total == 5 ? [21, 22, 23, 24, 25] : [21, 22, 23, 24, 25, 26]
//        for index in linear {
//            (self.withView(cell, tag: Int32(index)) as! UIImageView).image = UIImage(named: "trans")
//        }
        var indexing = 0
        for con in conditions {
            for key in data.allKeys {
                if (con as! NSDictionary)["key"] as! String == key as! String && data.getValueFromKey((key as! String)) == "1"  {
                    (self.withView(cell, tag: Int32(linear[indexing])) as! UIImageView).image = UIImage(named: (con as! NSDictionary)["image"] as! String)
                    indexing += 1
                }
//                else {
//                    (self.withView(cell, tag: Int32(linear[indexing])) as! UIImageView).image = UIImage(named: "trans")
//                }
            }
        }
        for remain in linear {
//            if remain >= indexing + 21 {
//                (self.withView(cell, tag: Int32(remain)) as! UIImageView).widthConstaint?.constant = 0
//            }
        }
    }
    
    func ident(data: NSDictionary) -> NSDictionary {
        var indexing = 0
        for con in conditions {
            for key in data.allKeys {
                if (con as! NSDictionary)["key"] as! String == key as! String && data.getValueFromKey((key as! String)) == "1"  {
                    indexing += 1
                }
            }
        }
        return ["cell":"PC_Station_Cell%i".format(parameters: indexing), "total": indexing]
    }
}

extension PC_Station_ViewController: SkeletonTableViewDataSource, SkeletonTableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataList.count == 0 ? 100 :  UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "PC_Station_Cell0"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let data = dataList[indexPath.row] as! NSDictionary
        
        let cell = tableView.dequeueReusableCell(withIdentifier: (self.ident(data: data) as! NSDictionary).getValueFromKey("cell"), for: indexPath)
        
        let imageSkeleton = self.withView(cell, tag: 11) as! UIView

        imageSkeleton.hideSkeleton()

        let rainSkeleton = self.withView(cell, tag: 13) as! UIView
        
        rainSkeleton.hideSkeleton()
        
        let contentSkeleton1 = self.withView(cell, tag: 12) as! UIView
        
        contentSkeleton1.hideSkeleton()
        
        let contentSkeleton2 = self.withView(cell, tag: 14) as! UIView
        
        contentSkeleton2.hideSkeleton()
        
        
        
        let image = self.withView(cell, tag: 1) as! UIImageView
        
        image.image = UIImage(named: "icon_rain")
        
        if data.getValueFromKey("color_monitoring") != "" {
            image.imageColor(color: AVHexColor.color(withHexString: data.getValueFromKey("color_monitoring")))
        }
        
        let name = self.withView(cell, tag: 2) as! UILabel
                
        name.text = data.getValueFromKey("station_name")
        
        let mm = self.withView(cell, tag: 3) as! UILabel
        
        let rain = data.getValueFromKey("preciptation")
        
        mm.text = rain == "" ? "--" : rain == "0" ? "0 mm" : "%.1f mm".format(parameters: Float(data.getValueFromKey("preciptation")) as! CVarArg)
        
        let forcast = self.withView(cell, tag: 4) as! UIImageView
        
        forcast.image = UIImage(named: "icon_du_bao_1")
        
        if data.getValueFromKey("color_forecast") != "" {
            forcast.imageColor(color: data.response(forKey: "color_forecast") ? AVHexColor.color(withHexString: data.getValueFromKey("color_forecast")) : UIColor.clear)
        }
        
        forcast.alpha = data.getValueFromKey("forecast") == "1" ? 1 : 0
        
        let forcastText = self.withView(cell, tag: 5) as! UILabel

        forcastText.alpha = data.getValueFromKey("forecast") == "1" ? 1 : 0
        
        self.condition(cell: cell, data: data, number: (self.ident(data: data) ).getValueFromKey("total"))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if dataList.count == 0 {
            return
        }
        
        let data = dataList[indexPath.row] as! NSDictionary
        
        print(data)
        
        let dataMonitorExtra = NSMutableArray.init()
        
        for con in conditions {
            for key in data.allKeys {
                if (con as! NSDictionary)["key"] as! String == key as! String && data.getValueFromKey((key as! String)) == "1"  {
                    dataMonitorExtra.add((con as! NSDictionary).getValueFromKey("forcast"))
                }
            }
        }
        
        let foreCast = PC_ForCast_ViewController.init()
        
        foreCast.stationCode = data.getValueFromKey("station_code") as NSString?
        
        foreCast.station = data.getValueFromKey("station_name") as NSString?
        
        foreCast.dataMonitorExtra = dataMonitorExtra
        
        self.navigationController?.pushViewController(foreCast, animated: true)
    }
}

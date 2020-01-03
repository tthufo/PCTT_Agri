//
//  PC_Main_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/4/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit
import SkeletonView
import MarqueeLabel

class PC_Main_ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 70
        }
    }
    
    @IBOutlet var bg: UIImageView!
    
    @IBOutlet var blurView: UIView!
    
    @IBOutlet var cover: UIView!
    
    @IBOutlet var time: MarqueeLabel!
    
    @IBOutlet var titleLabel: MarqueeLabel!
        
    @IBOutlet var notification: UIButton!
    
    @IBOutlet var search: UITextField!

    var dataList: NSMutableArray!
    
    var tempList: NSMutableArray!

    var kb: KeyBoard!
    
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataList = NSMutableArray.init()
        tempList = NSMutableArray.init()
        
        kb = KeyBoard.shareInstance()
        
        tableView.withCell("PC_Main_Cell")
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
        
        Permission.shareInstance()?.initLocation(false, andCompletion: { (type) in
            
        })
        
        blurView.topRadius()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        self.didRequestProvince()
        self.didRequestMaxDate()
        self.didRequestBG()

        kb.keyboard { (height, isOn) in
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
                                                    "company_id":Information.userInfo?.getValueFromKey("company_id") ?? "",              "province_code":"",
                                                    "overrideAlert":"1",
                                                    ], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            if result.getValueFromKey("ERR_CODE") != "0" {
                self.showToast(response?.dictionize().getValueFromKey("ERR_MSG"), andPos: 0)
                return
            }
            
            let imageUrl = (response?.dictionize()["RESULT"] as! NSDictionary).getValueFromKey("image")
            
            self.addValue(imageUrl, andKey: "bg")
            
            Information.saveBG()
            
            self.bg.imageUrlNoCache(url: Information.bg ?? "")
        })
    }
    
    func didRequestMaxDate() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getMaxCurrentDate",
                                                "company_id":Information.userInfo?.getValueFromKey("company_id") ?? "",              "province_code":"",
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
            
        })
    }
    
    func didRequestProvince() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getProvinceByAccount",
                                                    "company_id":Information.userInfo?.getValueFromKey("company_id") ?? "",
                                                    "overrideAlert":"1",
                                                    ], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            self.refreshControl.endRefreshing()
            if error != nil {
                self.view.hideSkeleton()
                self.tableView.reloadData()
            }
            let result = response?.dictionize() ?? [:]
            if result.getValueFromKey("ERR_CODE") != "0" {
                self.showToast(response?.dictionize().getValueFromKey("ERR_MSG"), andPos: 0)
                return
            }
            
            let data = (response?.dictionize()["RESULT"] as! NSArray)
            self.dataList.removeAllObjects()
            self.dataList.addObjects(from: data as! [Any])
            self.tempList.removeAllObjects()
            self.tempList.addObjects(from: data as! [Any])
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                self.view.hideSkeleton()
                self.tableView.reloadData()
            })
        })
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
            if (strip((dict as! NSDictionary)["province_name"] as! String)).containsIgnoringCase(find: strip(textField.text!)) {
                filtered.add(dict)
            }
        }
        
        dataList.removeAllObjects()
        dataList.addObjects(from: filtered as! [Any])
        tableView.reloadData()
    }
    
    @objc private func refreshWeatherData(_ sender: Any) {
        search.text = ""
        self.didRequestProvince()
        self.didRequestMaxDate()
        self.didRequestBG()
    }
    
    let strip: (String) -> String = {
        var mStringRef = NSMutableString(string: $0) as CFMutableString
        CFStringTransform(mStringRef, nil, kCFStringTransformStripCombiningMarks, Bool(truncating: 0))
        return String(mStringRef)
    }
}

extension PC_Main_ViewController: SkeletonTableViewDataSource, SkeletonTableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "PC_Main_Cell"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PC_Main_Cell", for: indexPath)
        
        let data = dataList[indexPath.row] as! NSDictionary
        
        let image = self.withView(cell, tag: 1) as! UIImageView
        
        image.image = UIImage(named: "icon_rain")
        
        image.imageColor(color: AVHexColor.color(withHexString: data.getValueFromKey("color")))
        
        let name = self.withView(cell, tag: 2) as! UILabel

        name.text = data.getValueFromKey("province_name")
        
        let mm = self.withView(cell, tag: 3) as! UILabel
        
        let rain = data.getValueFromKey("preciptation_max")
        
        mm.text = rain == "" ? "--" : rain == "0" ? "0 mm" : "%.01f mm".format(parameters: Float(data.getValueFromKey("preciptation_max")) as! CVarArg)

        let rainSkeleton = self.withView(cell, tag: 11) as! UIView
        
        rainSkeleton.hideSkeleton()
        
        let contentSkeleton1 = self.withView(cell, tag: 12) as! UIView
        
        contentSkeleton1.hideSkeleton()
        
        let contentSkeleton2 = self.withView(cell, tag: 13) as! UIView
        
        contentSkeleton2.hideSkeleton()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if dataList.count == 0 {
            return
        }
        
        let data = dataList[indexPath.row] as! NSDictionary
        let station = PC_Station_ViewController.init()
        station.provinceId = data.getValueFromKey("province_code") as NSString?
        station.station = data.getValueFromKey("province_name") as NSString?
        self.navigationController?.pushViewController(station, animated: true)
    }
}

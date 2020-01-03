//
//  PC_Setting_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/4/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit
import MarqueeLabel

class PC_Setting_ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var header: UITableViewCell!
    
    @IBOutlet var bg: UIImageView!
    
    @IBOutlet var blurView: UIView!
    
    @IBOutlet var bottom: MarqueeLabel!

    @IBOutlet var copyR: UILabel!
    
    var isShow: Bool = false

    var dataList: NSArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.withCell("PC_Setting_Cell")
        
        let uInfo: NSDictionary = Information.userInfo!
        
        let date = ((uInfo["created_at"] as! NSString).components(separatedBy: "T").first! as NSString)
        
        let dateTime = date.components(separatedBy: "-")
        
        var dat: String = ""
        for n in 0...dateTime.count - 1 {
            dat.append(dateTime[dateTime.count - 1 - n])
            if n != 2 {
                dat.append("/")
            }
        }
        
        dataList = [["title":"V", "content": uInfo["name"]],
        ["title":"Đổi mật khẩu", "content": "nav"],
        ["title":"Ngày khởi tạo", "content": dat],
        ["title":"Email", "content": uInfo["email"]],
        ["title":"Liên hệ", "content": uInfo["phone"]],
        ["title":"Cho phép gửi thông báo", "content": "sw"],
        ["title":"Phản hồi", "content": "nav", "badge":"Mới"],
        ["title":"Thoát tài khoản", "content": ""]]
        
        if Information.bg != nil && Information.bg != "" {
            bg.imageUrlNoCache(url: Information.bg ?? "")
        }
                
        copyR.text = "%@".format(parameters: (Information.userInfo?.getValueFromKey("company_name"))!)
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

        bottom.text = "Weather Book © 2019 - Ver %@ - Hotline 0917271595".format(parameters: appVersion!)

        FirePush.shareInstance()?.completion({ (state, info) in
            self.tableView.reloadData()
        })
        
        blurView.topRadius()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.didRequestStatusFeedBack()
        tableView.reloadData()
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func didRequestStatusFeedBack() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"checkStatusFeedback",
                                                    "user_id":Information.userInfo?.getValueFromKey("user_id") ?? "",
                                                    "overrideAlert":"1"
            ], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            if result.getValueFromKey("ERR_CODE") != "0" {
//                self.showToast(response?.dictionize().getValueFromKey("ERR_MSG"), andPos: 0)
                return
            }
            let data = (response?.dictionize()["RESULT"] as! NSDictionary)
            self.isShow = data.getValueFromKey("count_status") == "1" ? true : false
            self.tableView.reloadData()
        })
    }
    
    func didPressLogout() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"logout",
                                                    "user_id":Information.userInfo?.getValueFromKey("user_id") ?? "",
                                                    "device_id":FirePush.shareInstance()?.deviceToken() ?? "",
                                                    "overrideAlert":"1",
                                                    "host":self], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            if result.getValueFromKey("ERR_CODE") != "0" {
                self.showToast(response?.dictionize().getValueFromKey("ERR_MSG"), andPos: 0)
                return
            }
            
            Information.removeInfo()
            
            self.navigationController?.popToRootViewController(animated: true)
        })
    }
}

extension PC_Setting_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 210 : 55
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = dataList![indexPath.row] as! NSDictionary
        
        if indexPath.row == 0 {
            
            let title = self.withView(header, tag: 1) as! UILabel

            title.text = data["title"] as? String
            
            let content = self.withView(header, tag: 2) as! UILabel
            
            content.text = data["content"] as? String
            
            return header
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PC_Setting_Cell", for: indexPath)
        
        let title = self.withView(cell, tag: 1) as! UILabel

        title.text = data["title"] as? String
        
        let btn = self.withView(cell, tag: 100) as! UIButton
        
        btn.alpha = 1
        
        btn.setTitle("", for: .normal)
        
        btn.badgeValue = isShow ? data.getValueFromKey("badge") != "" ? "Mới" : "" : ""
        
        btn.badgeOriginX = 65
        
        btn.badgeOriginY = -5
        
        
        let content = self.withView(cell, tag: 2) as! UILabel
        
        content.text = data["content"] as? String != "sw" && data["content"] as? String != "nav" ? data["content"] as? String : ""
        
        let sw = self.withView(cell, tag: 3) as! UISwitch

        sw.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        sw.isOn = self.getValue("push") == "1" && self.checkForNotification()
        
        sw.isEnabled = self.checkForNotification()
        
        sw.action(forTouch: [:]) { (obj) in
            if self.getValue("push") == "1" {
                FirePush.shareInstance()?.didUnregisterNotification()
            } else {
                FirePush.shareInstance()?.reRegisterNotification()
            }
            self.addValue(self.getValue("push") == "1" ? "0" : "1", andKey: "push")
            sw.isOn = self.getValue("push") == "1"
        }
        
        sw.alpha = data["content"] as? String == "sw" ? 1 : 0
        
        let nav = self.withView(cell, tag: 4) as! UIImageView
        
        nav.alpha = data["content"] as? String == "nav" ? 1 : 0
        
        return  cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 {
            self.navigationController?.pushViewController(PC_ChangePass_ViewController.init(), animated: true)
        }
        
        if indexPath.row == 6 {
            self.navigationController?.pushViewController(PC_FeedBack_ViewController.init(), animated: true)
        }
        
        if indexPath.row == 5 {
            
            if !self.checkForNotification() {
                UIApplication.shared.open(URL(string:"App-Prefs:root=NOTIFICATIONS_ID")!, options: [:], completionHandler: nil)
                return
            }
            
            let cell = tableView.cellForRow(at: indexPath)
            if self.getValue("push") == "1" {
                FirePush.shareInstance()?.didUnregisterNotification()
            } else {
                FirePush.shareInstance()?.reRegisterNotification()
            }
            self.addValue(self.getValue("push") == "1" ? "0" : "1", andKey: "push")
            let sw = self.withView(cell, tag: 3) as! UISwitch
            sw.isOn = self.getValue("push") == "1"
        }
        
        if indexPath.row == 7 {
            self.didPressLogout()
        }
    }
}


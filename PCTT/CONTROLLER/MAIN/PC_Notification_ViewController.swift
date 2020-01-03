//
//  PC_Notification_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/6/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit
import SkeletonView
import SwipyCell

class PC_Notification_ViewController: UIViewController , UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 92.0
        }
    }
    
    @IBOutlet var bg: UIImageView!
    
    @IBOutlet var blurView: UIView!
    
    @IBOutlet var alert: UILabel!
    
    @IBOutlet var menu: UIButton!
    
    var dataList: NSMutableArray!
    
    let refreshControl = UIRefreshControl()
    
    var pageIndex: Int = 1
    
    var totalPage: Int = 1
    
    var isLoadMore: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataList = NSMutableArray.init()
        
        tableView.withCell("PC_Notification_Cell")
        tableView.withCell("TG_Empty_Cell")
        
        tableView.isSkeletonable = true
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(didReloadNotification(_:)), for: .valueChanged)
        
        if Information.bg != nil && Information.bg != "" {
            bg.imageUrlNoCache(url: Information.bg ?? "")
        }
        
        self.didRequestNotification(isShow: true)
        
        let gradient = SkeletonGradient.init(baseColor: UIColor.white, secondaryColor: UIColor.lightText)
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .topLeftBottomRight)
        view.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        
        blurView.topRadius()
    }
    
    override func viewDidLayoutSubviews() {
        view.layoutSkeletonIfNeeded()
    }
    
    @objc func didReloadNotification(_ sender: Any) {
        isLoadMore = false
        pageIndex = 1
        totalPage = 1
        didRequestNotification(isShow: true)
    }
    
    func didRequestNotification(isShow: Bool) {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getNotification",
                                                    "user_id":Information.userInfo?.getValueFromKey("user_id") ?? "",
                                                    "page_index": pageIndex,
                                                    "page_size": 10,
                                                    "overrideAlert":"1",
                                                    //                                                    "overrideLoading":isShow ? 1 : 0,
            //                                                    "host":self
            ], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            self.refreshControl.endRefreshing()
            let result = response?.dictionize() ?? [:]
            if result.getValueFromKey("ERR_CODE") != "0" {
                self.showToast(response?.dictionize().getValueFromKey("ERR_MSG"), andPos: 0)
                return
            }
            
            print(response)
            
            self.totalPage = (result["RESULT"] as! NSDictionary)["total_page"] as! Int
            
            self.pageIndex += 1
            
            if !self.isLoadMore {
                self.dataList.removeAllObjects()
                Information.changeInfo(notification: ((result["RESULT"] as! NSDictionary)["count_notification"] as! Int))
            }
            
            let data = ((result["RESULT"] as! NSDictionary)["list"] as! NSArray)
            self.dataList.addObjects(from: data.withMutable())
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                self.view.hideSkeleton()
                self.tableView.reloadData()
                self.alert.isHidden = self.dataList.count != 0
                self.menu.isEnabled = self.dataList.count != 0
            })
        })
    }
    
    func didRequestStatusNotification(idNotification: NSString) {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"sendStatusNotification",
                                                    "user_id":Information.userInfo?.getValueFromKey("user_id") ?? "",
                                                    "notification_id": idNotification == "-1" ? NSNull() : idNotification,
                                                    "status": 1,
                                                    "overrideAlert":"1"
            ], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            print(response ?? "")
            let result = response?.dictionize() ?? [:]
            if result.getValueFromKey("ERR_CODE") != "0" {
                return
            }
            if idNotification == "-1" {
                for noti in self.dataList {
                    (noti as! NSMutableDictionary)["status"] = "1"
                }
                self.tableView.reloadData(withAnimation: true)
            }
        })
    }
    
    func didRequestDeleteNotification(idNotification: NSString) {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"deleteNotification",
                                                    "user_id":Information.userInfo?.getValueFromKey("user_id") ?? "",
                                                    "notification_id": idNotification == "-1" ? NSNull() : idNotification,
                                                    "status": 1,
                                                    "overrideAlert":"1"
            ], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            if result.getValueFromKey("ERR_CODE") != "0" {
                return
            }
            if idNotification == "-1" {
                self.didReloadNotification(NSNull())
            } else {
                self.showToast("Xóa thành công", andPos: 0)
            }
        })
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressOption() {
        EM_MenuView.init(menu: [:]).show(completion: { (indexing, obj, menu) in
            switch indexing {
            case 1:
                self.tableView.scrollToBottom(animated: false, scrollPostion: .top)
                self.refreshControl.programaticallyBeginRefreshing(in: self.tableView)
                self.didReloadNotification(obj)
                break
            case 2:
                self.didRequestStatusNotification(idNotification: "-1")
                break
            case 3:
                self.didRequestDeleteNotification(idNotification: "-1")
                break
            default:
                break
            }
        })
    }
    
    func viewWithImageName(_ imageName: String) -> UIView {
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .center
        return imageView
    }
}

extension PC_Notification_ViewController: SkeletonTableViewDataSource, SkeletonTableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataList.count == 0 ? 92 : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count == 0 ? dataList.count : dataList.count
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "PC_Notification_Cell"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: dataList.count == 0 ? "TG_Empty_Cell" : "PC_Notification_Cell", for: indexPath) as! SwipyCell
        
        if dataList.count == 0 {
            
            return cell
        }
        
        let data = dataList[indexPath.row] as! NSDictionary
        
        
        let imageSkeleton = self.withView(cell, tag: 11) as! UIView
        
        imageSkeleton.hideSkeleton()
        
        let rainSkeleton = self.withView(cell, tag: 13) as! UIView
        
        rainSkeleton.hideSkeleton()
        
        let contentSkeleton1 = self.withView(cell, tag: 12) as! UIView
        
        contentSkeleton1.hideSkeleton()
        
        
        
        let timeline = self.withView(cell, tag: 10) as! UILabel
        
        let dateTime = data.getValueFromKey("timeline")?.components(separatedBy: " ").last
        
        let timeTime = data.getValueFromKey("timeline")?.components(separatedBy: " ").first
        
        let dateTimeFormat = ((dateTime! as NSString).date(withFormat: "yyyy-MM-dd")! as NSDate).string(withFormat: "dd/MM/yyyy")
        
        timeline.text = "%@ %@".format(parameters: timeTime!, dateTimeFormat!)
        
        
        
        let image = self.withView(cell, tag: 1) as! UIImageView
        
        image.image = UIImage(named: data.getValueFromKey("type") == "0" ? "icon_rain" : data.getValueFromKey("type") == "1" ? "exclamation" : "mail")
        
        if data.getValueFromKey("type") == "0" || data.getValueFromKey("type") == "1" {
            image.imageColor(color: AVHexColor.color(withHexString: data.getValueFromKey("color")))
        }
        
        let title = self.withView(cell, tag: 2) as! UILabel
        
        title.text = data.getValueFromKey("title")
        
        let content = self.withView(cell, tag: 3) as! UILabel
        
        content.hideSkeleton()
        
        content.text = data.getValueFromKey("content")
        
        let bg = self.withView(cell, tag: 5) as! UIView
        
        bg.alpha = data.getValueFromKey("status") == "1" ? 0 : 0.3
        
        let swipeView = viewWithImageName("trash")
        let swipeColor = AVHexColor.color(withHexString: "#456568")
        
        cell.addSwipeTrigger(forState: .state(0, .right), withMode: .exit, swipeView: swipeView, swipeColor: swipeColor!, completion: { cell, trigger, state, mode in
            self.dataList.removeObject(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            let status = data.getValueFromKey("status")
            if status == "0" {
                Information.changeInfo(notification: -1)
            }
            self.tableView.reloadData()
            self.didRequestDeleteNotification(idNotification: data.getValueFromKey("notification_id")! as NSString)
        })
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if dataList.count == 0 {
            return
        }
        
        let data = dataList[indexPath.row] as! NSDictionary
        
        let status = data.getValueFromKey("status")
        
        if status == "0" {
            (dataList[indexPath.row] as! NSMutableDictionary)["status"] = 1
            
            tableView.reloadData()
            
            Information.changeInfo(notification: -1)
            
            self.didRequestStatusNotification(idNotification: data.getValueFromKey("notification_id")! as NSString)
        }
        
        let foreCast = PC_ForCast_ViewController.init()
        
        foreCast.stationCode = data.getValueFromKey("station_code") as NSString?
        
        foreCast.station = data.getValueFromKey("station_name") as NSString?
        
        self.navigationController?.pushViewController(foreCast, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if self.pageIndex == 1 {
            return
        }
        
        if indexPath.row == dataList.count - 1 {
            if self.pageIndex <= self.totalPage {
                self.isLoadMore = true
                self.didRequestNotification(isShow: true)
            }
        }
    }
}

extension UIRefreshControl {
    func programaticallyBeginRefreshing(in tableView: UITableView) {
        self.tintColor = UIColor.white
        beginRefreshing()
        let offsetPoint = CGPoint.init(x: 0, y: -frame.size.height)
        tableView.setContentOffset(offsetPoint, animated: true)
    }
}

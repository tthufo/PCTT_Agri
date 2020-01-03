//
//  PC_FeedBack_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/9/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit
import MarqueeLabel
import SkeletonView

class PC_FeedBack_ViewController: UIViewController {
    
    var dataList: NSMutableArray!
    
    @IBOutlet var bg: UIImageView!
    
    @IBOutlet var titleLabel: MarqueeLabel!
    
    @IBOutlet var sendBtn: UIButton!

    @IBOutlet var content: UITextField!
    
    @IBOutlet var bottomGap: NSLayoutConstraint!
    
    var pageIndex: Int = 1
    
    var totalPage: Int = 1
    
    var isLoadMore: Bool = false
    
    @IBOutlet weak var tableView: ChatTable! {
        didSet {
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 60.0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataList = NSMutableArray.init()
    
        let data = [[
            "user_id": 1,
            "content": "Lượng",
            "timeline": "04:05 25/06/2019"
            ],
                    [
                        "user_id": 78,
                        "content": "Lượng mưa",
                        "timeline": "04:05 25/06/2019"
            ],
                    [
                        "user_id": 1,
                        "content": "Lượng mưa trạmDifdsfdfdfdffsfsden Ha Noi - CauDifdsfdfdfdffsfsden Difdsfdfdfdffsfsden không chính xác",
                        "timeline": "04:05 25/06/2019"
            ],
                    [
                        "user_id": 78,
                        "content": "Lượng mưa trạm Ha Noi - Cau Dien không chính xác",
                        "timeline": "04:05 25/06/2019"
            ],
                    [
                        "user_id": 78,
                        "content": "Lượng mưa trạm Ha Noi Lượng mưa trạm Ha Noi - Cau Dien không chính xác Lượng mưa trạm Ha Noi - Cau Dien không chính xác - Cau Dien không chính xác",
                        "timeline": "04:05 25/06/2019"
            ],
                    [
                        "user_id": 1,
                        "content": "Lượng",
                        "timeline": "04:05 25/06/2019"
            ],
                    [
                        "user_id": 78,
                        "content": "Lượng mưa",
                        "timeline": "04:05 25/06/2019"
            ],
                    [
                        "user_id": 1,
                        "content": "Lượng mưa trạmDifdsfdfdfdffsfsden Ha Noi - CauDifdsfdfdfdffsfsden Difdsfdfdfdffsfsden không chính xác",
                        "timeline": "04:05 25/06/2019"
            ],
                    [
                        "user_id": 78,
                        "content": "Lượng mưa trạm Ha Noi - Cau Dien không chính xác",
                        "timeline": "04:05 25/06/2019"
            ],
                    [
                        "user_id": 78,
                        "content": "Lượng mưa trạm Ha Noi Lượng mưa trạm Ha Noi - Cau Dien không chính xác Lượng mưa trạm Ha Noi - Cau Dien không chính xác - Cau Dien không chính xác",
                        "timeline": "04:05 25/06/2019"
            ],[
                "user_id": 1,
                "content": "Lượng",
                "timeline": "04:05 25/06/2019"
            ],
              [
                "user_id": 78,
                "content": "Lượng mưa",
                "timeline": "04:05 25/06/2019"
            ],
              [
                "user_id": 1,
                "content": "Lượng mưa trạmDifdsfdfdfdffsfsden Ha Noi - CauDifdsfdfdfdffsfsden Difdsfdfdfdffsfsden không chính xác",
                "timeline": "04:05 25/06/2019"
            ],
              [
                "user_id": 78,
                "content": "Lượng mưa trạm Ha Noi - Cau Dien không chính xác",
                "timeline": "04:05 25/06/2019"
            ],
              [
                "user_id": 78,
                "content": "Lượng mưa trạm Ha Noi Lượng mưa trạm Ha Noi - Cau Dien không chính xác Lượng mưa trạm Ha Noi - Cau Dien không chính xác - Cau Dien không chính xác",
                "timeline": "04:05 25/06/2019"
            ],[
                "user_id": 1,
                "content": "Lượng",
                "timeline": "04:05 25/06/2019"
            ],
              [
                "user_id": 78,
                "content": "Lượng mưa",
                "timeline": "04:05 25/06/2019"
            ],
              [
                "user_id": 1,
                "content": "Lượng mưa trạmDifdsfdfdfdffsfsden Ha Noi - CauDifdsfdfdfdffsfsden Difdsfdfdfdffsfsden không chính xác",
                "timeline": "04:05 25/06/2019"
            ],
              [
                "user_id": 78,
                "content": "Lượng mưa trạm Ha Noi - Cau Dien không chính xác",
                "timeline": "04:05 25/06/2019"
            ],
              [
                "user_id": 78,
                "content": "Lượng mưa trạm Ha Noi Lượng mưa trạm Ha Noi - Cau Dien không chính xác Lượng mưa trạm Ha Noi - Cau Dien không chính xác - Cau Dien không chính xác",
                "timeline": "04:05 25/06/2019"
            ],[
                "user_id": 1,
                "content": "Lượng",
                "timeline": "04:05 25/06/2019"
            ],
              [
                "user_id": 78,
                "content": "Lượng mưa",
                "timeline": "04:05 25/06/2019"
            ],
              [
                "user_id": 1,
                "content": "Lượng mưa trạmDifdsfdfdfdffsfsden Ha Noi - CauDifdsfdfdfdffsfsden Difdsfdfdfdffsfsden không chính xác",
                "timeline": "04:05 25/06/2019"
            ],
              [
                "user_id": 78,
                "content": "Lượng mưa trạm Ha Noi - Cau Dien không chính xác",
                "timeline": "04:05 25/06/2019"
            ],
              [
                "user_id": 78,
                "content": "Lượng mưa trạm Ha Noi Lượng mưa trạm Ha Noi - Cau Dien không chính xác Lượng mưa trạm Ha Noi - Cau Dien không chính xác - Cau Dien không chính xác",
                "timeline": "04:05 25/06/2019"
            ],[
                "user_id": 1,
                "content": "Lượng",
                "timeline": "04:05 25/06/2019"
            ],
              [
                "user_id": 78,
                "content": "Lượng mưa",
                "timeline": "04:05 25/06/2019"
            ],
              [
                "user_id": 1,
                "content": "Lượng mưa trạmDifdsfdfdfdffsfsden Ha Noi - CauDifdsfdfdfdffsfsden Difdsfdfdfdffsfsden không chính xác",
                "timeline": "04:05 25/06/2019"
            ],
              [
                "user_id": 78,
                "content": "Lượng mưa trạm Ha Noi - Cau Dien không chính xác",
                "timeline": "04:05 25/06/2019"
            ],
              [
                "user_id": 78,
                "content": "Lượng mưa trạm Ha Noi Lượng mưa trạm Ha Noi - Cau Dien không chính xác Lượng mưa trạm Ha Noi - Cau Dien không chính xác - Cau Dien không chính xác",
                "timeline": "04:05 25/06/2019"
            ]
        ]
        
        //        dataList.addObjects(from: data)
        
        tableView.withCell("PC_FeedBack_Cell")
        
        tableView.transform = CGAffineTransform(rotationAngle: (-.pi))
        
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.size.width - 10)
        
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        tableView.isSkeletonable = true
        
        let gradient = SkeletonGradient.init(baseColor: UIColor.white, secondaryColor: UIColor.lightText)
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .topLeftBottomRight)
        view.showAnimatedGradientSkeleton(usingGradient: gradient, animation: animation)
        
//        (tableView.inputAccessory.sendButton as UIButton).action(forTouch: [:]) { (obj) in
        sendBtn.action(forTouch: [:]) { (obj) in
            let comment = NSMutableDictionary.init(dictionary: ["user_id":Information.userInfo?.getValueFromKey("user_id") ?? "",
//                                  "content":self.tableView.inputAccessory.textView.text as Any,
                "content":self.content.text as Any,
                "timeline": NSDate().string(withFormat: "hh:mm dd/MM/yyyy") as Any
                ])
            self.dataList.insert(comment, at: 0)
            self.tableView.reloadData()
//            self.didRequestSendFeedBack(content: self.tableView.inputAccessory.textView.text)
            self.didRequestSendFeedBack(content: self.content.text!)
//            self.tableView.inputAccessory.textView.text = ""
            self.content.text = ""
            self.tableView.scrollToBottom(animated: true, scrollPostion: .top)
//            (self.tableView.inputAccessory.sendButton as UIButton).isEnabled = false
            self.sendBtn.isEnabled = false
        }
        
        tableView.inputAccessory.alpha = 0
        
        tableView.action(forTouch: [:]) { (objc) in
//            (self.tableView.inputAccessory.textView as UITextView).resignFirstResponder()
            self.view.endEditing(true)
        }
        
        if Information.bg != nil && Information.bg != "" {
            bg.imageUrlNoCache(url: Information.bg ?? "")
        }
        
        self.didRequestFeedBack(isShow: true)
        
        content.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            bottomGap.constant = keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
//            let keyboardRectangle = keyboardFrame.cgRectValue
//            let keyboardHeight = keyboardRectangle.height
            bottomGap.constant = 9
        }
    }
    
    @objc func textIsChanging(_ textField:UITextField) {
        sendBtn.isEnabled = textField.text!.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "") == "" ? false : true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutSkeletonIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5) {
            self.tableView.inputAccessory.alpha = 1
        }
//        tableView.becomeFirstResponder()
    }
    
    @objc func didReloadFeedBack(_ sender: Any) {
        isLoadMore = false
        pageIndex = 1
        totalPage = 1
        didRequestFeedBack(isShow: true)
    }
    
    func didRequestFeedBack(isShow: Bool) {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getFeedback",
                                                    "user_id":Information.userInfo?.getValueFromKey("user_id") ?? "",
                                                    "page_index":pageIndex,
                                                    "page_size":10,
                                                    "overrideAlert":"1",
//                                                    "overrideLoading": isShow ? 1 : 0,
//                                                    "host":self
            ], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            if error != nil {
                self.view.hideSkeleton()
                self.tableView.reloadData()
            }
            
            let result = response?.dictionize() ?? [:]
            if result.getValueFromKey("ERR_CODE") != "0" {
                self.showToast(response?.dictionize().getValueFromKey("ERR_MSG"), andPos: 0)
                self.view.hideSkeleton()
                self.tableView.reloadData()
                return
            }
            
            self.totalPage = (result["RESULT"] as! NSDictionary)["total_page"] as! Int
            
            self.pageIndex += 1
            
            let data = ((result["RESULT"] as! NSDictionary)["list"] as! NSArray)
            
            if !self.isLoadMore {
                self.dataList.removeAllObjects()
            }
            
            self.dataList.addObjects(from: data.reversed())
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                self.view.hideSkeleton()
                self.tableView.reloadData()
            })
            
            if isShow {
                self.tableView.scrollToBottom(animated: false, scrollPostion: .top)
            }
        })
    }
    
    func didRequestSendFeedBack(content: String) {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"sendFeedback",
                                                    "user_id":Information.userInfo?.getValueFromKey("user_id") ?? "",
                                                    "content":content,
                                                    "status":0,
                                                    "overrideAlert":"1"], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            (self.dataList.firstObject as! NSMutableDictionary)["failed"] = result.getValueFromKey("ERR_CODE") != "0" ? "1" : "0"
            self.tableView.reloadData()
        })
    }
    
    @IBAction func didPressBack() {
//        (self.tableView.inputAccessory.textView as UITextView).resignFirstResponder()
        self.view.endEditing(true)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        self.navigationController?.popViewController(animated: true)
    }
}

extension PC_FeedBack_ViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

extension PC_FeedBack_ViewController: SkeletonTableViewDataSource, SkeletonTableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataList.count == 0 ? 60 :  UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "PC_FeedBack_Cell"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "PC_FeedBack_Cell", for: indexPath)
        
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        let data = dataList[indexPath.row] as! NSDictionary
        
        let isMe = data.getValueFromKey("user_id") != Information.userInfo?.getValueFromKey("user_id")
        
        
        let dayLeft = self.withView(cell, tag: 10) as! UILabel
        
        dayLeft.text = data.getValueFromKey("timeline")
        
        let contentLeft = self.withView(cell, tag: 11) as! UIMarginLabel
        
        contentLeft.text = isMe ? data.getValueFromKey("content") : ""
        
        let dayRight = self.withView(cell, tag: 20) as! UILabel
        
        dayRight.text = data.getValueFromKey("timeline")
        
        
        let contentRight = self.withView(cell, tag: 21) as! UIMarginLabel
        
        contentRight.text = !isMe ? data.getValueFromKey("content") : ""
        
        
        dayLeft.isHidden = !isMe
        
        contentLeft.isHidden = !isMe
        
        dayRight.isHidden = isMe
        
        contentRight.isHidden = isMe
        
        let contentSkeleton1 = self.withView(cell, tag: 99) as! UIView
        
        contentSkeleton1.hideSkeleton()
        
        let contentSkeleton2 = self.withView(cell, tag: 100) as! UIView
        
        contentSkeleton2.hideSkeleton()
        
        
        
        let resend = self.withView(cell, tag: 9999) as! UIButton

        resend.isHidden = data.getValueFromKey("failed") != "1"
        resend.action(forTouch: [:]) { (objc) in
            self.dataList.moveObject(at: UInt(indexPath.row), to: UInt(0))
            (self.dataList.firstObject as! NSMutableDictionary)["failed"] = "0"
            self.tableView.reloadData(withAnimation: true)
            let content = self.dataList.firstObject as! NSMutableDictionary
            self.didRequestSendFeedBack(content: content.getValueFromKey("content"))
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if self.pageIndex == 1 {
            return
        }
        
        if indexPath.row == dataList.count - 1 {
            if self.pageIndex <= self.totalPage {
                self.isLoadMore = true
                self.didRequestFeedBack(isShow: false)
            }
        }
    }
}

class UIMarginLabel: UILabel {
    
    var topInset:       CGFloat = 5
    var rightInset:     CGFloat = 5
    var bottomInset:    CGFloat = 5
    var leftInset:      CGFloat = 5
    
    public override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    public override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
    
    public override func sizeToFit() {
        super.sizeThatFits(intrinsicContentSize)
    }
}

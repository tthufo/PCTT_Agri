//
//  PC_Global_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/12/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit

import SDWebImage

import ImageScrollView

class PC_Global_ViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var bg: UIImageView!
    
    @IBOutlet var loadingBg: UIImageView!
    
    @IBOutlet var day: UILabel!

    @IBOutlet var halfDay: UILabel!

    @IBOutlet var hour: UILabel!
    
    @IBOutlet var play: UIButton!
    
    @IBOutlet var back: UIButton!
    
    @IBOutlet var playWidth: NSLayoutConstraint!
    
    @IBOutlet var bottomBar: UIView!
    
    @IBOutlet var bottomBarBG: UIView!
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var imageView: UIImageView!

    var imageData: NSMutableDictionary!
    
    var listDay: NSMutableArray!
    
    var listHour: NSMutableArray!
    
    var listImageView: NSMutableArray!
    
    var timer: Timer!
    
    var timerHour: Timer!
    
    var isHourShow: Bool = false
    
    var imageIndex:NSInteger = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()

        if Information.bg != nil && Information.bg != "" {
            bg.imageUrlNoCache(url: Information.bg ?? "")
        }
        
        back.setImage(UIImage(named: "icon_back_global"), for: .normal)
        
        imageData = NSMutableDictionary.init()
        
        listDay = NSMutableArray.init()

        listHour = NSMutableArray.init()
        
        listImageView = NSMutableArray.init()

        self.didRequestAnalysis()
        
        for label in [day, halfDay, hour] {
            (label as! UILabel).action(forTouch: [:]) { (obj) in
                self.playWidth.constant = (label as! UILabel) == self.hour ? 44 : 0
                self.play.backgroundColor = (label as! UILabel) == self.hour ? AVHexColor.color(withHexString: "#0099FF") : UIColor.clear
                for el in [self.day, self.halfDay, self.hour] {
                    if (el as! UILabel) == label {
                        (el as! UILabel).backgroundColor = AVHexColor.color(withHexString: "#0099FF")
                    } else {
                        (el as! UILabel).backgroundColor = UIColor.clear
                    }
                }
                self.scrollView.setContentOffset(CGPoint(x: label!.tag * Int(self.screenWidth()), y: 0), animated: true)
                self.timeStart(isShow: true)
                self.pageControl.currentPage = [self.day, self.halfDay, self.hour].index(of: label)!
                self.pageControl.numberOfPages = 3
                self.play.setImage(UIImage(named: "ic_play_video"), for: .normal)
                self.scrollView.isHidden = false
                self.imageView.isHidden = true
                self.isHourShow = false
                self.imageIndex = 0
                self.imageView.image = self.getImageHour(index: 0)
            }
        }
        
        pageControl.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
        self.view.action(forTouch: [:]) { (obj) in
            self.timeStart(isShow: true)
            print("aihihi")
        }
        
        day.backgroundColor = AVHexColor.color(withHexString: "#0099FF")
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
        
//        let tap = UILongPressGestureRecognizer(target: self, action: #selector(tapHandler))
//        tap.minimumPressDuration = 0
//        imageView.addGestureRecognizer(tap)
    }
    
    func getImageHour (index: Int) -> UIImage {
        for image in listHour {
            if (image as! NSDictionary)["index"] as! Int == index {
                return (image as! NSDictionary)["img"] as! UIImage
            }
        }
        
        return UIImage(named: "bg_no_image")!
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if isHourShow {
                self.timeHourStart(isShow: false)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            // do something with your currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
//            print("up")
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if isHourShow {
                self.timeHourStart(isShow: true)
            }
        }
    }
    
//    @objc func tapHandler(gesture: UITapGestureRecognizer) {
//        if gesture.state == .began {
//            print("tap down")
//            self.timeStart(isShow: true)
//        } else if gesture.state == .ended {
//            print("tap up")
//        }
//    }
    
    @objc func swiped(gesture: UIGestureRecognizer) {
        
        if listHour.count == 0 {
            return
        }
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                imageIndex -= 1
                if imageIndex < 0 {
                    imageIndex = 0
                    return
                }
                pageControl.currentPage = imageIndex
                UIView.transition(with: self.imageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.imageView.imageWithFade = self.getImageHour(index: self.imageIndex)
                }) { (done) in
                }
            case UISwipeGestureRecognizer.Direction.left:
                imageIndex += 1
                if imageIndex > listHour.count - 1 {
                    imageIndex = listHour.count - 1
                    return
                }
                pageControl.currentPage = imageIndex
                UIView.transition(with: self.imageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.imageView.imageWithFade = self.getImageHour(index: self.imageIndex)
                }) { (done) in
                }
            default:
                break
            }
        }
    }
    
    func timeHourStart (isShow: Bool) {
        if timerHour != nil {
            timerHour.invalidate()
            timerHour = nil
        }
        if !isShow {
            return
        }
        timerHour = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(PC_Global_ViewController.updateHourImage),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func timeStart (isShow: Bool) {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        if !isShow {
            return
        }
        UIView.animate(withDuration: 0.3) {
            self.bottomBar.alpha = 1
            self.bottomBarBG.alpha = 0.6
        }
        timer = Timer.scheduledTimer(timeInterval: 5,
                                     target: self,
                                     selector: #selector(PC_Global_ViewController.update),
                                     userInfo: nil,
                                     repeats: false)
    }
    
    func didRequestAnalysis() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getImageAnalystRain",
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"1",
                                                    "host":self], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            if result.getValueFromKey("ERR_CODE") != "0" {
                self.showToast(response?.dictionize().getValueFromKey("ERR_MSG"), andPos: 0)
                return
            }
            
            self.imageData.addEntries(from: response?.dictionize()["RESULT"] as! [AnyHashable : Any])
            
            self.downloadImages(imageUrls: [self.imageData.getValueFromKey("rain24h") as! String, self.imageData.getValueFromKey("rain12h") as! String, ((self.imageData.getValueFromKey("rain1h") as! NSString).components(separatedBy: ",")).last as! String], isDayList: true)
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
//        for imageView in listImageView {
//            (imageView as! ImageScrollView).refresh()
//        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
            self.playWidth.constant = pageIndex == 2 ? 44 : 0
            self.play.backgroundColor = pageIndex == 2 ? AVHexColor.color(withHexString: "#0099FF") : UIColor.clear
            for el in [self.day, self.halfDay, self.hour] {
                if (el as! UILabel).tag == Int(pageIndex) {
                    (el as! UILabel).backgroundColor = AVHexColor.color(withHexString: "#0099FF")
                } else {
                    (el as! UILabel).backgroundColor = UIColor.clear
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        self.playWidth.constant = pageIndex == 2 ? 44 : 0
        self.play.backgroundColor = pageIndex == 2 ? AVHexColor.color(withHexString: "#0099FF") : UIColor.clear
        for el in [self.day, self.halfDay, self.hour] {
            if (el as! UILabel).tag == Int(pageIndex) {
                (el as! UILabel).backgroundColor = AVHexColor.color(withHexString: "#0099FF")
            } else {
                (el as! UILabel).backgroundColor = UIColor.clear
            }
        }
    }
    
    func setupSlideScrollView(slides: NSArray) {
//        imageScrollView.setup()
//        let myImage = UIImage(named: "my_image_name")
//        imageScrollView.display(image: myImage)
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(slides.count), height: scrollView.frame.size.height)
        scrollView.isPagingEnabled = true
        scrollView.backgroundColor = UIColor.white
        for i in 0 ..< slides.count {
//            let imageView = UIImageView.init()
//            imageView.frame = CGRect.init(x: CGFloat(self.screenWidth()) * CGFloat(i), y: CGFloat(0), width: CGFloat(self.screenWidth()), height: CGFloat(scrollView.frame.size.height))
//
//            imageView.contentMode = .scaleAspectFit
            let imageView = ImageScrollView.init()
            imageView.frame = CGRect.init(x: CGFloat(self.screenWidth()) * CGFloat(i), y: CGFloat(0), width: CGFloat(self.screenWidth()), height: CGFloat(scrollView.frame.size.height))
            for dict in slides {
                if (dict as! NSDictionary).getValueFromKey("index") == String(i) {
//                    imageView.image = (dict as! NSDictionary)["img"] is NSNull ? UIImage(named:"bg_no_image") : ((dict as! NSDictionary)["img"] as! UIImage)
                    imageView.display(image: ((dict as! NSDictionary)["img"] is NSNull ? UIImage(named:"bg_no_image") : ((dict as! NSDictionary)["img"] as! UIImage))!)
                }
            }
            scrollView.addSubview(imageView)
            listImageView.add(imageView)
        }
    }
    
    func downloadImages (imageUrls: NSArray, isDayList: Bool) {
        self.loadingBg.alpha = 1;
        back.isHidden = true
        self.loadingBg.isUserInteractionEnabled = false
        for imageUrl in imageUrls {
            SDWebImageManager().imageDownloader?.downloadImage(with: URL(string: imageUrl as! String), options: .highPriority, progress: {
                (receivedSize, expectedSize, url) in
            }, completed: { (downloadedImage, data, error, success) in
                if isDayList {
                    self.listDay.add(["img": !success ? UIImage(named: "bg_no_image") : downloadedImage, "index": imageUrls.index(of: imageUrl)])
                    if self.listDay.count >= imageUrls.count {
                        self.loadingBg.alpha = 0;
                        self.back.isHidden = false
                        self.loadingBg.isUserInteractionEnabled = true
                        self.timeStart(isShow: true)
                        self.pageControl.currentPage = 0
                        self.pageControl.numberOfPages = imageUrls.count
                        self.setupSlideScrollView(slides: self.listDay)
                    }
                } else {
                    self.listHour.add(["img": !success ? UIImage(named: "bg_no_image") : downloadedImage, "index": imageUrls.index(of: imageUrl)])
                    if self.listHour.count >= imageUrls.count {
                        self.loadingBg.alpha = 0;
                        self.back.isHidden = false
                        self.loadingBg.isUserInteractionEnabled = true
                        self.pageControl.currentPage = 0
                        self.imageIndex = 0
                        self.pageControl.numberOfPages = imageUrls.count
                        self.scrollView.isHidden = true
                        self.imageView.isHidden = false
                        self.isHourShow = true
                        self.timeHourStart(isShow: true)
                    }
                    if imageUrls.index(of: imageUrl) == 0 {
                        self.imageView.image = downloadedImage
                    }
                }
            })
        }
    }
    
    @IBAction func didPressHour() {
        if !isHourShow {
            if listHour.count == 0 {
                self.loadingBg.alpha = 1;
                self.loadingBg.isUserInteractionEnabled = false
                self.downloadImages(imageUrls: (self.imageData.getValueFromKey("rain1h") as! NSString).components(separatedBy: ",") as NSArray, isDayList: false)
                play.setImage(UIImage(named: !isHourShow ? "ic_pause" : "ic_play_video"), for: .normal)
                return
            }
            self.pageControl.numberOfPages = listHour.count
            if imageIndex == listHour.count - 1 {
                imageIndex = 0
            }
            pageControl.currentPage = imageIndex
            imageView.image = self.getImageHour(index: imageIndex)
            scrollView.isHidden = !isHourShow
            imageView.isHidden = isHourShow
        }
        self.timeHourStart(isShow: !isHourShow)
        play.setImage(UIImage(named: !isHourShow ? "ic_pause" : "ic_play_video"), for: .normal)
        isHourShow = !isHourShow
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func update() {
        UIView.animate(withDuration: 0.3) {
            self.bottomBar.alpha = 0
            self.bottomBarBG.alpha = 0
        }
        self.timeStart(isShow: false)
    }
    
    @objc func updateHourImage() {
        if imageIndex > listHour.count - 1 {
            imageIndex = listHour.count - 1
            self.timeHourStart(isShow: false)
            play.setImage(UIImage(named: "ic_play_video"), for: .normal)
            isHourShow = false
            self.timeStart(isShow: true)
            return
        }
        pageControl.currentPage = imageIndex
        UIView.transition(with: self.imageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.imageView.imageWithFade = self.getImageHour(index: self.imageIndex)
        }) { (done) in
            
        }
//        imageView.imageWithFade = self.getImageHour(index: imageIndex)
//        imageView.layer.add(CATransition(), forKey: kCATransition)
        imageIndex += 1
    }
}

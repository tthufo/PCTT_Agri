//
//  Marcro.swift
//  InformationCollector
//
//  Created by thanhhaitran on 5/10/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

import Foundation

import SDWebImage

import JSONKit_NoWarning

let screenWidth = UIScreen.main.bounds.size.width

let screenHeight = UIScreen.main.bounds.size.height

let IS_IPHONE_4 = screenHeight < 568.0

let IS_IPHONE_5 = screenHeight == 568.0

let IS_IPHONE_6 = screenHeight == 667.0

let IS_IPHONE_6P = screenHeight == 736.0

let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad

func IS_IPHONE_X () -> Bool {
    var iphoneX = false
    if #available(iOS 11.0, *) {
        if ((UIApplication.shared.keyWindow?.safeAreaInsets.top)! > CGFloat(0.0)) {
            iphoneX = true
        }
    }
    return iphoneX
}

func iOS_VERSION_EQUAL_TO(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version, options: NSString.CompareOptions.numeric) == ComparisonResult.orderedSame
}

func iOS_VERSION_GREATER_THAN(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version, options: NSString.CompareOptions.numeric) == ComparisonResult.orderedDescending
}

func iOS_VERSION_GREATER_THAN_OR_EQUAL_TO(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version, options: NSString.CompareOptions.numeric) != ComparisonResult.orderedAscending
}

func iOS_VERSION_LESS_THAN(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version, options: NSString.CompareOptions.numeric) == ComparisonResult.orderedAscending
}

func iOS_VERSION_LESS_THAN_OR_EQUAL_TO(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version, options: NSString.CompareOptions.numeric) != ComparisonResult.orderedDescending
}

func root() -> UIViewController {
    let root: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    return (root.window?.rootViewController)!
}



//func tabbar() -> TG_Root_ViewController {
//    return (root() as! UINavigationController).viewControllers.first as! TG_Root_ViewController
//}
//
//func user() -> TG_User_ViewController {
//    return ((root() as! UINavigationController).viewControllers.first as! TG_Root_ViewController).viewControllers?.last as! TG_User_ViewController
//}
//
//func logged() -> Bool {
//    return Information.token != nil
//}
//
//func INFO() -> NSDictionary {
//    return Information.userInfo!
//}

extension String {
    func replace(target: String, withString: String) -> String {
        return self.replace(target:target, withString:withString)
    }
}

extension String {
    
    func format(parameters: CVarArg...) -> String {
        return String(format: self, arguments: parameters)
    }
    
    func stringImage() -> UIImage {
        let dataDecoded:NSData = NSData(base64Encoded: self, options: NSData.Base64DecodingOptions(rawValue: 0))!
        let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
        return decodedimage
    }
    
    func urlGet(postFix: String) -> String {
        let host = root().infoPlist()["host"]
        return "%@/%@".format(parameters:host as! String, postFix)
    }
    
    func dictionize() -> NSDictionary {
        return (self as NSString).objectFromJSONString() as! NSDictionary
    }
}

extension UIImage {
//    func imageString() -> String {
//        return (UIImageJPEGRepresentation(self,0.1)?.base64EncodedString(options: .endLineWithLineFeed))!
//    }
//
    func fullImageString() -> String {
        let data: Data? = self.jpegData(compressionQuality: 1)
        return (data?.base64EncodedString(options: .endLineWithLineFeed))!
    }
}

extension UIImageView {
    var imageWithFade: UIImage? {
        get{
            return self.image
        }
        set{
            UIView.transition(with: self,
                              duration: 1, options: .transitionCrossDissolve, animations: {
                                self.image = newValue
            }, completion: nil)
        }
    }
    
    func imageUrl (url: String) {
        self.sd_setImage(with: NSURL.init(string: (url as NSString).encodeUrl())! as URL, placeholderImage: UIImage.init(named: "demo_bg")) { (image, error, cacheType, url) in
            if error != nil {
                return
            }
            
            if ((image != nil) && cacheType == .none)
            {
                UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    self.image = image
                }, completion: nil)
            }
        }
    }
    
    func imageUrlNoCache (url: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            SDWebImageManager.shared().loadImage(with: NSURL.init(string: (url as NSString).encodeUrl())! as URL, options: .continueInBackground, progress: { (progress, current, url) in
            }) { (img, data, error, cacheType, isDone, url) in
                if error != nil {
                    return
                }
                self.alpha = 0.3
                self.addValue(img?.fullImageString(), andKey: "bbgg")
                Information.saveBG()
                UIView.transition(with: self, duration: 1.5, options: .transitionCrossDissolve, animations: { () -> Void in
                    self.image = img
                    self.alpha = 1
                }, completion: {(done) in
                   }
                )
            }
        })
    }
    
    func imageUrlNoCacheNoSave (url: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            SDWebImageManager.shared().loadImage(with: NSURL.init(string: (url as NSString).encodeUrl())! as URL, options: .continueInBackground, progress: { (progress, current, url) in
            }) { (img, data, error, cacheType, isDone, url) in
                if error != nil {
                    return
                }
                self.alpha = 0.3
                UIView.transition(with: self, duration: 1.0, options: .transitionCrossDissolve, animations: { () -> Void in
                    self.image = img
                    self.alpha = 1
                }, completion: {(done) in
                }
                )
            }
        })
    }
    
    func imageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}

extension Date {
    func dateComp(type: Int) -> String {
        let calendar = Calendar.current
        let time = calendar.dateComponents([.month, .weekday, .day], from: self)
        return "%i".format(parameters: (type == 0 ? time.day : type == 1 ? time.weekday : time.month)!)
    }
}

extension UIView {
    func topRadius() {
        if #available(iOS 11.0, *){
            self.clipsToBounds = false
            self.layer.cornerRadius = 8
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }else{
            let rectShape = CAShapeLayer()
            rectShape.bounds = self.frame
            rectShape.position = self.center
            rectShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 8, height: 8)).cgPath
            self.layer.mask = rectShape
        }
    }
    
    func image() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    var heightConstaint: NSLayoutConstraint? {
        get {
            return constraints.first(where: {
                $0.firstAttribute == .height && $0.relation == .equal
            })
        }
        set { setNeedsLayout() }
    }
    
    var widthConstaint: NSLayoutConstraint? {
        get {
            return constraints.first(where: {
                $0.firstAttribute == .width && $0.relation == .equal
            })
        }
        set { setNeedsLayout() }
    }
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint.init(x:(labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                               y:(labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint.init(x:locationOfTouchInLabel.x - textContainerOffset.x,
                                                          y:locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}

extension String {
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}

extension UISearchBar {
    
    func getTextField() -> UITextField? { return value(forKey: "searchField") as? UITextField }
    
    func setClearButton(color: UIColor) {
        getTextField()?.setClearButton(color: color)
    }
}

extension UITextField {
    func modifyClearButtonWithImage(image : UIImage) {
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(image, for: .normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        clearButton.contentMode = .scaleAspectFit
        clearButton.addTarget(self, action: #selector(self.clear(sender:)), for: .touchUpInside)
        self.rightView = clearButton
        self.rightViewMode = .unlessEditing
    }
    
    @objc func clear(sender : AnyObject) {
        self.text = ""
    }
    
    private class ClearButtonImage {
        static private var _image: UIImage?
        static private var semaphore = DispatchSemaphore(value: 1)
        static func getImage(closure: @escaping (UIImage?)->()) {
            DispatchQueue.global(qos: .userInteractive).async {
                semaphore.wait()
                DispatchQueue.main.async {
                    if let image = _image { closure(image); semaphore.signal(); return }
                    guard let window = UIApplication.shared.windows.first else { semaphore.signal(); return }
                    let searchBar = UISearchBar(frame: CGRect(x: 0, y: -200, width: UIScreen.main.bounds.width, height: 44))
                    window.rootViewController?.view.addSubview(searchBar)
                    searchBar.text = "txt"
                    searchBar.layoutIfNeeded()
                    _image = UIImage(named: "icon_close") // searchBar.getTextField()?.getClearButton()?.image(for: .normal)
                    closure(_image)
                    searchBar.removeFromSuperview()
                    semaphore.signal()
                }
            }
        }
    }
    
    func setClearButton(color: UIColor) {
        ClearButtonImage.getImage { [weak self] image in
            guard   let image = image,
                let button = self?.getClearButton() else { return }
            button.imageView?.tintColor = color
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    func getClearButton() -> UIButton? { return value(forKey: "clearButton") as? UIButton }
}

extension UIViewController {
    
    var isModal: Bool {
        
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
}

extension UITableView {
    func scrollToBottom(animated: Bool = true, scrollPostion: UITableView.ScrollPosition = .top) {
        let no = self.numberOfRows(inSection: 0)
        if no > 0 {
            let index = IndexPath(row: 0, section: 0)
            scrollToRow(at: index, at: scrollPostion, animated: animated)
        }
    }
}

//
//  Information.swift
//  TourGuide
//
//  Created by Mac on 8/18/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class Information: NSObject {
    @objc static var token: String?
    
    @objc static var bg: String?
    
    @objc static var bbgg: String?
    
    static var userInfo: NSDictionary?
    
    static var log: NSDictionary?
    
    static func saveToken() {
        if self.getValue("token") != nil {
            token = "Bearer %@".format(parameters: self.getValue("token"))
        } else {
            token = nil
        }
    }
    
    static func saveBG() {
        if self.getValue("bg") != nil {
            bg = self.getValue("bg")
        } else {
            bg = nil
        }
        if self.getValue("bbgg") != nil {
            bbgg = self.getValue("bbgg")
        } else {
            bbgg = nil
        }
    }
    
    static func changeInfo(notification: Int) {
        if self.getObject("info") != nil {
            userInfo = self.getObject("info")! as NSDictionary
            let temp = userInfo?.reFormat()
            temp!["count_notification"] = notification >= 0 ? notification : Int((temp?.getValueFromKey("count_notification"))!)! - 1
            self.add((temp as! [AnyHashable : Any]), andKey: "info")
            userInfo = self.getObject("info")! as NSDictionary
        }
    }
    
    static func saveInfo() {
        if self.getObject("info") != nil {
            userInfo = self.getObject("info")! as NSDictionary
        } else {
            userInfo = nil
        }
        
        if self.getObject("log") != nil {
            log = self.getObject("log")! as NSDictionary
        } else {
            log = nil
        }
    }
    
    static func removeInfo() {
        
        self.removeValue("token")

        token = nil
        
        self.remove("info")

        userInfo = nil
        
        self.remove("log")
        
        log = nil
        
        self.remove("bg")
        
        bg = nil
    }
}

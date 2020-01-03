//
//  PC_Login_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/3/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit
import MarqueeLabel

class PC_Login_ViewController: UIViewController, UITextFieldDelegate {
 
    @IBOutlet var logo: UIImageView!
    
    @IBOutlet var bg: UIImageView!
    
    @IBOutlet var login: UIView!
    
    @IBOutlet var cover: UIView!

    @IBOutlet var uName: UITextField!
    
    @IBOutlet var pass: UITextField!

    @IBOutlet var check: UIButton!
    
    @IBOutlet var submit: UIButton!
    
    @IBOutlet var uNameErr: UILabel!

    @IBOutlet var passErr: UILabel!
    
    @IBOutlet var bottom: MarqueeLabel!

    var isCheck: Bool!
    
    var kb: KeyBoard!
    
    let bottomGap = IS_IPHONE_5 ? 20.0 : 40.0

    let topGap = IS_IPHONE_5 ? 80 : 120

    override func viewDidLoad() {
        super.viewDidLoad()

        kb = KeyBoard.shareInstance()

        isCheck = false
        
        self.setUp()
        
        self.view.action(forTouch: [:]) { (obj) in
            self.view.endEditing(true)
        }
        uName.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
        pass.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
        
        FirePush.shareInstance()?.completion({ (state, info) in
            print(info)
        })
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        bottom.text = "Weather Book © 2019 - Ver %@ - Hotline 0917271595".format(parameters: appVersion!)
        
        submit.withShadow()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        uName.text = ""
        
        pass.text = ""
        
        self.submit.isEnabled = self.uName.text?.count != 0 && self.pass.text?.count != 0
        self.submit.alpha = self.uName.text?.count != 0 && self.pass.text?.count != 0 ? 1 : 0.5
        
        kb.keyboardOff()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        kb.keyboard { (height, isOn) in
            UIView.animate(withDuration: 1, animations: {
                var frame = self.login.frame
                
                frame.origin.y -= isOn ? (height - CGFloat(self.bottomGap)) : (-height + CGFloat(self.bottomGap))
               
                self.login.frame = frame
                
                var frameLogo  = self.logo.frame
                
                frameLogo.origin.y -= isOn ? (height - CGFloat(self.bottomGap)) : (-height + CGFloat(self.bottomGap))
                
                self.logo.frame = frameLogo
            })
        }
    }
    
    func setUp() {
        let logged = Information.token != nil && Information.token != ""
        
        let bbgg = Information.bbgg != nil && Information.bbgg != ""
        
        var frame = logo.frame

        frame.origin.y = CGFloat(self.screenHeight() - 237) / 2

        frame.origin.x = CGFloat(self.screenWidth() - 250) / 2
        
        logo.frame = frame
        
        logo.alpha = 1
                
        UIView.animate(withDuration: 1, animations: {
            self.cover.alpha = bbgg ? 0.3 : 0
        }) { (done) in
            UIView.transition(with: self.bg, duration: 1, options: .transitionCrossDissolve, animations: {
                self.bg.image = bbgg ? Information.bbgg!.stringImage() : UIImage(named: "bg_default")
            }, completion: { (done) in
                UIView.animate(withDuration: 1, animations: {
                    self.cover.alpha = 0
                }) { (done) in
                    UIView.animate(withDuration: 0.5, animations: {
                        var frame = self.logo.frame
                        
                        frame.origin.y -= CGFloat((self.screenHeight()/2 - (237 * 0.7)) / 2) + (CGFloat(self.topGap) - 100) + (IS_IPHONE_5 ? 140 : 60)
                        
                        self.logo.frame = frame
                        
                        self.logo.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                        
                    }) { (done) in
                        if logged {
                            self.uName.text = Information.log!["name"] as? String
                            self.pass.text = Information.log!["pass"] as? String
                            self.submit.isEnabled = self.uName.text?.count != 0 && self.pass.text?.count != 0
                            self.submit.alpha = self.uName.text?.count != 0 && self.pass.text?.count != 0 ? 1 : 0.5
                            self.didPressSubmit()
                        }
                        self.setUpLogin()
                    }
                }
            })
        }
    }
    
    func setUpLogin() {
        var frame = login.frame
        
        frame.origin.y = CGFloat(self.screenHeight() - 363) / 2 + CGFloat(self.topGap)
        
        frame.size.width = CGFloat(self.screenWidth() - 10)
        
        frame.origin.x = 5

        login.frame = frame
        
        self.view.addSubview(login)
        
        UIView.animate(withDuration: 0.5, animations: {

            self.login.alpha = 1

        }) { (done) in
            
        }
    }
    
    @IBAction func didPressForget() {
        self.view.endEditing(true)
        self.navigationController?.pushViewController(PC_Forgot_ViewController.init(), animated: true)
    }
    
    @IBAction func didPressCheck() {
        pass.isSecureTextEntry = isCheck
        
        check.setImage(UIImage(named: isCheck ? "design_ic_visibility_off" : "design_ic_visibility"), for: .normal)
        
        isCheck = !isCheck
    }
    
    @IBAction func didPressSubmit() {
        self.view.endEditing(true)
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"login",
                                                    "username":uName.text as Any,
                                                    "password":pass.text as Any,
                                                    "device_id":FirePush.shareInstance()?.deviceToken() ?? "",
                                                    "platform":"IOS",
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"1",
                                                    "host":self], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            if result.getValueFromKey("ERR_CODE") != "0" {
                self.showToast(response?.dictionize().getValueFromKey("ERR_MSG"), andPos: 0)
                return
            }
            
            self.add(["name":self.uName.text as Any, "pass":self.pass.text as Any], andKey: "log")

            self.add((response?.dictionize()["RESULT"] as! NSDictionary).reFormat() as? [AnyHashable : Any], andKey: "info")

            Information.saveInfo()
            
            self.addValue((response?.dictionize()["RESULT"] as! NSDictionary).getValueFromKey("token"), andKey: "token")

            Information.saveToken()
            
            if Information.userInfo?.getValueFromKey("count_province") == "1" {
                self.navigationController?.pushViewController(PC_Station_ViewController.init(), animated: true)
            } else {
                self.navigationController?.pushViewController(PC_Main_ViewController.init(), animated: true)
            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == uName {
            pass.becomeFirstResponder()
        } else {
            self.view.endEditing(true)
        }
        
        return true
    }
    
    @objc func textIsChanging(_ textField:UITextField) {
        submit.isEnabled = uName.text?.count != 0 && pass.text?.count != 0
        submit.alpha = uName.text?.count != 0 && pass.text?.count != 0 ? 1 : 0.5
    }
}

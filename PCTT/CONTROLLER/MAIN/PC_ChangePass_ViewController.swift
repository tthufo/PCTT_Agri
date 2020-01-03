//
//  PC_ChangePass_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/4/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit

import MarqueeLabel

class PC_ChangePass_ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var bg: UIImageView!
    
    @IBOutlet var cover: UIView!
    
    @IBOutlet var reNewBg: UIView!
    
    @IBOutlet var titleLabel: MarqueeLabel!

    var kb: KeyBoard!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var cell1: UITableViewCell!
    
    @IBOutlet var cell2: UITableViewCell!

    @IBOutlet var cell3: UITableViewCell!
    
    @IBOutlet var oldPass: UITextField!
    
    @IBOutlet var newPass: UITextField!
    
    @IBOutlet var reNewPass: UITextField!
    
    @IBOutlet var submit: UIButton!
    
    @IBOutlet var oldPassErr: UILabel!
    
    @IBOutlet var newPassErr: UILabel!
    
    @IBOutlet var reNewPassErr: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        kb = KeyBoard.shareInstance()
        
        tableView.action(forTouch: [:]) { (obj) in
            self.view.endEditing(true)
        }
        
        if Information.bg != nil && Information.bg != "" {
            bg.imageUrlNoCache(url: Information.bg ?? "")
        }
        
        oldPass.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
        newPass.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
        reNewPass.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
        
        submit.withShadow()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        kb.keyboardOff()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        kb.keyboard { (height, isOn) in
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: isOn ? (height - 0) : 0, right: 0)
        }
    }
    
    @IBAction func didPressBack() {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressCheck(sender: UIButton) {
        let tag = sender.tag

        let fields = [oldPass, newPass, reNewPass]

        let check = sender.currentImage == UIImage(named: "design_ic_visibility_off")
        (fields[tag - 1])!.isSecureTextEntry = !check
        sender.setImage(UIImage(named: !check ? "design_ic_visibility_off" : "design_ic_visibility"), for: .normal)
    }
    
    @IBAction func didPressSubmit() {
        self.view.endEditing(true)
        
        if (newPass.text != reNewPass.text) {
            reNewBg.backgroundColor = UIColor.red
            reNewPassErr.alpha = 1
            return
        }
        
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"changePassword",
                                                    "user_id":Information.userInfo?.getValueFromKey("user_id") ?? "",               "old_password":oldPass.text as Any,
                                                    "new_password":newPass.text as Any,
                                                    "overrideLoading":"1",
                                                    "overrideAlert":"1",
                                                    "host":self], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            if result.getValueFromKey("ERR_CODE") != "0" {
                self.showToast(response?.dictionize().getValueFromKey("ERR_MSG"), andPos: 0)
                return
            }
            
            self.showToast("Mật khẩu mới sẽ được gửi qua số điện thoại", andPos: 0)

            self.navigationController?.popViewController(animated: true)
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == oldPass {
            newPass.becomeFirstResponder()
        } else if textField == newPass {
            reNewPass.becomeFirstResponder()
        } else {
            self.view.endEditing(true)
        }
        
        return true
    }
    
    @objc func textIsChanging(_ textField:UITextField) {
        if (textField == reNewPass) {
            reNewBg.backgroundColor = UIColor.black
            reNewPassErr.alpha = 0
        }
        submit.isEnabled = oldPass.text?.count != 0 && newPass.text?.count != 0 && reNewPass.text?.count != 0
        submit.alpha = oldPass.text?.count != 0 && newPass.text?.count != 0 && reNewPass.text?.count != 0 ? 1 : 0.5
    }
}

extension PC_ChangePass_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 2 ? 191 : 122
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return indexPath.row == 0 ? cell1 : indexPath.row == 1 ? cell2 : cell3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

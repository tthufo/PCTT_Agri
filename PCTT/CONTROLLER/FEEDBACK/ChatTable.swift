//
//  ChatTable.swift
//  DynamicAccessoryViewChat
//
//  Created by MAC_MINI_6 on 06/06/18.
//  Copyright © 2018 MAC_MINI_6. All rights reserved.
//

import UIKit
import SkeletonView

class ChatTable: UITableView {
    
    var coverView: UIView? = nil
  
  lazy var inputAccessory: ChatAccessory = {
    let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 144)
    let inputAccessory = ChatAccessory(frame: rect)
    return inputAccessory
  }()

  override var inputAccessoryView: UIView? {
    return inputAccessory
  }
  
  override var canBecomeFirstResponder: Bool {
    return true
  }
  
  override func awakeFromNib() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector:  #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//    let f = self.convert(self.frame, to: self.parentViewController()?.parent?.view)
//    coverView = UIView.init(frame: CGRect.init(x: self.frame.origin.x, y: f.origin.y, width: self.frame.size.width, height: self.frame.size.height - 65))
//    coverView?.backgroundColor = UIColor.black
//    coverView?.alpha = 0.6
//    coverView?.isUserInteractionEnabled = false
//    coverView?.layer.cornerRadius = 6
//    coverView?.clipsToBounds = true
//    self.parentViewController()?.view.addSubview(coverView!)
//    self.addSubview(coverView!)
  }
  
  @objc func keyboardWillShow(_ notification: Notification) {
    if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      let keyboardRectangle = keyboardFrame.cgRectValue
      let keyboardHeight = keyboardRectangle.height
//      self.contentInset.top = keyboardHeight
      if keyboardHeight > 100 {
        scrollToBottom()
      }
    }
  }
  
  @objc func keyboardWillHide(_ notification: NSNotification) {
    if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      let keyboardRectangle = keyboardFrame.cgRectValue
      let keyboardHeight = keyboardRectangle.height
//      self.contentInset.top = keyboardHeight
    }
  }
}
//MARK:- Scroll to bottom function

//
//  TZYAlert.swift
//  TZYAlert
//
//  Created by 田子瑶 on 2017/4/10.
//  Copyright © 2017年 田子瑶. All rights reserved.
//

import Foundation
import UIKit

public class TZYAlert: NSObject {
    
    public enum Type {
        case OK, Cancel, Other
    }
    
    public enum Style {
        case Alert, ActionSheet
    }
    
    public class AlertItem: NSObject {
        var title = ""
        var type = Type.Cancel
        var tag = -1
        var action: AlertHandle?
    }
    
    public typealias AlertHandle = (AlertItem) -> ()
    
    private var key = "alertView"
    
    private var items = [AlertItem]()
    private var title: String?
    private var message: String?
    private var style: Style!
    
    init(title: String?, msg: String?, style: Style) {
        super.init()
        self.title = title
        self.message = msg
        self.style = style
    }
    
    public class func alert(withTitle title: String?, msg: String?) -> TZYAlert {
        return TZYAlert(title: title, msg: msg, style: .Alert)
    }
    
    public class func actionSheet(withTitle title: String?, msg: String?) -> TZYAlert {
        return TZYAlert(title: title, msg: msg, style: .ActionSheet)
    }
    
    public class func showMessage(title: String, msg: String) -> TZYAlert {
        let alert = TZYAlert(title: title, msg: msg, style: .Alert)
        alert.addButton(withTitle: "确定")
        alert.show()
        return alert
    }
    
    public class func showMessage(msg: String) -> TZYAlert {
        return showMessage("提示", msg: msg)
    }
    
    public func addButton(withTitle title: String) -> Int {
        let item = AlertItem()
        item.title = title
        item.action = { item in
            
        }
        item.type = .Other
        items.append(item)
        return items.indexOf(item)!
    }
    
    public func addButton(withTitle title: String, type: Type, handle: AlertHandle?) {
        let item = AlertItem()
        item.title = title
        item.action = handle
        item.type = type
        items.append(item)
        item.tag = items.indexOf(item)!
    }
    
    public func addCancelButton(withTitle title: String, handle: AlertHandle?) {
        addButton(withTitle: title, type: .Cancel, handle: handle)
    }
    
    public func addCommonButton(withTitle title: String, handle: AlertHandle?) {
        addButton(withTitle: title, type: .Other, handle: handle)
    }
    
    public func buttonTitleAt(index: Int) -> String {
        guard index >= 0 && index < items.count else {
            print(#file, #function, #line, "数组越界")
            return ""
        }
        return items[index].title
    }
    
    public func actions() -> [AlertItem] {
        return items
    }
    
    public func show() {
        if #available(iOS 8.0, *) {
            let preferredStyle: UIAlertControllerStyle = style == .Alert ? .Alert : .ActionSheet
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
            for item in items {
                let actionStyle: UIAlertActionStyle = item.type == .Cancel ? .Cancel : .Default
                let alertAction = UIAlertAction(title: item.title, style: actionStyle, handler: { (action) in
                    item.action?(item)
                })
                alertVC.addAction(alertAction)
            }
            dispatch_async(dispatch_get_main_queue(), { 
                self.topShowViewController()?.presentViewController(alertVC, animated: true, completion: nil)
            })
        }
        else {
            if style == .Alert {
                let alertView = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: nil)
                objc_setAssociatedObject(alertView, &key, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                for item in items {
                    if item.type == .Cancel {
                        alertView.cancelButtonIndex = addButton(withTitle: item.title)
                    }
                    else {
                        alertView.addButtonWithTitle(item.title)
                    }
                }
                dispatch_async(dispatch_get_main_queue(), {
                    alertView.show()
                })
            }
            else {
                let actionSheet = UIActionSheet(title: title, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
                for item in items {
                    if item.type == .Cancel {
                        actionSheet.cancelButtonIndex = addButton(withTitle: item.title)
                    }
                    else {
                        actionSheet.addButtonWithTitle(item.title)
                    }
                }
                dispatch_async(dispatch_get_main_queue(), {
                    guard let vc = self.topShowViewController() else {
                        return
                    }
                    actionSheet.showInView(vc.view)
                })
            }
        }
    }
    
    private func topShowViewController() -> UIViewController? {
        return topViewController(withRootViewController: UIApplication.sharedApplication().keyWindow?.rootViewController)
    }
    
    private func topViewController(withRootViewController rootVC: UIViewController?) -> UIViewController? {
        if rootVC is UITabBarController {
            return topViewController(withRootViewController: (rootVC as! UITabBarController).selectedViewController)
        }
        else if rootVC is UINavigationController {
            return topViewController(withRootViewController: (rootVC as! UINavigationController).visibleViewController)
        }
        else if rootVC?.presentedViewController != nil {
            return topViewController(withRootViewController: rootVC?.presentedViewController)
        }
        else {
            return rootVC
        }
    }
}

extension TZYAlert: UIAlertViewDelegate, UIActionSheetDelegate {
    
    public func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        let item = items[buttonIndex]
        item.action?(item)
    }
    
    public func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        let item = items[buttonIndex]
        item.action?(item)
    }
}
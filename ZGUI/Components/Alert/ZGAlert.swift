//
//  ZGAlert.swift
//  Pods
//
//  Created by zhaogang on 2017/8/25.
//
//

import UIKit

public typealias ZGAlertTapHandler = (Int) -> Void

public enum ZGAlertStyle : Int {
    case normal
    case remind   //带闹铃图片的
}

public class ZGAlert: NSObject {
    public static let alertWidth:CGFloat = 270
    public class func showNormalItem(_ item:ZGAlertItem, tapHandler:ZGAlertTapHandler? = nil) {
        guard let mainWindow = ZGUIUtil.getMainWindow() else {
            return
        }
        let backgroundView = UIView(frame: mainWindow.bounds)
        backgroundView.backgroundColor = UIColor.init(white: 0, alpha: 0.6)
        mainWindow.addSubview(backgroundView)
        
        let screenSize = UIScreen.main.bounds.size
        let width:CGFloat = alertWidth
        
        var frame:CGRect = CGRect.init(origin: .zero, size: screenSize)
        frame.size.width = width
        frame.origin.x = (screenSize.width - alertWidth) / 2
        
        var contentView:ZGAlertView!
        
        if item.title == nil {
            let alertView = ZGNormalNoTitleAlert(frame:frame)
            backgroundView.addSubview(alertView)
            contentView = alertView
        } else {
            let alertView = ZGNormalAlert(frame:frame)
            backgroundView.addSubview(alertView)
            contentView = alertView
        }
        
        //setItem从新计算高度
        contentView.setItem(item)
        
        frame.size.height = contentView.realHeight
        
        frame.origin.y = (screenSize.height - frame.height) / 2
        contentView.frame = frame
        
        contentView.tapHandler = { (buttonIndex) in
            backgroundView.removeFromSuperview()
            
            if let tapHandler = tapHandler {
                tapHandler(buttonIndex)
            }
        }
        
        contentView.transform = CGAffineTransform.init(scaleX: 0.2, y: 0.2)
        UIView.animate(withDuration: 0.2, animations: {
            contentView.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            contentView.alpha = 1
        })
    }
    
    public class func showRemindItem(_ item:ZGAlertItem, tapHandler:ZGAlertTapHandler? = nil) {
        guard let mainWindow = ZGUIUtil.getMainWindow() else {
            return
        }
        let backgroundView = UIView(frame: mainWindow.bounds)
        backgroundView.backgroundColor = UIColor.init(white: 0, alpha: 0.6)
        mainWindow.addSubview(backgroundView)
        
        let screenSize = UIScreen.main.bounds.size
        let width:CGFloat = alertWidth
        
        var frame:CGRect = CGRect.init(origin: .zero, size: screenSize)
        frame.size.width = width
        frame.origin.x = (screenSize.width - alertWidth) / 2
        
        var contentView:ZGAlertView!
        
        if item.title == nil {
            
            let alertView = ZGRemindNoTitleAlert(frame:frame)
            backgroundView.addSubview(alertView)
            contentView = alertView 
        } else {
            let alertView = ZGRemindAlert(frame:frame)
            backgroundView.addSubview(alertView)
            contentView = alertView
        }
        //setItem从新计算高度
        contentView.setItem(item)
        
        frame.size.height = contentView.realHeight
        
        frame.origin.y = (screenSize.height - frame.height) / 2
        contentView.frame = frame
        
        contentView.tapHandler = { (buttonIndex) in
            backgroundView.removeFromSuperview()
            
            if let tapHandler = tapHandler {
                tapHandler(buttonIndex)
            }
        }
        
        contentView.transform = CGAffineTransform.init(scaleX: 0.2, y: 0.2)
        UIView.animate(withDuration: 0.2, animations: {
            contentView.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            contentView.alpha = 1
        })
    }
    
    public class func show(style:ZGAlertStyle = .normal,
                           content:String? = nil,
                           title:String? = nil,
                           buttonTitles:String...,
        tapHandler:ZGAlertTapHandler? = nil) {
        
        
        let item = ZGAlertItem()
        item.title = title
        item.content = content
        
        var btnItems = [ZGAlertButtonItem]()
        var index:Int = -1
        let btnCount:Int = buttonTitles.count
        for buttonTitle in buttonTitles {
            index += 1
            let btnItem = ZGAlertButtonItem()
            btnItem.buttonTitle = buttonTitle
            btnItems.append(btnItem)
            if index < 1 && btnCount > 1 {
                btnItem.backgroundColor = UIColor.color(withHex: 0xffffff)
                btnItem.backgroundHighlightColor = UIColor.color(withHex: 0xeeeeee)
                btnItem.titleColor = UIColor.color(withHex: 0x333333)
            } else {
                btnItem.backgroundColor = UIColor.color(withHex: 0xe60044)
                btnItem.backgroundHighlightColor = UIColor.color(withHex: 0xc00039)
                btnItem.titleColor = UIColor.color(withHex: 0xffffff)
            }
        }
        
        item.buttonItems = btnItems
        
        if style == .normal {
            self.showNormalItem(item, tapHandler: tapHandler)
        } else {
            self.showRemindItem(item, tapHandler: tapHandler)
        }
    }
}

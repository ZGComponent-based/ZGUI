//
//  AlertDemoItem.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/8/28.
//

import UIKit
import ZGUI

class AlertDemoItem: ZGBaseUIItem {
    
    var titleLabel:NSAttributedString?
    var titleLabelFrame:CGRect = .zero
    
    var alertTitle:String?
    var content:String?
    var buttonCount:Int?
    var alertStyle:ZGAlertStyle?
    
    static var alertIndex:Int = 0
    
    func openAlertWindow() {
        guard let alertStyle = self.alertStyle, let buttonCount = self.buttonCount else {
            return
        }
        
        if buttonCount == 2 {
            self.show(style: alertStyle, content: self.content, title: self.alertTitle, buttonTitles: "按钮1", "按钮2") { (buttonIndex) in
                print("共两个按钮 buttonIndex: \(buttonIndex)")
            }
        } else {
            self.show(style: alertStyle, content: self.content, title: self.alertTitle, buttonTitles: "按钮") { (buttonIndex) in
                print("buttonIndex: \(buttonIndex)")
            }
        }
    }

    override func mapViewType() -> ZGCollectionViewCell.Type {
        return AlertDemoCell.self
    }
    
    func resetTile(_ title:String) {
        let text = "<font color='#6b6b6b' size='15'>\(title)</font>"
        self.titleLabel = ZGUILabelStyle.attributedStringOfHtmlText(text)
        if let attributedText = self.titleLabel {
            self.titleLabelFrame.size = attributedText.textSize(constrainedToSize: CGSize.init(width: Int.max, height: 100))
        }
        self.titleLabelFrame.origin.y = (self.size.height - self.titleLabelFrame.height) / 2
        self.titleLabelFrame.origin.x = 10
    }
    
    init(style:ZGAlertStyle,
                           content:String?,
                           title:String? = nil,
                           buttonCount:Int) {
        super.init()
        self.size.width = UIScreen.main.bounds.size.width
        self.size.height = 44
        
        AlertDemoItem.alertIndex += 1
        
        self.alertStyle = style
        self.content = content
        self.alertTitle = title
        self.buttonCount = buttonCount
        
        var text:String = ""
        
        if style == .normal {
            text += "普通弹窗"
        } else {
            text += "提醒弹窗"
        }
        
        if title != nil {
            text += "[有标题]"
        }
        
        text += "\(AlertDemoItem.alertIndex)"
        
        self.resetTile(text)
    }
    
    public func show(style:ZGAlertStyle = .normal,
                           content:String?,
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
            ZGAlert.showNormalItem(item, tapHandler: tapHandler)
        } else {
            item.remindIcon = "bundle://tip_push_alert_ring@2x.png"
            ZGAlert.showRemindItem(item, tapHandler: tapHandler)
        }
    }
}

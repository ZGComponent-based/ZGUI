//
//  ZGUILabelExtension.swift
//  Pods
//
//  Created by zhaogang on 2017/5/13.
//
//

import UIKit

import Foundation
import UIKit
import ZGCore

public extension UILabel {
    
    /// 采用html标签方式设置样式
    ///
    /// - parameter styleText: 取值如：`<font face='Helvetica' size='13' color='#E50F3C' line='u' >Hello world</font>`
    ///
    public func htmlStyleText(_ styleText:String?) {
        guard let htmlText = styleText else { 
            return
        }
        
        self.attributedText = ZGUILabelStyle.attributedStringOfHtmlText(htmlText)
    }
    
    public func differentFontAndColor(lable : UILabel, differentText : String, differentTextColor : UIColor? = nil,differentTextFont : UIFont? = nil) {
        
        guard let text = lable.text else{
            return
        }
        guard let differentTextColor = differentTextColor else {
            return
        }
        let attrstring:NSMutableAttributedString = NSMutableAttributedString(string:text)
        
        let str = NSString(string: text)
        
        let theRange = str.range(of: differentText)
        
        if differentTextColor != nil {
            attrstring.addAttribute(NSAttributedString.Key.foregroundColor, value: differentTextColor, range: theRange)
        }else{
            attrstring.addAttribute(NSAttributedString.Key.foregroundColor, value: lable.textColor, range: theRange)
        }
        
        if differentTextFont != nil {
            attrstring.addAttribute(NSAttributedString.Key.font, value: differentTextFont, range: theRange)
        }else{
            attrstring.addAttribute(NSAttributedString.Key.font, value: lable.font, range: theRange)
        }
        
        lable.attributedText = attrstring
    }
}

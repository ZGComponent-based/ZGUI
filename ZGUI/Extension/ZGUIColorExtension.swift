//
//  UIColorExtension.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/3/28.
//
//

import Foundation
import UIKit
import ZGCore

public extension UIColor {
    public class func color(withHex hexColor:Int, alpha: CGFloat = 1) -> UIColor {
        let red = CGFloat( (hexColor & 0xFF0000) >> 16 ) / 255.0;
        let green = CGFloat( (hexColor & 0xFF00) >> 8 ) / 255.0;
        let blue = CGFloat( (hexColor & 0xFF) ) / 255.0;
        return UIColor.init(red: red, green: green, blue: blue, alpha: alpha);
    }
    
    public class func colorOfHexText(_ hexText:String) -> UIColor {
        var hexString:String = hexText
        if hexText.hasPrefix("#") {
            let startIndex = hexText.index(hexText.startIndex, offsetBy: 1)
            hexString = hexText.substring(from: startIndex)
        }
        let colorHex:Int = hexString.hexValue()
        return UIColor.color(withHex: colorHex, alpha: 1)
    }
    
    static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, a: CGFloat = 1) -> UIColor {
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
    }
    
    static func randomColor() -> UIColor {
        let r = CGFloat(arc4random_uniform(256))
        
        let g = CGFloat(arc4random_uniform(256))
        
        let b = CGFloat(arc4random_uniform(256))
        
        return UIColor.rgb(r, g, b)
    }
}

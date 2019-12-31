//
//  ZGUIUtil.swift
//  Pods
//
//  Created by zhaogang on 2017/7/14.
//
//

import UIKit
import ZGCore

public class ZGUIUtil: NSObject {
    
    //只在tbbzui模块内使用的方法
    class func bundleForImage(_ imageName:String) -> String {
        return "bundle://ZGUI/\(imageName)"
    }
    
    //只在tbbzui模块内使用的方法
    class func bundleImage(_ imageName:String) -> UIImage? {
        let bundlePath = self.bundleForImage(imageName)
        return ZGImage(bundlePath)
    }
    
    public class func getMainWindow() -> UIView? {
        guard let  delegate = UIApplication.shared.delegate else {
            return nil
        }
        
        guard let pWin = delegate.window else {
            return nil
        }
        
        return pWin
    }
    
    public class func statusBarHeight() -> CGFloat {
        var height = UIApplication.shared.statusBarFrame.height
        if height < 1 {
            height = 20
            if self.safeBottomMargin() > 0 {
                height = 44
            }
        }
        
        return height
    }
    
    public class func navigationBarHeight() -> CGFloat {
        return self.statusBarHeight() + 44
    }
    
    public class func safeBottomMargin() -> CGFloat {
        guard let window = self.getMainWindow() else {
            return 0
        }
        if #available(iOS 11.0, *) {
            let contentFrame = window.safeAreaLayoutGuide.layoutFrame
            return window.bounds.height - contentFrame.origin.y - contentFrame.size.height
        }
        return 0
    }
}

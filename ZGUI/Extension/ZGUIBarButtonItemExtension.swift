//
//  ZGUIBarButtonItemExtension.swift
//  Pods
//
//  Created by zhaogang on 2017/9/7.
//
//

import Foundation
import ZGCore

private var badgeNumberKey: String = "badgeNumberKey"
private var showRedDotKey: String = "showRedDotKey"
private var userDataKey: String = "userDataKey"
private var orderValueKey: String = "orderValueKey"
private var imageUrlKey: String = "imageUrlKey"
private var efTitleNormal: String = "efTitleNormal"

public extension UIBarButtonItem {
    
    public var badgeNumber: Int?{
        get{
            if let obj = objc_getAssociatedObject(self, &badgeNumberKey) as? NSNumber{
                return obj.intValue
            }
            return nil
        }
        set{
            if let value = newValue {
                let num = NSNumber(value: value)
                objc_setAssociatedObject(self, &badgeNumberKey, num, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    public var showRedDot: Bool?{
        get{
            if let obj = objc_getAssociatedObject(self, &showRedDotKey) as? NSNumber{
                return obj.boolValue
            }
            return nil
        }
        set{
            if let value = newValue {
                let num = NSNumber(value: value)
                objc_setAssociatedObject(self, &showRedDotKey, num, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    public var userData: Any?{
        get{
            if let userData = objc_getAssociatedObject(self, &userDataKey) {
                return userData
            }
            return nil
        }
        set{
            objc_setAssociatedObject(self, &userDataKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    public var orderValue: Int?{
        get{
            if let obj = objc_getAssociatedObject(self, &orderValueKey) as? NSNumber{
                return obj.intValue
            }
            return nil
        }
        set{
            if let value = newValue {
                let num = NSNumber(value: value)
                objc_setAssociatedObject(self, &orderValueKey, num, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    public var imageUrl: String?{
        get{
            if let obj = objc_getAssociatedObject(self, &imageUrlKey) as? String {
                return obj
            }
            return nil
        }
        set{
            if let value = newValue {
                objc_setAssociatedObject(self, &imageUrlKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    public var attributedTitleNormal: NSAttributedString?{
        get{
            if let obj = objc_getAssociatedObject(self, &efTitleNormal) as? NSAttributedString {
                return obj
            }
            return nil
        }
        set{
            if let value = newValue {
                objc_setAssociatedObject(self, &efTitleNormal, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    //导航按钮样式设置方法
    static var button : UIButton?
    // 在分类里面添加构造函数，用便利构造函数
    // Swift 函数的参数可以给定一个默认值，外界可以不传这个参数，就使用默认值
    convenience init(imageName: String? = nil, highlightedImageName: String? = nil, title: String? = nil, target: AnyObject?,font : UIFont? = nil,titleColor : UIColor? = nil, action: Selector? = nil) {
        self.init()
        // 初始化一个按钮
        UIBarButtonItem.button = UIButton()
        if action != nil {
            UIBarButtonItem.button?.addTarget(target, action: action!, for: UIControl.Event.touchUpInside)
        }
        
        
        if imageName != nil {
            // 设置按钮的不同状态的图片
            UIBarButtonItem.button?.setImage(ZGUIUtil.bundleImage(imageName!), for: .normal)
            
        }
        
        if highlightedImageName != nil {
            UIBarButtonItem.button?.setImage(ZGUIUtil.bundleImage(highlightedImageName!), for: UIControl.State.highlighted)
        }
        
        // 如果外界传入标题，就设置标题
        if title != nil {
            UIBarButtonItem.button?.setTitle(title, for: UIControl.State())
            // 设置字体的大小颜色
            UIBarButtonItem.button?.titleLabel?.font = font
            UIBarButtonItem.button?.setTitleColor(titleColor, for: UIControl.State())
            UIBarButtonItem.button?.setTitleColor(titleColor, for: UIControl.State.highlighted)
        }
        
        // 设置按钮的大小
        UIBarButtonItem.button?.sizeToFit()
        // 将按钮设置成当前类的 customView
        customView = UIBarButtonItem.button
    }
}

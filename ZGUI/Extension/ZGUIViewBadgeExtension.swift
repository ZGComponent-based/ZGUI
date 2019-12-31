//
//  ZGUIViewBadgeExtension.swift
//  Pods
//
//  Created by zhaogang on 2017/5/12.
//
//

import Foundation

private var badgeBackgroundColorKey: String = "badgeBackgroundColorKey"
private var badgeTextColorKey: String = "badgeTextColorKey"
private var maxBadgeNumberKey: String = "maxBadgeNumberKey"
private var badgeOriginOffsetKey: String = "badgeCenterOffsetKey"
private var badgeKey: String = "badgeKey"
private var badgeFontKey: String = "badgeFontKey"
private var redDotWidthKey: String = "redDotWidthKey"
private var numberWidthKey: String = "numberWidthKey"

private var defaultMaxBadgeNumber: Int = 99
private var defaultRedDotWidth: CGFloat = 5
private var defaultNumberWidth: CGFloat = 15

public enum ZGBadgeStyle: Int {
    case redDot = 7890
    case number = 7891
}

public extension UIView{
    
    public func showBadge(_ style: ZGBadgeStyle, value: Int){
        switch style {
        case .number:
            showNumberBadge(value)
        case .redDot:
            showRedDotBadge()
        }
    }
    
    public func getBadgeFrame() -> CGRect {
        return self.badge.frame
    }
    
    public func resetBadgeFrame(_ frame:CGRect) {
        self.badge.frame = frame
    }
    
    public func showStyleTextBadge(_ styleText:String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        guard let attributedText = ZGUILabelStyle.attributedStringOfHtmlText(styleText, paragraphStyle: paragraphStyle) else {
            return
        }
        let tag = ZGBadgeStyle.redDot.rawValue
        
        var retFrame = CGRect.zero
        retFrame.size = attributedText.textSize(constrainedToSize: CGSize.init(width: Int.max, height: 100))
        retFrame.size.width += 8
        retFrame.size.height += 4
        self.badge.frame = retFrame
        self.badge.attributedText = attributedText
        self.badge.tag = tag
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        self.badge.layer.cornerRadius = self.badge.frame.height / 2.0
        self.badge.layer.masksToBounds = true
        CATransaction.commit()
        
        self.badge.isHidden = false
        self.bringSubviewToFront(self.badge)
    }
    
    private func showRedDotBadge() {
        let tag = ZGBadgeStyle.redDot.rawValue
        let width = CGFloat(self.badgeRedDotWidth)
        self.badge.frame = CGRect(x: self.width - width + self.badgeOriginOffset.x, y: self.badgeOriginOffset.y, width: width, height: width)
        self.badge.text = ""
        self.badge.tag = tag
        self.badge.layer.cornerRadius = self.badge.frame.width / 2.0
        self.badge.layer.masksToBounds = true
        self.badge.isHidden = false
        self.bringSubviewToFront(self.badge)
    }
    
    private func showNumberBadge(_ value: Int) {
        if value < 0 {
            return
        }
        let width = CGFloat(self.badgeNumberWidth)
        
        let tag = ZGBadgeStyle.number.rawValue
        self.badge.isHidden = (value == 0)
        if value == 0{
            return
        }
        self.badge.tag = tag
        
        self.badge.text = value > self.maxBadgeNumber ? "\(self.maxBadgeNumber)+" : "\(value)"
        self.badge.isHidden = false
        
        var rect = self.badge.frame
        rect.size.width = width
        rect.size.height = width
        rect.origin.y = self.badgeOriginOffset.y
        
        self.badge.font = self.badgeTextFont
        if let text = self.badge.text {
            let count = String.init(text).count
            if count > 1{
                self.badge.font =  UIFont.boldSystemFont(ofSize: 8)
            }
            if count > 2{
                rect.size.width += 3
            }
        }
        rect.origin.x = self.width - rect.size.width + self.badgeOriginOffset.x
        self.badge.frame = rect
        
        self.badge.layer.cornerRadius = self.badge.frame.height / 2.0
        self.badge.layer.masksToBounds = true
    }
    
    public func clearBadge(){
        self.badge.isHidden = true
    }
    
    public func resumeBadge(){
        if self.badge.isHidden {
            self.badge.isHidden = false
        }
    }
    
    private func initBadge() -> UILabel{
        let width: CGFloat = CGFloat(self.badgeRedDotWidth)
        let frame = CGRect(x: self.width - width, y: 0, width: width, height: width)
        let label = UILabel(frame: frame)
        label.textAlignment = .center
        label.backgroundColor = self.badgeBackgroundColor
        label.text = ""
        label.textColor = self.badgeTextColor
        label.font = self.badgeTextFont
        self.badge = label
        self.addSubview(label)
        self.bringSubviewToFront(label)
        return label
    }
    
    private var badge: UILabel{
        get{
            if let label = objc_getAssociatedObject(self, &badgeKey) as? UILabel{
                return label
            }
            return initBadge()
        }
        set{
            objc_setAssociatedObject(self, &badgeKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var badgeBackgroundColor: UIColor{
        get{
            if let color = objc_getAssociatedObject(self, &badgeBackgroundColorKey) as? UIColor{
                return color
            }
            return UIColor.colorOfHexText("#FF6279")
        }
        set{
            objc_setAssociatedObject(self, &badgeBackgroundColorKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var badgeTextColor: UIColor{
        get{
            if let color = objc_getAssociatedObject(self, &badgeTextColorKey) as? UIColor{
                return color
            }
            return UIColor.white
        }
        set{
            objc_setAssociatedObject(self, &badgeTextColorKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var maxBadgeNumber: Int{
        get{
            if let obj = objc_getAssociatedObject(self, &maxBadgeNumberKey) as? NSNumber{
                return obj.intValue
            }
            return defaultMaxBadgeNumber
        }
        set{
            let num = NSNumber(value: newValue)
            objc_setAssociatedObject(self, &maxBadgeNumberKey, num, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var badgeOriginOffset: CGPoint{
        get{
            if let dic = objc_getAssociatedObject(self, &badgeOriginOffsetKey) as? [String: Any]{
                if let x = dic["x"] as? CGFloat, let y = dic["y"]  as? CGFloat{
                    return CGPoint(x: x, y: y)
                }
            }
            return CGPoint.zero
        }
        set{
            let dic = ["x": newValue.x,"y": newValue.y]
            objc_setAssociatedObject(self, &badgeOriginOffsetKey, dic, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }
    
    public var badgeTextFont: UIFont{
        get {
            if let font = objc_getAssociatedObject(self, &badgeFontKey) as? UIFont{
                return font
            }
            return UIFont.boldSystemFont(ofSize: 10)
        }
        set {
            objc_setAssociatedObject(self, &badgeFontKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    public var badgeRedDotWidth: CGFloat {
        get{
            if let width = objc_getAssociatedObject(self, &redDotWidthKey) as? NSNumber{
                return CGFloat(width.doubleValue)
            }
            return defaultRedDotWidth
        }
        set{
            let width = NSNumber(value: Double(newValue))
            objc_setAssociatedObject(self, &redDotWidthKey, width, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            self.showRedDotBadge()
        }
    }
    
    public var badgeNumberWidth: CGFloat {
        get{
            if let width = objc_getAssociatedObject(self, &numberWidthKey) as? NSNumber{
                return CGFloat(width.doubleValue)
            }
            return defaultNumberWidth
        }
        set{
            let width = NSNumber(value: Double(newValue))
            objc_setAssociatedObject(self, &numberWidthKey, width, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

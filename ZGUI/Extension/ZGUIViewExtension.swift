//
//  ZGUIViewExtension.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/3/31.
//
//

import UIKit

public extension UIView {
    var left: CGFloat {
        set {
            var frame = self.frame;
            frame.origin.x = newValue;
            self.frame = frame;
        }
        get {
            return self.frame.origin.x;
        }
    }
    
    var top: CGFloat {
        set {
            var frame = self.frame;
            frame.origin.y = newValue;
            self.frame = frame;
        }
        get {
            return self.frame.origin.y;
        }
    }
    
    var right: CGFloat {
        set {
            var frame = self.frame;
            frame.origin.x = newValue - frame.width;
            self.frame = frame;
        }
        get {
            return self.frame.maxX;
        }
    }
    
    var bottom: CGFloat {
        set {
            var frame = self.frame;
            frame.origin.y = newValue - frame.height;
            self.frame = frame;
        }
        get {
            return self.frame.maxY;
        }
    }
    
    var width: CGFloat {
        set {
            var frame = self.frame;
            frame.size.width = newValue;
            self.frame = frame;
        }
        get {
            return self.frame.width;
        }
    }
    
    var height: CGFloat {
        set {
            var frame = self.frame;
            frame.size.height = newValue;
            self.frame = frame;
        }
        get {
            return self.frame.height;
        }
    }
    
    var centerX: CGFloat {
        set {
            self.center = CGPoint.init(x: newValue, y: self.center.y);
        }
        get {
            return self.center.x;
        }
    }
    
    var centerY: CGFloat {
        set {
            self.center = CGPoint.init(x: self.center.x, y: newValue);
        }
        get {
            return self.center.y;
        }
    }

    var boundsCenter : CGPoint {
        get {
            return CGPoint.init(x: self.frame.width/2, y: self.frame.height/2);
        }
    }
    
}

public extension UIView {
    public func removeAllSubviews() {
        while self.subviews.count > 0 {
            let child = self.subviews.last;
            child?.removeFromSuperview();
        }
    }
    
    public func removeAllSubLayer() {
        while (self.layer.sublayers?.count ?? 0) > 0 {
            let child = self.layer.sublayers?.last;
            child?.removeFromSuperlayer();
        }
    }
} 

public extension UIView {
    public func addCustomButton() -> UIButton {
        let label = UIButton(type:.custom)
        self.addSubview(label)
        return label
    }
    
    public func addUIImageView() -> UIImageView {
        let imageView = UIImageView()
        self.addSubview(imageView)
        imageView.backgroundColor = UIColor.clear
        return imageView
    }
    
    public func addCustomImageView() -> ZGImageView {
        let imageView = ZGImageView()
        self.addSubview(imageView)
        imageView.backgroundColor = UIColor.clear
        return imageView
    }
    
    public func addNormalLabel() -> UILabel {
        let label = UILabel()
        self.addSubview(label)
        label.numberOfLines = 0
        return label
    }
    
    public func addNormalLayer() -> CALayer {
        let layer1 = CALayer()
        self.layer.addSublayer(layer1)
        return layer1
    }
    
    public func addTextView() -> UITextView {
        let t1 = UITextView()
        self.addSubview(t1)
        return t1
    }
    
    public func addTextField() -> UITextField {
        let t1 = UITextField()
        self.addSubview(t1)
        return t1
    }
}

public extension UIView {
    public func showTextTip(_ text:String) {
        guard let window = self.mainWindow() else{
            return
        }
        ZGUIToastView.showInView(window, text: text)
    }
    
    func mainWindow() -> UIWindow? {
        if let window = UIApplication.shared.delegate?.window {
            return window
        }
        return nil
    }
    
    /// 用于登录、或有数据时的弹窗加载
    ///
    /// - parameter text: 提示文字
    /// - parameter isTransparent:  true:背景透明， false：不透明
    public func showPopUpLoading(_ text:String? = nil) {
        var centerRect = self.bounds
         ZGLoadingBox.showLoading(frame: centerRect, inView: self, tipString: text, popup: true)
    }
    
    public func hidePopupLoading() {
        ZGLoadingBox.hideLoading(self)
    }
    
    public func isPopupLoading() -> Bool {
        return ZGLoadingBox.isLoading(inView: self)
    }
    
    //截图
    public func snapshot(rect: CGRect = CGRect.zero, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        
        var snapRect = rect
        if  rect.size == .zero {
            snapRect = calculateSnapshotRect()
        }
        UIGraphicsBeginImageContextWithOptions(snapRect.size, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        self.drawHierarchy(in: snapRect, afterScreenUpdates: false)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    // 计算UIView所显示内容Rect
    func calculateSnapshotRect() -> CGRect {
        var targetRect = self.bounds
        if let scrollView = self as? UIScrollView {
            let contentInset = scrollView.contentInset
            let contentSize = scrollView.contentSize
            
            targetRect.origin.x = contentInset.left
            targetRect.origin.y = contentInset.top
            targetRect.size.width = targetRect.size.width  - contentInset.left - contentInset.right > contentSize.width ? targetRect.size.width  - contentInset.left - contentInset.right : contentSize.width
            targetRect.size.height = targetRect.size.height - contentInset.top - contentInset.bottom > contentSize.height ? targetRect.size.height  - contentInset.top - contentInset.bottom : contentSize.height
        }
        return targetRect
    }
    
    /// 部分圆角
    ///
    /// - Parameters:
    ///   - corners: 需要实现为圆角的角，可传入多个
    ///   - radii: 圆角半径
    func corner(byRoundingCorners corners: UIRectCorner, radii: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    //渐变
    func setGradientLayer(firstColor: UIColor, secondColor: UIColor) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        //        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        gradientLayer.cornerRadius = self.frame.size.height / 2
        
        return gradientLayer
    }
    
    //渐变
    func setGradient(firstColor: UIColor, secondColor: UIColor,corner:CGFloat){
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        gradientLayer.cornerRadius = corner
        self.layer.addSublayer(gradientLayer)
    }
    //渐变带方向
    func setAllGradient(firstColor: UIColor, secondColor: UIColor,corner:CGFloat,startPoint:CGPoint,endPoint:CGPoint){
        if let layers = self.layer.sublayers {
            for (index,value) in layers.enumerated() {
                if value is CAGradientLayer {
                    value.removeFromSuperlayer()
                    break
                }
            }
        }
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        gradientLayer.cornerRadius = corner
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
}


//
//  ZGCircleOverlayLoadingView.swift
//  ZGUIDemo
//

import Foundation
import UIKit
import ZGCore

enum ZGLoadingTag : Int {
    case TBLoadingActivityLabelTag = 103901
}

class ZGCircleLoadingView: UIView {
    // 主layer
    var shapeLayer:CAShapeLayer!
    // 圆形layer
    var layer1:CAShapeLayer!
    
    //创建上下两个渐变色
    var topColors:[CGColor] = [UIColor.colorOfHexText("#DCDCDC").cgColor, UIColor.colorOfHexText("#4c4c4c").cgColor]
    var bottomColors:[CGColor] = [UIColor.colorOfHexText("#DCDCDC").cgColor, UIColor.white.cgColor]
 
    func startAnimating()  {
        shapeLayer = CAShapeLayer()
        self.layer.addSublayer(shapeLayer)
        let borderWidth:CGFloat = 5
        
        // 考虑取比外边框小的一部分，避免圆环被切除
        let shapeRect = self.bounds
        shapeLayer.frame = shapeRect
        
        var topRect = shapeLayer.bounds
        topRect.size.height = topRect.height/2
        let topLayer = CAGradientLayer()
        topLayer.frame  = topRect
        topLayer.colors = topColors
        topLayer.startPoint = CGPoint.init(x:0, y:0.5)
        topLayer.endPoint   = CGPoint.init(x:1, y:0.5)
        shapeLayer.addSublayer(topLayer)
        
        let bottomLayer = CAGradientLayer()
        var bottomRect = topRect
        bottomRect.origin.y = topRect.height
        bottomLayer.frame  = bottomRect
        bottomLayer.colors = bottomColors
        bottomLayer.startPoint = CGPoint.init(x:0, y:0.5)
        bottomLayer.endPoint   = CGPoint.init(x:1, y:0.5)
        shapeLayer.addSublayer(bottomLayer)
        
        //如果不减去borderWidth，刚好会到个类似莲花的效果
        var radius = (shapeRect.width-borderWidth)/2
        
        // 创建一个圆形layer
        layer1 = CAShapeLayer()
        layer1.frame = shapeRect
        layer1.path = UIBezierPath(arcCenter: CGPoint.init(x: shapeRect.midX, y: shapeRect.midX),
                                   radius: radius,
                                   startAngle: CGFloat(Double.pi/30),
                                   endAngle: 2 * CGFloat(Double.pi) - CGFloat(Double.pi/30),
                                   clockwise: true).cgPath
        layer1.lineWidth    = borderWidth
        layer1.lineCap      = CAShapeLayerLineCap.round
        layer1.lineJoin     = CAShapeLayerLineJoin.round
        layer1.strokeColor  = UIColor.black.cgColor
        layer1.fillColor    = UIColor.clear.cgColor
        
        // 根据laery1 的layer形状在 shaperLayer 中截取出来一个layer
        shapeLayer.mask = layer1
        
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.toValue   =  2 * Double.pi
        animation.duration = 1.0
        animation.repeatCount = HUGE
        self.layer.add(animation, forKey: nil)
    }
    func stopAnimating() {
        self.layer.removeAllAnimations()
    }
    var isAnimating: Bool {
        return true
    }
}

open class ZGLoadingView: UIView {
    var activityIndicatorStyle:UIActivityIndicatorView.Style = .gray
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        self.addSubview(label)
        label.numberOfLines = 0
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var activityIndicatorView: ZGCircleLoadingView = {
//        let view1 = UIActivityIndicatorView(activityIndicatorStyle: self.activityIndicatorStyle)
        let view1 = ZGCircleLoadingView(frame:CGRect.init(x: 0, y: 0, width: 40, height: 40))
        self.addSubview(view1)
        return view1
    }()
    
    open func startAnimating() {
        self.activityIndicatorView.startAnimating()
    }
    
    open func stopAnimating() {
        self.activityIndicatorView.stopAnimating()
    }
    
    open var isAnimating: Bool {
        return self.activityIndicatorView.isAnimating
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        let vGap:CGFloat = 10
        var centerHeight:CGFloat = self.activityIndicatorView.height
        if self.titleLabel.height > 0 {
             centerHeight = centerHeight + self.titleLabel.height + vGap
        }
        let topY:CGFloat = (self.height - centerHeight) / 2
        
        var rect = self.activityIndicatorView.frame
        rect.origin.x = (self.width - rect.width) / 2
        rect.origin.y = topY
        self.activityIndicatorView.frame = rect
        
        if self.titleLabel.height > 1 {
            var labelRect = self.titleLabel.frame
            labelRect.origin.x = (self.width - labelRect.width) / 2
            labelRect.origin.y = rect.origin.y + rect.height + vGap
            self.titleLabel.frame = labelRect
        }
    }
}

public class ZGLoadingBox:UIView {
    public static var loadingTopColors = [UIColor.colorOfHexText("#DCDCDC").cgColor, UIColor.colorOfHexText("#4c4c4c").cgColor]
   public static var loadingBottomColors = [UIColor.colorOfHexText("#DCDCDC").cgColor, UIColor.white.cgColor]
 
    lazy var loadingView: ZGLoadingView = {
        let view1 = ZGLoadingView()
        self.addSubview(view1)
        return view1
    }()
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        var rect = self.loadingView.frame
        rect.size = CGSize.init(width: 110, height: 110)
        rect.origin.x = (self.width - rect.width) / 2
        rect.origin.y = (self.height - rect.height) / 2
        self.loadingView.frame = rect
    }
    
    public static func hideLoading(_ parentView:UIView) {
        let tag: Int = ZGLoadingTag.TBLoadingActivityLabelTag.rawValue
        let circleOverlayViewOpt = parentView.viewWithTag(tag)
        if let loadingBox = circleOverlayViewOpt as? ZGLoadingBox {
            loadingBox.loadingView.stopAnimating()
            loadingBox.removeFromSuperview()
        }
    }
    
    deinit {
        self.loadingView.stopAnimating()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func appWillEnterForeground() {
        self.loadingView.startAnimating()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public static func refreshLoading(inView:UIView) {
        let tag: Int = ZGLoadingTag.TBLoadingActivityLabelTag.rawValue
        if let loadingBox = inView.viewWithTag(tag) as? ZGLoadingBox {
            inView.bringSubviewToFront(loadingBox)
            loadingBox.loadingView.startAnimating()
        }
    }
    
    public static func isLoading(inView:UIView) -> Bool {
        let tag: Int = ZGLoadingTag.TBLoadingActivityLabelTag.rawValue
        return inView.viewWithTag(tag) != nil
    }
    
    @discardableResult
    public static func showLoading(frame:CGRect,
                                   inView:UIView,
                                   tipString:String? = nil,
                                   popup:Bool = false,
                                   backgroundColor:UIColor=UIColor.clear
                                   ) -> UIView {
        let tag: Int = ZGLoadingTag.TBLoadingActivityLabelTag.rawValue
        if let loadingBox = inView.viewWithTag(tag) {
            inView.bringSubviewToFront(loadingBox)
            return loadingBox
        }
        
        let lView = ZGLoadingBox(frame: frame)
        lView.backgroundColor = backgroundColor
        lView.tag = tag
        if popup {
            lView.loadingView.backgroundColor = UIColor.color(withHex: 0xf3f3f3)
            lView.loadingView.activityIndicatorStyle = .whiteLarge
        }
        inView.addSubview(lView)
        lView.loadingView.titleLabel.text = tipString
        lView.loadingView.titleLabel.sizeToFit()
        lView.loadingView.layer.cornerRadius = 10
        lView.loadingView.layer.masksToBounds = true
        lView.loadingView.activityIndicatorView.topColors = self.loadingTopColors
        lView.loadingView.activityIndicatorView.bottomColors = self.loadingBottomColors
        lView.loadingView.startAnimating()
        return lView
    }
    
}

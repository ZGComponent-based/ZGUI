//
//  ZGWaterDropPageControl.swift
//  Pods
//  迁移oc组件功能
//  Created by zhaogang on 2017/6/6.
//
//

import UIKit

class ZGWaterDropView: UIView {
    
    var radius:CGFloat = 2
    var _centerX:CGFloat = 0
    var _centerY:CGFloat = 0
    
    weak var shapeLayer:CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let layer1 = CAShapeLayer()
        layer1.fillColor = UIColor.clear.cgColor
        layer1.strokeColor = UIColor.clear.cgColor
        layer1.lineWidth = 0.1
        self.layer.addSublayer(layer1)
        self.shapeLayer = layer1
         
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetParameter() {
        radius = self.frame.size.width/2.0
        if radius == 0 {
            radius = 3
        }
        
        _centerX = self.bounds.size.width/2
        _centerY = self.bounds.size.height/2
    }
    
    func setCurrentOffset(_ currentOffset:CGFloat) {
        let isLeft:Bool = currentOffset <= 0
 
        let path:CGMutablePath = self.createPathWithOffset(currentOffset)
        shapeLayer.path = path
        
        let angle:CGFloat = (CGFloat.pi / 2)
        if isLeft {
            self.transform = CGAffineTransform(rotationAngle: -angle)
        } else {
            self.transform = CGAffineTransform(rotationAngle: angle)
        }
    }
    
    //创建普通的圆
    func createPathWithOffset(_ offset:CGFloat) -> CGMutablePath {
        var currentOffset = offset
        if currentOffset < 0 {
            currentOffset = -currentOffset
        }
        _centerX = self.bounds.size.width/2
        _centerY = self.bounds.size.height/2
        
        let path = CGMutablePath()
        var wdiff:CGFloat = currentOffset * 0.1
        
        let pX:CGFloat = _centerX - radius
        let pY:CGFloat = _centerY - radius
        let width:CGFloat = radius*2
        let rect = CGRect.init(x: pX, y: pY, width: width, height: width)
        path.addEllipse(in: rect)
        path.closeSubpath()
        
        return path;
    }
    
    //水滴效果的
    func createWaterPathWithOffset(_ offset:CGFloat) -> CGMutablePath {
        var currentOffset = offset
        if currentOffset < 0 {
            currentOffset = -currentOffset
        }
        _centerX = self.bounds.size.width/2
        _centerY = self.bounds.size.height/2
        
        let path = CGMutablePath()
        var wdiff:CGFloat = currentOffset * 0.1
        
        if currentOffset == 0 {
            let pX:CGFloat = _centerX - radius
            let pY:CGFloat = _centerY - radius
            let width:CGFloat = radius*2
            let rect = CGRect.init(x: pX, y: pY, width: width, height: width)
            path.addEllipse(in: rect)
        } else {
            let center = CGPoint.init(x: _centerX, y: _centerY)
            path.addArc(center: center, radius: radius, startAngle: 0, endAngle: CGFloat.pi, clockwise: true)
            let pRadius:CGFloat = radius*1.5
            if (wdiff > pRadius) {
                wdiff = pRadius
            }
            let bottom = _centerY + wdiff+radius;
            var toPoint = CGPoint.init(x: _centerX, y: bottom)
            var cPoint1 = CGPoint.init(x: _centerX - radius, y: bottom)
            var cPoint2 = CGPoint.init(x: _centerX, y: bottom)
            path.addCurve(to: toPoint, control1: cPoint1, control2: cPoint2)
            
            toPoint = CGPoint.init(x: _centerX+radius, y: _centerY)
            cPoint1 = CGPoint.init(x: _centerX , y: bottom)
            cPoint2 = CGPoint.init(x: _centerX+radius, y: bottom)
            path.addCurve(to: toPoint, control1: cPoint1, control2: cPoint2)
        }
        path.closeSubpath()
        
        return path;
    }
    
}

class ZGWaterDropPageControlDot : UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        let r:CGFloat = frame.size.width/2.0
        self.layer.masksToBounds = true
        self.layer.cornerRadius = r
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class ZGWaterDropPageControl: UIControl {
    public enum PageControlStyle:Int {
        case center = 0
        case left = 1
        case right = 2
    }
    var _numberOfPages:CGFloat = 0
    var numberOfPages:CGFloat  {
        get {
            return _numberOfPages
        }
        set {
            _numberOfPages = newValue
            self.createPageIndicatorDots()
        }
    }
    var _currentPage:CGFloat = 0
    var currentPage:CGFloat {
        get {
            return _currentPage
        }
        set {
            if _numberOfPages == 0 {
                return
            }
           _currentPage = newValue
            self.resetPageIndicatorTintColor()
            self.moveWaterDrop()
            self.waterDropView.setCurrentOffset(_currentPage)
        }
    }
    public var style:PageControlStyle = .center
    weak var waterDropView:ZGWaterDropView!
    
    var _pageIndicatorTintColor:UIColor? = UIColor.color(withHex: 0x9AC0CD)
    var _currentPageIndicatorTintColor:UIColor? = UIColor.color(withHex: 0x8E388E)
    
    public var dotPadding:CGFloat = 6
    public var pageIndicatorTintColor:UIColor? {
        get {
            return _pageIndicatorTintColor
        }
        set {
            _pageIndicatorTintColor = newValue
        }
    }
    
    func moveWaterDrop() {
        var frame = self.waterDropView.frame
        let offsetX = self.getDotOffsetX()
        let radius:CGFloat = self.waterDropView.radius
        let dotWidth:CGFloat = radius*2
        frame.origin.x = offsetX + (self.dotPadding+dotWidth)*_currentPage
        UIView.animate(withDuration: 0.2) {
            self.waterDropView.frame = frame
        }
    }
    
    func resetPageIndicatorTintColor()  {
        self.waterDropView.shapeLayer.fillColor = _currentPageIndicatorTintColor?.cgColor
        self.waterDropView.shapeLayer.strokeColor = _currentPageIndicatorTintColor?.cgColor
    }
    
    public var currentPageIndicatorTintColor:UIColor? {
        get {
            return _currentPageIndicatorTintColor
        }
        set {
            _currentPageIndicatorTintColor = newValue
            self.resetPageIndicatorTintColor()
        }
    }
    
    public required init(frame: CGRect, style:PageControlStyle = .center) {
        super.init(frame: frame)
        self.style = style
        let view1 = ZGWaterDropView()
        self.addSubview(view1)
        self.waterDropView = view1
        self.waterDropView.radius = 3.0
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getDotOffsetX() -> CGFloat {
        let width:CGFloat = self.frame.size.width
        let radius:CGFloat = self.waterDropView.radius
        let length:CGFloat = _numberOfPages*radius*2.0 + (_numberOfPages-1)*self.dotPadding
        
        var offsetX:CGFloat = (width-length)/2.0
        
        switch (style) {
        case .center:
            break
        case .left:
            offsetX = 10
            break
        case .right:
            offsetX = width-length-10
            break;
        }
        return offsetX
    }

    func createPageIndicatorDots() {
        let subArray = self.subviews
        
        for  subView in subArray {
            if subView is ZGWaterDropPageControlDot {
                subView.removeFromSuperview()
            }
        }
        self.waterDropView.isHidden = false
        if _numberOfPages <= 1 {
            self.waterDropView.isHidden = true
            return
        }
        self.waterDropView.resetParameter()
        let radius:CGFloat = self.waterDropView.radius
        let dotWidth:CGFloat = radius*2
        let offsetX:CGFloat = self.getDotOffsetX()
        let offsetY:CGFloat = self.frame.size.height - dotWidth
        let pageCount:Int = Int(_numberOfPages)
        for i in 0 ..< pageCount {
            let pX:CGFloat = offsetX + (self.dotPadding+dotWidth) * CGFloat(i)
            let pY:CGFloat = offsetY
            let rect = CGRect.init(x: pX, y: pY, width: dotWidth, height: dotWidth)
            let dot = ZGWaterDropPageControlDot(frame:rect)
            dot.backgroundColor = self.pageIndicatorTintColor;
            self.addSubview(dot)
        }

        self.waterDropView.frame = CGRect.init(x:offsetX, y:offsetY, width:dotWidth, height:dotWidth)
        self.bringSubviewToFront(self.waterDropView)
    }
    
    public func setCurrentPageAndMoveWaterDropWithoutAnimationToIndex(_ index:Int) {
        if _numberOfPages == 0 {
            return
        }
        _currentPage = CGFloat(index)
        
        self.resetPageIndicatorTintColor()
        
        var frame = self.waterDropView.frame;
        let offsetX = self.getDotOffsetX()
        let radius:CGFloat = self.waterDropView.radius
        let dotWidth:CGFloat = radius*2
        frame.origin.x = offsetX + (self.dotPadding+dotWidth)*_currentPage
        self.waterDropView.frame = frame
        
        self.waterDropView.setCurrentOffset(_currentPage)
    }
}

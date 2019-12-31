//
//  Corner.swift
//  cactus-teacher-ios
//
//  Created by zhaogang on 2018/4/9.
//

import UIKit

open class Corner {
    
    //MARK: - 对所有角整体切割
    open  class func DN_allCorner(_ currentView : UIView, radius : CGFloat, size : CGSize, currentViewBackGroundColor : UIColor? = nil, borderColor : UIColor? = nil, borderWidth : CGFloat? = nil){
        
        let maskPath:UIBezierPath = UIBezierPath.init(roundedRect: CGRect(x: 0, y: 0, width: size.width, height: size.height), byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize(width: radius, height: radius))
        
        let maskLayer:CAShapeLayer = CAShapeLayer.init()
        
        maskLayer.frame = currentView.bounds
        
        maskLayer.path = maskPath.cgPath
        
        currentView.layer.mask = maskLayer
        
    }
    
    //切角加边框
    open class func DN_addBorderCorner(_ currentView:UIView,radius: CGFloat,size: CGSize,backGroundColor:UIColor? = nil,borderColor:UIColor,borderWidth:CGFloat){
        
        let maskPath:UIBezierPath = UIBezierPath.init(roundedRect: CGRect(x: 0, y: 0, width: size.width, height: size.height), byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize(width: radius, height: radius))
        
        
        let maskLayer:CAShapeLayer = CAShapeLayer.init()
        
        maskLayer.frame = currentView.bounds;
        //填充色
        maskLayer.fillColor = UIColor.clear.cgColor;
        // 设置线宽
        maskLayer.lineWidth = borderWidth;
        // 设置线的颜色
        maskLayer.strokeColor = borderColor.cgColor;
        // 使用UIBezierPath创建路径
        
        maskLayer.path = maskPath.cgPath;
        
        currentView.layer.addSublayer(maskLayer) ;
        
        
    }
    
    //MARK: - 对各个角分别进行切割
    open class func DN_everyCorner(_ currentView : UIView, topLeftRadius : CGFloat, bottomLeftRadius : CGFloat, topRightRadius : CGFloat, bottomRightRadius : CGFloat, size : CGSize, currentViewBackGroundColor : UIColor? = nil, borderColor : UIColor? = nil, borderWidth : CGFloat? = nil){
        
        let maskPath:UIBezierPath = UIBezierPath.init()
        
        maskPath.move(to: CGPoint(x: size.width - topRightRadius, y: 0))
        
        maskPath.addLine(to: CGPoint(x: topLeftRadius, y: 0))
        
        maskPath.addArc(withCenter: CGPoint(x: topLeftRadius, y: topLeftRadius), radius: topLeftRadius, startAngle: CGFloat(-Double.pi / 2), endAngle: CGFloat(-Double.pi), clockwise: false)
        
        maskPath.addLine(to: CGPoint(x: 0, y: size.height - bottomLeftRadius))
        
        maskPath.addArc(withCenter: CGPoint(x: bottomLeftRadius, y: size.height - bottomLeftRadius), radius: bottomLeftRadius, startAngle: CGFloat(-Double.pi), endAngle: CGFloat(-Double.pi * 3 / 2), clockwise: false)
        
        maskPath.addLine(to: CGPoint(x: size.width - bottomRightRadius, y: size.height))
        
        maskPath.addArc(withCenter: CGPoint(x: size.width - bottomRightRadius, y: size.height - bottomRightRadius), radius: bottomRightRadius, startAngle: CGFloat(Double.pi / 2), endAngle: CGFloat(0), clockwise: false)
        
        maskPath.addLine(to: CGPoint(x: size.width, y: topRightRadius))
        
        maskPath.addArc(withCenter: CGPoint(x: size.width - topRightRadius, y: topRightRadius), radius: topRightRadius, startAngle: CGFloat(0), endAngle: CGFloat(-Double.pi / 2), clockwise: false)
        
        let maskLayer:CAShapeLayer = CAShapeLayer.init()
        
        maskLayer.frame = currentView.bounds
        
        maskLayer.path = maskPath.cgPath
        
        currentView.layer.mask = maskLayer
        
    }
    
}

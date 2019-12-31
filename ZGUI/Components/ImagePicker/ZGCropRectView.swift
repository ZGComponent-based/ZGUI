//
//  ZGCropRectView.swift
//  ZGCamera
//
//  Created by zhaogang on 2018/4/2.
//  Copyright © 2018年 zhaogang. All rights reserved.
//

import UIKit
import ZGCore

protocol ZGCropRectViewDelegate: NSObjectProtocol {
    func yhOptionalCropRectViewDidBeginEditing(cropRectView: ZGCropRectView)
    
    func yhOptionalCropRectViewEditingChanged(cropRectView:ZGCropRectView)
    
    func yhOptionalCropRectViewDidEndEditing(cropRectView:ZGCropRectView)
}
class ZGCropRectView: UIView {
    var delegate : ZGCropRectViewDelegate?
    
    lazy var topLeftCornerView: ZGResizeView = {
        let instance = ZGResizeView()
        instance.delegate = self
        
        return instance
    }()
    lazy var topRightCornerView: ZGResizeView = {
        let instance = ZGResizeView()
        instance.delegate = self
        
        return instance
    }()
    
    lazy var bottomLeftCornerView: ZGResizeView = {
        let instance = ZGResizeView()
        instance.delegate = self
        
        return instance
    }()
    lazy var bottomRightCornerView: ZGResizeView = {
        let instance = ZGResizeView()
        instance.delegate = self
        
        return instance
    }()
    lazy var topEdgeView: ZGResizeView = {
        let instance = ZGResizeView()
        instance.delegate = self
        
        return instance
    }()
    lazy var leftEdgeView: ZGResizeView = {
        let instance = ZGResizeView()
        instance.delegate = self
        
        return instance
    }()
    
    lazy var bottomEdgeView: ZGResizeView = {
        let instance = ZGResizeView()
        instance.delegate = self
        
        return instance
    }()
    lazy var rightEdgeView: ZGResizeView = {
        let instance = ZGResizeView()
        instance.delegate = self
        
        return instance
    }()
    
    
    
    var initialRect = CGRect.zero
    var firstRecordRect = CGRect.zero
    var liveResizing = true
    var isRecord = false
    
    var showsGridMajor :Bool?{
        didSet{
            self.setNeedsLayout()
        }
    }
    var showsGridMinor :Bool?{
        didSet{
            self.setNeedsLayout()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        contentMode = .redraw
        
        self.showsGridMajor = true
        self.showsGridMinor = false
        
        self.isRecord = false
        
        let imageView = UIImageView(frame: self.bounds.insetBy(dx: -2.0, dy: -2.0))
        
        imageView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))
        
        let image = ZGImage(ZGUIUtil.bundleForImage("photoCropEditorBorder"))
        imageView.image = image?.resizableImage(withCapInsets: UIEdgeInsets(top: 23.0, left: 23.0, bottom: 23.0, right: 23.0))
        
        self.addSubview(imageView)
        self.addSubview(self.topLeftCornerView)
        
        
        self.addSubview(self.topRightCornerView)
        self.addSubview(self.bottomLeftCornerView)
        self.addSubview(self.bottomRightCornerView)
        self.addSubview(topEdgeView)
        self.addSubview(leftEdgeView)
        self.addSubview(bottomEdgeView)
        self.addSubview(rightEdgeView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        super.hitTest(point, with: event)
        for subView in subviews {
            if (subView.isKind(of: ZGResizeView.self)){
                if (subView.frame.contains(point)){
                    return subView
                }
                
            }
        }
        return nil
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let width = self.bounds.width
        let height = self.bounds.height
        
        for i  in 0..<3 {
            if let isShowsGridMinor = self.showsGridMinor{
                if isShowsGridMinor {
                    for j in 1..<3{
                        UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.3).set()
                        
                        
                        UIRectFill(CGRect(x:CGFloat(width / 3.0 / 3.0 * CGFloat(j)) + width / CGFloat(3*i) , y: 0, width: 1, height: height))
                        UIRectFill(CGRect(x:0.0 , y: CGFloat(height / 3.0 / 3.0 * CGFloat(j)) + width / CGFloat(3*i), width: width, height: 1.0))
                        
                    }
                }
            }
            
            
            if let isShowsGridMajor = self.showsGridMajor{
                if isShowsGridMajor {
                    if (i > 0){
                        UIColor.white.set()
                        
                        
                        UIRectFill(CGRect(x:CGFloat(width / CGFloat(3) * CGFloat(i)), y: 0, width: 1, height: height))
                        UIRectFill(CGRect(x:0.0 , y: CGFloat(height / 3.0 * CGFloat(i)), width: width, height: 1.0))
                        
                    }
                }
            }
            
        }
        
    }
    
}


extension ZGCropRectView{
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.topRightCornerView.frame = CGRect(origin: CGPoint(x: self.topLeftCornerView.bounds.width / -2, y: self.topLeftCornerView.bounds.height / -2), size: self.topLeftCornerView.bounds.size)
        
        
        self.topRightCornerView.frame = CGRect(origin: CGPoint(x:self.bounds.width -  self.topRightCornerView.bounds.width / -2, y: self.topRightCornerView.bounds.height / -2), size: self.topLeftCornerView.bounds.size)
        
        
        
        self.bottomLeftCornerView.frame = CGRect(origin: CGPoint(x: self.bottomLeftCornerView.bounds.width / -2, y:self.bounds.height -  self.bottomLeftCornerView.bounds.height / 2), size: self.bottomLeftCornerView.bounds.size)
        
        
        self.bottomRightCornerView.frame = CGRect(origin: CGPoint(x: self.bounds.width - self.bottomRightCornerView.bounds.width / 2, y:self.bounds.height -  self.bottomRightCornerView.bounds.height / 2), size: self.topRightCornerView.bounds.size)
        
        
        self.topEdgeView.frame = CGRect(x: self.topLeftCornerView.frame.maxX, y: self.topEdgeView.frame.height / -2, width: self.topRightCornerView.frame.minX - self.topLeftCornerView.frame.maxX, height: self.topEdgeView.bounds.height)
        
        self.leftEdgeView.frame = CGRect(x: self.leftEdgeView.frame.width / -2, y: self.topLeftCornerView.frame.maxY / -2, width: self.leftEdgeView.bounds.width, height:self.bottomLeftCornerView.frame.minY -  self.topLeftCornerView.frame.maxY)
        
        self.bottomEdgeView.frame = CGRect(x: self.bottomLeftCornerView.frame.maxX, y: self.bottomLeftCornerView.frame.minY, width: self.bottomRightCornerView.frame.minX - self.bottomLeftCornerView.frame.maxX, height: self.bottomEdgeView.bounds.height)
        
        self.rightEdgeView.frame = CGRect(x:self.bounds.width - self.rightEdgeView.bounds.width/2 , y: self.topRightCornerView.frame.minY, width: self.rightEdgeView.bounds.width, height:self.bottomRightCornerView.frame.minY -  self.topRightCornerView.frame.maxY)
    }
    private func cropRectMakeWithResizeControlView(resizeControlView: ZGResizeView) -> CGRect {
        var rect = self.frame
        if let translation = resizeControlView.translation{
            
            if resizeControlView == self.topEdgeView {
                let width = self.initialRect.height - translation.y
                
                rect = CGRect(x: self.initialRect.minX + translation.y / 2, y: self.initialRect.minY + translation.y, width: width, height: width)
                
            }else if(resizeControlView == self.leftEdgeView){
                let width = self.initialRect.width - translation.x
                
                rect = CGRect(x: self.initialRect.minX + translation.x, y: self.initialRect.minY + translation.x/2, width: width, height: width)
            }else if (resizeControlView == self.bottomEdgeView) {
                let width = self.initialRect.height + translation.y
                //修改4.15
                rect = CGRect(x: self.initialRect.minX - translation.y/2, y: self.initialRect.minY, width: width, height: width)
                
            }else if (resizeControlView == self.rightEdgeView) {
                let width = self.initialRect.width + translation.x
                
                rect = CGRect(x: self.initialRect.minX , y: self.initialRect.minY-translation.x/2 , width: width, height: width)
                
            }else if (resizeControlView == self.topLeftCornerView){
                
                rect = CGRect(x: self.initialRect.minX + translation.x, y: self.initialRect.minY + translation.x, width: self.initialRect.width - translation.x, height: self.initialRect.height - translation.x)
                
            }else if (resizeControlView == self.topRightCornerView){
                
                rect = CGRect(x: self.initialRect.minX + translation.x, y: self.initialRect.minY + translation.y, width: self.initialRect.width - translation.y, height: self.initialRect.height - translation.y)
                
            }else if (resizeControlView == self.bottomLeftCornerView){
                
                rect = CGRect(x: self.initialRect.minX + translation.x, y: self.initialRect.minY,
                              width: self.initialRect.width - translation.x, height: self.initialRect.height - translation.x)
                
            }else if (resizeControlView == self.bottomRightCornerView){
                
                rect = CGRect(x: self.initialRect.minX ,y: self.initialRect.minY, width: self.initialRect.width + translation.x, height: self.initialRect.height + translation.x)
            }
        }
        
        
        let minWidth = self.leftEdgeView.bounds.width + self.rightEdgeView.bounds.width
        
        if rect.width < minWidth {
            rect.origin.x = self.frame.maxX - minWidth
            rect.size.width = minWidth
        }
        let minHeight = self.topEdgeView.bounds.height + self.bottomEdgeView.bounds.height
        
        if rect.height < minHeight {
            rect.origin.y = self.frame.maxY - minHeight
            rect.size.height = minHeight
        }
        
        
        
        //边界不让滚动
        rect = CGRect(x:  max(rect.minX, self.firstRecordRect.minX), y: max(rect.minY,self.firstRecordRect.minY), width: min(rect.width,self.firstRecordRect.width), height: min(rect.height,self.firstRecordRect.height))
        
        
        return rect
    }
}

// MARK: -ZGResizeConrolViewDelegate
extension ZGCropRectView:ZGResizeConrolViewDelegate{
    func yhdOptionalResizeConrolViewDidBeginResizing(resizeConrolView: ZGResizeView) {
        self.liveResizing = true
        self.initialRect = self.frame
        self.delegate?.yhOptionalCropRectViewDidBeginEditing(cropRectView: self)
        
        if !self.isRecord && self.initialRect.width > 0 {
            self.isRecord = true
            self.firstRecordRect = self.initialRect
        }
    }
    
    func yhdOptionalResizeConrolViewDidResize(resizeConrolView: ZGResizeView) {
        self.frame = self.cropRectMakeWithResizeControlView(resizeControlView: resizeConrolView)
        self.delegate?.yhOptionalCropRectViewEditingChanged(cropRectView: self)
        
    }
    
    func yhdOptionalResizeConrolViewDidEndResizing(resizeConrolView: ZGResizeView) {
        
        self.liveResizing = false
        self.delegate?.yhOptionalCropRectViewDidEndEditing(cropRectView: self)
    }
}

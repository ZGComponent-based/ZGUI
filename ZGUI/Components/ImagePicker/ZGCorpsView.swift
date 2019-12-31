//
//  ZGCorpsView.swift
//  ZGCamera
//
//  Created by zhaogang on 2018/4/2.
//  Copyright © 2018年 zhaogang. All rights reserved.
//

import UIKit
import AVFoundation
import QuartzCore
let MarginTop :CGFloat = 37.0
let MarginLeft :CGFloat = 37.0

protocol YHDCropViewDelegate:NSObjectProtocol {
    
    func yhdOptionalDidBeginingTailor(_ cropView:ZGCorpsView)
    
    func yhdOptionalDidFinishTailor(_ cropView:ZGCorpsView)
}

class ZGCorpsView: UIView {
    
    var delegate :YHDCropViewDelegate?
    
    var image : UIImage?{
        didSet{
            self.imageView?.removeFromSuperview()
            self.imageView = nil
            self.zoomingView?.removeFromSuperview()
            self.zoomingView = nil
            self.setNeedsLayout()
        }
    }
    var croppedImage : UIImage?{
        get{
            if (self.delegate != nil ) {
                self.delegate?.yhdOptionalDidBeginingTailor(self)
            }
            
            var cropRect = self.convert(self.scrollView.frame, to: self.zoomingView)
            let size = self.image?.size
            
            if !self.isZoom {
                cropRect = CGRect(x: cropRect.origin.x, y: cropRect.origin.y, width: cropRect.size.width, height: cropRect.size.width)
            }
            
            var ratio :CGFloat =  1.0
            let orientation = UIApplication.shared.statusBarOrientation
            
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad || orientation.isPortrait {
                if let imageSize = self.image?.size,let width = size?.width{
                    ratio = AVMakeRect(aspectRatio: imageSize, insideRect: self.insetRect).width / width
                }
                
            }else{
                if let imageSize = self.image?.size,let height = size?.height{
                    ratio = AVMakeRect(aspectRatio:imageSize, insideRect: self.insetRect).height / height
                }
            }
            
            let zoomedCropRect = CGRect(x: cropRect.origin.x / ratio, y: cropRect.origin.y / ratio, width: cropRect.size.height / ratio, height: cropRect.size.height / ratio)
            var finalImage : UIImage?
            if let transform = self.imageView?.transform{
                
                if let rotatedImage = self.image?.rotatedImageWithImage(transform:transform),
                    let croppedImage = rotatedImage.cgImage?.cropping(to: zoomedCropRect) {
                    let image = UIImage(cgImage: croppedImage, scale: 1.0, orientation: (rotatedImage.imageOrientation))
                    
                    if self.angle == -90 {
                        finalImage = image.rotate(orient: .left)
                    }else if(self.angle == -180){
                        finalImage = image.rotate(orient: .down)
                    }else if(self.angle == -270){
                        finalImage = image.rotate(orient: .right)
                    }else{
                        
                        finalImage = image
                    }
                }
            }
            return finalImage!
        }
    }
    
    var aspectRatio :CGFloat?{
        
        set{
            var cropRect = self.scrollView.frame
            var width = cropRect.width
            var height = cropRect.height
            if width < height {
                if let newvalue = newValue{
                    width = height * newvalue
                }
            }else{
                if let newvalue = newValue{
                    height = width * newvalue
                }
            }
            cropRect.size = CGSize(width: width, height: height)
            
            self.zoomToCropRect(toRect: cropRect)
        }
        
        get{
            let cropRect = self.scrollView.frame
            let width = cropRect.width
            let height = cropRect.height
            return width / height
        }
    }
    
    var cropRect :CGRect?{
        
        set{
            if let newvalue = newValue{
                self.zoomToCropRect(toRect: newvalue)
            }
        }
        get{
            return self.scrollView.frame
        }
    }
    
    
    lazy var scrollView: UIScrollView = {
        let instance = UIScrollView(frame: self.bounds)
        instance.delegate = self
        
        instance.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleTopMargin.rawValue) | UInt8(UIView.AutoresizingMask.flexibleLeftMargin.rawValue) | UInt8(UIView.AutoresizingMask.flexibleRightMargin.rawValue) | UInt8(UIView.AutoresizingMask.flexibleBottomMargin.rawValue)))
        instance.backgroundColor = UIColor.clear
        instance.maximumZoomScale = 20.0
        instance.showsHorizontalScrollIndicator = false
        instance.showsVerticalScrollIndicator = false
//        instance.bounces = false
//        instance.bouncesZoom = false
        instance.clipsToBounds = false
        
        return instance
    }()
    
    lazy  var cropRectView : ZGCropRectView = {
        let instance = ZGCropRectView()
        instance.delegate  = self
        return instance
    }()
    var zoomingView : UIView?
    
    var imageView : UIImageView?
    
    var insetRect = CGRect.zero
    var editingRect = CGRect.zero
    
    var resizing = false
    
    /*用来标示是否移动*/
    var isZoom = true
    /*是否正在旋转动画中*/
    var rotateAnimationInProgress = false
    
    /*当前旋转角度*/
    var angle:Int = 0
    
    /*记住最后一次旋转角度*/
    var cropBoxLastEditedAngle:Int = 0
    
    var topOverlayView : UIView?
    var leftOverlayView :UIView?
    var rightOverlayView : UIView?
    var bottomOverlayView :UIView?
    var isBlack:Bool?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let hitView = self.cropRectView.hitTest(self.convert(point, to: self.cropRectView), with: event)
        
        if hitView != nil {
            return hitView
        }
        
        let locationInImageView = self.convert(point, to: self.zoomingView)
        let zoomedPoint = CGPoint(x: locationInImageView.x * self.scrollView.zoomScale, y: locationInImageView.y * self.scrollView.zoomScale)
        if let isZommedPoint = self.zoomingView?.frame.contains(zoomedPoint){
            if isZommedPoint {
                return self.scrollView
            }
        }
        
        return super.hitTest(point, with: event)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let _ = self.image else {
            return
        }
        
        self.editingRect = self.bounds.insetBy(dx: MarginLeft, dy: MarginTop)
        
        if self.imageView == nil {
            self.insetRect = self.bounds.insetBy(dx: MarginLeft, dy: MarginTop)
            self.setupImageView()
        }
        
        if !self.resizing {
            self.layoutCropRectViewWithCropRect(cropRect: self.scrollView.frame)
            
        }
    }
    
}

extension ZGCorpsView{
    
    private func setupUI(){
        
        self.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)|UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue)))
        backgroundColor = UIColor.clear
        self.addSubview(self.scrollView)
        self.addSubview(self.cropRectView)
        self.topOverlayView = UIView()
        self.topOverlayView?.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        if let topOverlayView = self.topOverlayView{
            self.addSubview(topOverlayView)
        }
        self.leftOverlayView = UIView()
        self.leftOverlayView?.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        if let leftOverlayView = self.leftOverlayView{
            self.addSubview(leftOverlayView)
        }
        self.rightOverlayView = UIView()
        self.rightOverlayView?.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        if let rightOverlayView = self.rightOverlayView{
            self.addSubview(rightOverlayView)
        }
        self.bottomOverlayView = UIView()
        self.bottomOverlayView?.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        if let bottomOverlayView = self.bottomOverlayView{
            self.addSubview(bottomOverlayView)
        }
    }
}

extension ZGCorpsView{
    //视图旋转
    open func rotateScrollView(){
        
        if self.rotateAnimationInProgress {
            return
        }
        
        //计算新的旋转角度
        var newAngle  = self.angle
        
        newAngle = newAngle - 90
        if newAngle <= -360 {
            newAngle = 0
        }
        
        self.angle = newAngle
        
        //角度转弧度
        var angleInRadians:CGFloat = 0.0
        switch newAngle {
        case -90:
            angleInRadians = -CGFloat(Double.pi/2)
            break
            
        case -180:
            angleInRadians = -CGFloat(Double.pi)
            break
        case -270:
            angleInRadians = -CGFloat(Double.pi + Double.pi/2)
            break
        default:
            break
        }
        
        /*设置旋转矩阵*/
        let rotation = CGAffineTransform.init(rotationAngle: angleInRadians)
        self.cropRectView.alpha = 0.0
        UIView.animate(withDuration: 1.0, animations: {
            self.transform = rotation
            self.rotateAnimationInProgress = true
            
            
        }) { (complete) in
            self.rotateAnimationInProgress = false
            self.cropRectView.alpha = 1.0
        }
    }
    
    //重置
    open func resetScrollView(){
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .beginFromCurrentState, animations: {
            self.scrollView.bounds = self.cropRectView.frame
            self.scrollView.zoom(to: self.cropRectView.frame, animated: false)
        }) { (complete) in
            
        }
        
    }
    
    private  func layoutCropRectViewWithCropRect(cropRect:CGRect) {
        self.cropRectView.frame = cropRect
        let width = cropRect.width
        let heigt = cropRect.height
        let rect = CGRect(x: cropRect.minX, y: cropRect.minY + (heigt - width)/2, width: width, height: width)
        
        UIView.animate(withDuration: 1.0, animations: {
            self.cropRectView.frame = rect
        }) {[weak self] (complete) in
            if let isBlack = self?.isBlack{
                if isBlack {
                    self?.isBlack = false
                    if let frame = self?.cropRectView.frame{
                         self?.zoomToCropRect(toRect: frame)
                    }
                   
                }
            }

        }
        self.layoutOverlayViewsWithCropRect(cropRect: cropRect)
    }
    
    private func setupImageView()  {
        if let imageSize = self.image?.size{
            
            let cropRect = AVMakeRect(aspectRatio: imageSize, insideRect: self.insetRect)
            self.scrollView.frame = cropRect
            self.scrollView.contentSize = cropRect.size
            self.zoomingView = UIView(frame: self.scrollView.bounds)
            if let zoomingView = self.zoomingView{
                
                self.scrollView.addSubview(zoomingView)
            }
            if let imageFrame = self.zoomingView?.bounds{
                self.imageView = UIImageView(frame: imageFrame)
            }
            self.imageView?.backgroundColor = UIColor.clear
            self.imageView?.contentMode = .scaleAspectFit
            self.imageView?.image = self.image
            if let imageView = self.imageView{
                self.zoomingView?.addSubview(imageView)
            }
            isBlack = true
        }
        
    }
    
    private func layoutOverlayViewsWithCropRect(cropRect:CGRect)  {
        self.topOverlayView?.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.width, height:cropRect.minY )
        
        self.leftOverlayView?.frame = CGRect(x: 0.0, y: cropRect.minY, width: cropRect.minX, height: cropRect.height)
        
        self.rightOverlayView?.frame = CGRect(x: cropRect.maxX, y: cropRect.minY , width: self.bounds.width - cropRect.maxX, height: cropRect.height)
        
        self.bottomOverlayView?.frame = CGRect(x: 0.0, y: cropRect.maxY, width: self.bounds.width, height: self.bounds.height - cropRect.maxY)
    }
    
    
    private func zoomToCropRect(toRect: CGRect)  {
        if self.scrollView.frame.equalTo(toRect) {
            return
        }
        
        let width = toRect.width
        let height = toRect.height
        
        let scale = min(self.editingRect.width / width, self.editingRect.height / height)
        
        let scaledWidth = width * scale
        let scaledHeight = height * scale
        
        let cropRect = CGRect(x: (self.bounds.width - scaledWidth)/2, y: (self.bounds.height - scaledHeight) / 2, width: scaledWidth, height: scaledHeight)
        var zoomRect = self.convert(toRect, to: self.zoomingView)
        zoomRect.size.width = cropRect.width / (self.scrollView.zoomScale * scale)
        zoomRect.size.height = cropRect.height / (self.scrollView.zoomScale * scale)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .beginFromCurrentState, animations: {
            self.scrollView.bounds = cropRect
            self.scrollView.zoom(to: zoomRect, animated: false)
            self.layoutCropRectViewWithCropRect(cropRect: cropRect)
        }) { (complete) in
            
        }
    }
    
    private func cappedCropRectInImageRectWithCropRectView(cropRectView:ZGCropRectView) -> CGRect  {
        var cropRect = cropRectView.frame
        
        let rect = self.convert(cropRect, to: self.scrollView)
        if let zoomMinX = self.zoomingView?.frame.minX{
            if rect.minX < zoomMinX {
                if let zoomFrame = self.zoomingView?.frame{
                    let temp = self.scrollView.convert(zoomFrame, to: self)
                    cropRect.origin.x = temp.minX
                    cropRect.size.width = rect.maxX
                }
                
            }
        }
        
        if let zoomMinY = self.zoomingView?.frame.minY{
            if rect.minY < zoomMinY {
                if let zoomFrame = self.zoomingView?.frame{
                    let temp = self.scrollView.convert(zoomFrame, to: self)
                    cropRect.origin.y = temp.minY
                    cropRect.size.height = rect.maxX
                }
                
            }
            
        }
        
        if let zoomMaxX = self.zoomingView?.frame.maxX{
            if rect.maxX > zoomMaxX {
                if let zoomFrame = self.zoomingView?.frame{
                    let temp = self.scrollView.convert(zoomFrame, to: self)
                    cropRect.size.width = temp.maxX - cropRect.minX
                }
            }
        }
        
        if let zoomMaxY = self.zoomingView?.frame.maxY{
            if rect.maxY > zoomMaxY {
                if let zoomFrame = self.zoomingView?.frame{
                    let temp = self.scrollView.convert(zoomFrame, to: self)
                    cropRect.size.height = temp.minY - cropRect.minY
                }
                
            }
            
        }
        
        return cropRect
    }
    
    private func automaticZoomIfEdgeTouched(cropRect:CGRect) {
        if (cropRect.minX < (self.editingRect.minX - 5.0) || cropRect.maxX > (self.editingRect.maxX + 5.0) ||
            cropRect.minY < (self.editingRect.minY - 5.0) ||
            cropRect.maxY > (self.editingRect.maxY + 5.0)){
            
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .beginFromCurrentState, animations: {
                self.zoomToCropRect(toRect: self.cropRectView.frame)
            }, completion: nil)
            
        }
    }
    
}


extension ZGCorpsView:ZGCropRectViewDelegate{
    func yhOptionalCropRectViewDidBeginEditing(cropRectView: ZGCropRectView) {
        self.resizing = true
        self.isZoom = true
        
    }
    
    func yhOptionalCropRectViewEditingChanged(cropRectView: ZGCropRectView) {
        let cropRect = self.cappedCropRectInImageRectWithCropRectView(cropRectView: cropRectView)
        self.layoutCropRectViewWithCropRect(cropRect: cropRect)
        self.automaticZoomIfEdgeTouched(cropRect: cropRect)
    }
    
    func yhOptionalCropRectViewDidEndEditing(cropRectView: ZGCropRectView) {
        self.resizing = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if !self.resizing{
                self.zoomToCropRect(toRect: self.cropRectView.frame)
            }
        }
    }
    
}

extension ZGCorpsView:UIGestureRecognizerDelegate{
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool{
        
        return true
    }
}

extension ZGCorpsView:UIScrollViewDelegate{
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        var contentOffset = scrollView.contentOffset
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.zoomingView
    }
}

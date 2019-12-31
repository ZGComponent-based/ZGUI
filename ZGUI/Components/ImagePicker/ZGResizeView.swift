//
//  ZGResizeView.swift
//  ZGCamera
//
//  Created by zhaogang on 2018/4/2.
//  Copyright © 2018年 zhaogang. All rights reserved.
//

import UIKit

protocol ZGResizeConrolViewDelegate:NSObjectProtocol {
    func yhdOptionalResizeConrolViewDidBeginResizing(resizeConrolView:ZGResizeView)
    
    func yhdOptionalResizeConrolViewDidResize(resizeConrolView:ZGResizeView)
    func yhdOptionalResizeConrolViewDidEndResizing(resizeConrolView:ZGResizeView)
}


class ZGResizeView :UIView{
    
    var translation: CGPoint?
    var startPoint: CGPoint?
    
    var delegate : ZGResizeConrolViewDelegate?
    
    override init(frame:CGRect) {
        super.init(frame:CGRect(x: frame.origin.x, y: frame.origin.y, width: 10.0, height: 10.0))
        backgroundColor = UIColor.clear
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_ :)))
        addGestureRecognizer(gestureRecognizer)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ZGResizeView{
    
    @objc func handlePan(_ gestureRecognizer:UIPanGestureRecognizer) {
        
        if gestureRecognizer.state == .began{
            let translationInView: CGPoint = gestureRecognizer.translation(in: self.superview)
            self.startPoint = CGPoint(x: translationInView.x, y: translationInView.y)
            
            self.delegate?.yhdOptionalResizeConrolViewDidBeginResizing(resizeConrolView: self)
        }else if(gestureRecognizer.state == .changed){
            
            let translation: CGPoint = gestureRecognizer.translation(in: self.superview)
            if let startPoint = self.startPoint{
                self.translation = CGPoint(x: CGFloat(roundf(Float(startPoint.x + translation.x))), y: CGFloat(roundf(Float(startPoint.y + translation.y))))
                self.delegate?.yhdOptionalResizeConrolViewDidResize(resizeConrolView: self)
            }
            
        }else if(gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled) {
            
            self.delegate?.yhdOptionalResizeConrolViewDidEndResizing(resizeConrolView: self)
        }
        
    }
    
}

//
//  CropViewControllerTransitioning.swift
//  ZGCamera
//
//  Created by libo on 2018/3/31.
//  Copyright © 2018年 libo. All rights reserved.
//

import UIKit

class CropViewControllerTransitioning: NSObject,UIViewControllerAnimatedTransitioning {
    
    var isDissmissing = false
    var image = UIImage()
    var fromView = UIView()
    var toView = UIView()
    var fromFrame = CGRect.zero
    var toframe = CGRect.zero
    var prepareForTransitionHandler = (()->Void).self
    
}



// MARK: - 代理方法
extension CropViewControllerTransitioning{
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.45
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView: UIView = transitionContext.containerView
        
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        
        let cropViewController = (self.isDissmissing == false) ? toViewController : fromViewController
        let previousController = (self.isDissmissing == false) ? fromViewController : toViewController
        
        cropViewController?.view.frame = containerView.bounds
        if self.isDissmissing {
            previousController?.view.frame = containerView.bounds
        }
        
        if self.isDissmissing == false {
            if let cropView = cropViewController?.view{
                containerView.addSubview((cropView))
            }
            
        } else {
            if let previousView = previousController?.view,let cropView = cropViewController?.view{
                
                containerView.insertSubview(previousView, belowSubview: cropView)
            }
            
        }
        var imageView: UIImageView? = nil
        if ((self.isDissmissing && !self.toframe.isEmpty)) || (!self.isDissmissing  && (!self.fromFrame.isEmpty)) {
            imageView = UIImageView(image: self.image)
            imageView?.frame = self.fromFrame
            if let imageView = imageView{
                containerView.addSubview(imageView)
            }
        }
        cropViewController?.view.alpha = (self.isDissmissing ? 1.0 : 0.0)
        
        if let imageView = imageView{
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.7, options: UIView.AnimationOptions(rawValue: 0), animations: {    imageView.frame = self.toframe
                
            })
        }
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {    cropViewController?.view.alpha = (self.isDissmissing ? 0.0 : 1.0)
            
        })
        
    }
}

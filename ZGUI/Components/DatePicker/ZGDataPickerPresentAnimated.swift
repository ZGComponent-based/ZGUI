//
//  EWDataPickerPresentAnimated.swift
//  EWDatePicker
//
//  Created by Ethan.Wang on 2018/8/27.
//  Copyright © 2018年 Ethan. All rights reserved.
//

import UIKit

enum ZGDatePickerPresentAnimateType {
    case present//被推出时
    case dismiss//取消时
}

//EWDatePickerViewController的推出和取消动画
class ZGDatePickerPresentAnimated: NSObject,UIViewControllerAnimatedTransitioning {

    var type: ZGDatePickerPresentAnimateType = .present

    init(type: ZGDatePickerPresentAnimateType) {
        self.type = type
    }
    /// 动画时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    /// 动画效果
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        switch type {
        case .present:
            let toVC : ZGDatePickerViewController = transitionContext.viewController(forKey: .to) as! ZGDatePickerViewController
            let toView = toVC.view

            let containerView = transitionContext.containerView
            containerView.addSubview(toView!)

            toVC.containV.transform = CGAffineTransform(translationX: 0, y: (toVC.containV.frame.height))

            UIView.animate(withDuration: 0.25, animations: {
                /// 背景变色
                toVC.backgroundView.alpha = 1.0
                /// datepicker向上推出
                toVC.containV.transform =  CGAffineTransform(translationX: 0, y: -10)
            }) { (finished) in
                UIView.animate(withDuration: 0.2, animations: {
                    /// transform初始化
                    toVC.containV.transform = CGAffineTransform.identity
                }, completion: { (finished) in
                    transitionContext.completeTransition(true)
                })
            }
        case .dismiss:
            let toVC : ZGDatePickerViewController = transitionContext.viewController(forKey: .from) as! ZGDatePickerViewController

            UIView.animate(withDuration: 0.25, animations: {
                toVC.backgroundView.alpha = 0.0
                /// datepicker向下推回
                toVC.containV.transform =  CGAffineTransform(translationX: 0, y: (toVC.containV.frame.height))
            }) { (finished) in
                transitionContext.completeTransition(true)
            }
        }
    }
}

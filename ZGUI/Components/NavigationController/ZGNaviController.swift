//
//  ZGNaviController.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/3/21.
//  All rights reserved.
//

import UIKit

public let ZGUINavigationPanNotifyCation = "ZGUINavigationPanNotifyCation"
let ZGUINavigationShadowMax: CGFloat = 0.7
let ZGSUINavigationShadowViewMinAlpha: CGFloat = 0.2//shadowView 最低的透明度
let ZGUINavigationPushPopTime: Double = 0.35

open class ZGNaviController: UINavigationController {
    
    // 默认为特效开启
    public var canDragBack = true
    
    var animating = false
    var shadowView: UIView!
    var interactivePopGestureRecognizer1: UIPanGestureRecognizer?
    let screenW = UIScreen.main.bounds.size.width
    
    /**
     * 子类可以重新该方法用来处理滚动视图的响应
     */
    open dynamic  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        if floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1 && interactivePopGestureRecognizer1 != nil {
            interactivePopGestureRecognizer1?.delegate = nil
            interactivePopGestureRecognizer1?.isEnabled = false
        }
        navigationBar.setBackgroundImage(self.ts_imageWithColor(UIColor.white), for: .default)
//        navigationBar.backgroundColor = UIColor.white
        navigationBar.shadowImage = UIImage()
        self.setNavigationBarHidden(true, animated: false)
        shadowView = UIView(frame: self.view.bounds)
        shadowView.backgroundColor = UIColor.black
        shadowView.alpha = ZGSUINavigationShadowViewMinAlpha
        
        interactivePopGestureRecognizer1 = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureRecognizer(_:)))
        interactivePopGestureRecognizer1?.delegate = self
        self.view.addGestureRecognizer(interactivePopGestureRecognizer1!)
        self.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    func ts_imageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    override open func pushViewController(_ viewController: UIViewController, animated: Bool) {
//        if animating {
//            return
//        }
//        animating = true
        interactivePopGestureRecognizer1?.isEnabled = false
        super.pushViewController(viewController, animated: animated)
    }
    
    override open func popViewController(animated: Bool) -> UIViewController? {
        interactivePopGestureRecognizer1?.isEnabled = false
        if let topViewController = self.topViewController {
            addShadowView(topViewController, defaultValue: ZGUINavigationShadowMax)
        }
        var duration: Double = 0
        if animated {
            duration = ZGUINavigationPushPopTime
        }
        UIView.animate(withDuration: duration) {
            self.shadowView.alpha = 0.0
        }
        //暂时先注释掉，控制器返回方法走两遍
//        preparePopController()
        return super.popViewController(animated: animated)
    }
    
    override open func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if let topViewController = self.topViewController {
            addShadowView(topViewController, defaultValue: ZGUINavigationShadowMax)
        }
        interactivePopGestureRecognizer1?.isEnabled = false
        return super.popToRootViewController(animated: animated)
    }
    
    override open func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if let topViewController = self.topViewController {
            addShadowView(topViewController, defaultValue: ZGUINavigationShadowMax)
        }
        UIView.animate(withDuration: ZGUINavigationPushPopTime) {
            self.shadowView.alpha = 0.0
        }
        interactivePopGestureRecognizer1?.isEnabled = false
        return super.popToViewController(viewController, animated: animated)
    }
    
    func addShadowView(_ viewController: UIViewController, defaultValue: CGFloat){
        
        if !shadowView.isDescendant(of: viewController.view) {
            viewController.view.addSubview(shadowView)
        }
        
        var rect = shadowView.frame
        rect.origin.x = -1 * screenW
        rect.size.width = screenW
        rect.size.height = self.view.frame.size.height
        shadowView.frame = rect
        
        shadowView.frame = rect;
        shadowView.alpha = defaultValue
    }
    
    //没写完
    /**
     * 需要保证窗口在回退时能够正常调用自定义返回方法
     */
    func preparePopController(){
        self.animating = false
        guard let ctl = self.topViewController else {
            return
        }
        if ctl is ZGBaseViewCTL {
            let viewCtl = ctl as! ZGBaseViewCTL
            viewCtl.preGoBack()
            if let gobackHandler = viewCtl.gobackHandler {
                gobackHandler(viewCtl.paramDict)
            }
        }
    }
    
    deinit {
        self.delegate = nil
        shadowView = nil
        interactivePopGestureRecognizer1 = nil
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ZGNaviController: UIGestureRecognizerDelegate{
    
    @objc func panGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        if self.viewControllers.count <= 1 || !canDragBack {
            return
        }
        let translationX = gestureRecognizer.translation(in: self.view).x
        //velocityX 为正时候向右滑动，为负时候向左滑动
        let velocityX = gestureRecognizer.velocity(in:self.view).x
        rightwardsPanGestureRecognizer(gestureRecognizer, translationX: translationX, velocityX: velocityX)
    }
    
    func rightwardsPanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer, translationX:CGFloat, velocityX: CGFloat) {

        guard let outVCL = self.viewControllers.last else{
            return
        }
        if self.viewControllers.count < 2 {
            return
        }
        let inVCL = self.viewControllers[self.viewControllers.count-2]
        
        if gestureRecognizer.state == .began {
            
           rightwardsPanGestureBegin(inVCL, outVCL: outVCL)
            
        }else if gestureRecognizer.state == .changed {
            
            rightwardsPanGestureChange(inVCL, outVCL: outVCL, translationX: translationX)
            
        }else if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
            
            rightwardsPanGestureEnd(inVCL, outVCL: outVCL, translationX: translationX, velocityX: velocityX)
        }
    }
    
    func rightwardsPanGestureEnd(_ inVCL: UIViewController, outVCL: UIViewController, translationX: CGFloat, velocityX: CGFloat) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ZGUINavigationPanNotifyCation) , object: nil, userInfo: ["moving":NSNumber.init(value: false)])
        
        if translationX < 100 {
            if velocityX < 170 {
                UIApplication.shared.beginIgnoringInteractionEvents()
                UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.shadowView.alpha = ZGUINavigationShadowMax
                    outVCL.view.center = CGPoint(x: self.screenW/2, y: outVCL.view.frame.size.height/2)
                    inVCL.view.center = CGPoint(x: 62, y: inVCL.view.frame.size.height / 2)
                }, completion: { (finished) in
                    inVCL.view.removeFromSuperview()
                    UIApplication.shared.endIgnoringInteractionEvents()
                })
                return
            }
        }
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            self.shadowView.alpha = 0
            inVCL.view.center = CGPoint(x: self.screenW/2, y: inVCL.view.frame.size.height/2.0)
            outVCL.view.center = CGPoint(x: self.view.frame.size.width + self.screenW / 2.0, y:outVCL.view.frame.size.height/2)
        }, completion: { (finished) in
            outVCL.willMove(toParent: nil)
            outVCL.beginAppearanceTransition(false, animated: true)
            
            if let outViewController = self.viewControllers.last{
                outViewController.view.removeFromSuperview()
                self.preparePopController()
                outViewController.removeFromParent()
                outViewController.endAppearanceTransition()
                inVCL.beginAppearanceTransition(true, animated: true)
            }
            if let inViewController = self.viewControllers.last{
                inViewController.endAppearanceTransition()
            }
            UIApplication.shared.endIgnoringInteractionEvents()
        })
    }
    
    func rightwardsPanGestureBegin(_ inVCL: UIViewController, outVCL: UIViewController){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ZGUINavigationPanNotifyCation) , object: nil, userInfo: ["moving":NSNumber.init(value: true)])
        
        if let controllerView = self.view.subviews.first?.subviews.first{
            inVCL.view.frame = controllerView.bounds
            let sViews = controllerView.subviews
            var enableInsertInnerView = true
            
            for viewItem in sViews {
                if viewItem == inVCL.view {
                    enableInsertInnerView = false
                    break
                }
            }
            if enableInsertInnerView {
                controllerView.insertSubview(inVCL.view, belowSubview: outVCL.view)
                let path = UIBezierPath(rect: outVCL.view.bounds)
                outVCL.view.layer.shadowPath = path.cgPath
                outVCL.view.layer.shadowColor = UIColor.black.cgColor
                outVCL.view.layer.shadowOffset = CGSize(width: 3, height: 0)
                outVCL.view.layer.shadowOpacity = 0.7
                outVCL.view.layer.shadowRadius = 3.0
                if let topViewController = self.topViewController {
                    addShadowView(topViewController, defaultValue: ZGUINavigationShadowMax)
                }
            }
            inVCL.view.center = CGPoint(x: 62, y: inVCL.view.frame.size.height/2)
            outVCL.view.center = CGPoint(x: screenW/2, y: outVCL.view.frame.size.height/2)
        }
    }
    
    func rightwardsPanGestureChange(_ inVCL: UIViewController, outVCL: UIViewController, translationX: CGFloat){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ZGUINavigationPanNotifyCation) , object: nil, userInfo: ["moving":NSNumber.init(value: true)])
        var temp = screenW - 320
        if temp > 0 {
            temp = temp/2
        }
        
        var inViewCenterX = 62.0 + temp + translationX / (screenW / 98.0)
        var outViewCenterX = screenW / 2.0 + translationX
        if inViewCenterX > screenW / 2.0 {
            inViewCenterX = self.screenW / 2.0
        }
        if outViewCenterX < screenW / 2.0{
            outViewCenterX = self.screenW / 2.0
        }
        
        let shadowX = ZGUINavigationShadowMax * (80 - translationX/(screenW/98.0))/80
        shadowView.alpha = shadowX
        
        inVCL.view.center = CGPoint(x: inViewCenterX, y: inVCL.view.frame.size.height/2)
        outVCL.view.center = CGPoint(x: outViewCenterX, y: outVCL.view.frame.size.height/2)
    }
}

extension ZGNaviController: UINavigationControllerDelegate{
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool){
        shadowView.removeFromSuperview()
        interactivePopGestureRecognizer1?.isEnabled = true
        animating = false
    }
}

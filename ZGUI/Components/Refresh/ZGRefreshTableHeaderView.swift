//
//  ZGRefreshTableHeaderView.swift
//  ZGUIDemo
//
//  Created by LeAustinHan on 2017/3/17.
//  
//

import UIKit
import ZGNetwork
import ZGCore
import QuartzCore

//宏定义
let FLIP_ANIMATION_DURATION =  0.18
let TEXT_COLOR = UIColor.color(withHex: 0x333333)

//FIXME:test
//TODO:test
public enum EGOOPullRefreshState {
    case egooPullRefreshPulling
    case egooPullRefreshNormal
    case egooPullRefreshLoading
    case egooPullRefreshComplete
    case egooPullRefreshSuccess //用于成功提示
    case egooPullRefreshError //刷新失败
}

public enum RefreshTableHeaderViewStyle {
    case refreshTableHeaderViewStyleDefault
    case refreshTableHeaderViewStyleCustom //左边是图片动画，右边是loading动画
}

//代理,加上@objc 与不加有什么不同？如何不加@objc声明可选代理？
@objc public protocol ZGRefreshTableHeaderDelegate : NSObjectProtocol{
    func refreshTableHeaderDidTriggerRefresh(_ view:ZGRefreshTableHeaderView)
    func refreshTableHeaderDataSourceIsLoading(_ view:ZGRefreshTableHeaderView) ->Bool
    
    @objc optional func refreshTableHeaderDidFinishedLoading(_ view: ZGRefreshTableHeaderView)
    @objc optional func refreshTableHeaderDidTriggerFallRedPacket(_ view: ZGRefreshTableHeaderView)
}

open class ZGRefreshTableHeaderView: UIView {
    open weak var delegate:ZGRefreshTableHeaderDelegate?
    open var isLoadingComplete:Bool = false
    open var state:EGOOPullRefreshState = .egooPullRefreshNormal
    public var style:RefreshTableHeaderViewStyle!
    open var finishMessage:String?
    
    weak var statusLabel:UILabel?
    weak var arrowImage:CALayer?
    weak var activityView:UIActivityIndicatorView?
    weak var backgroundView:UIView?
    
    public var headerHeight:CGFloat = 0
    
    required public init?(coder aDecoder: NSCoder) {
        self.isLoadingComplete = false
        self.state = EGOOPullRefreshState.egooPullRefreshComplete
        self.style = RefreshTableHeaderViewStyle.refreshTableHeaderViewStyleDefault
        super.init(coder: aDecoder)
    }
    
    public func setActivityStyle(_ style:UIActivityIndicatorView.Style?){//...
        if (activityView == nil) {
            return
        }
        activityView?.style = style!
        if style == UIActivityIndicatorView.Style.white{
            statusLabel?.textColor = UIColor.white
        }else{
            statusLabel?.textColor = TEXT_COLOR
        }
    }
    
    open func startCustomLoading(){
        
//        let shake:CABasicAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
//        shake.fromValue = NSNumber.init(value: 0)
//        shake.toValue = NSNumber.init(value: 2 * Double.pi)
//        shake.duration = 0.8
//        shake.autoreverses = false
//        shake.repeatCount = MAXFLOAT
//        rightImageView?.layer.add(shake, forKey: "shakeAnimation")
//
//        leftImageView?.animationDuration = 0.3
//        leftImageView?.startAnimating()
    }
    
    open func stopCustomLoading(){
//        rightImageView?.layer.removeAllAnimations()
//        leftImageView?.stopAnimating()
//        leftImageView?.image = self.param?.lImage
//        rightImageView?.isHidden = true
    }
    
    override open func layoutSubviews(){
        super.layoutSubviews()
 
        guard let statusLabel = self.statusLabel else {
            return
        }

        var lRect = statusLabel.frame
        lRect.origin.y = (self.height - lRect.height) / 2
        statusLabel.frame = lRect
        
        guard let activityView = self.activityView else {
            return
        }
        var aRect = activityView.frame
        aRect.origin.y = (self.height - aRect.height) / 2
        activityView.frame = aRect
        
    }
    
    open func initContent() {
        self.style = RefreshTableHeaderViewStyle.refreshTableHeaderViewStyleDefault
        
        self.finishMessage  = "刷新成功"
        let screen:UIScreen = UIScreen.main
        let view1 = UIView.init(frame: screen.bounds)
        self.addSubview(view1)
        self.backgroundView = view1
        var rect:CGRect  = self.backgroundView!.frame
        rect.origin.y = frame.size.height-rect.size.height
        self.backgroundView!.frame = rect
        
        self.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        self.backgroundColor = UIColor.clear
        
        let font = UIFont.systemFont(ofSize: 13)
        let size = "下拉即可刷新".textSize(attributes:[.font:font], constrainedToSize: CGSize.init(width: 100, height: 20))
        var label:UILabel! = UILabel.init(frame: CGRect.init(x: 0.0, y: (frame.size.height - size.height)/2, width: self.frame.size.width, height: size.height))
        
        label.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        label.font = font
        label.textColor = TEXT_COLOR;
        label.backgroundColor = UIColor.clear
        label.textAlignment = NSTextAlignment.center
        self.addSubview(label)
        self.statusLabel = label 
        
        let layer:CALayer = CALayer()
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        layer.frame = CGRect.init(x: 25.0, y: 20.0, width: 15.0, height: 30.0)
        layer.contentsGravity = CALayerContentsGravity.resizeAspect;
        let image1 = ZGImage("bundle://ZGUI/blueArrow.png")
        layer.contents =  image1?.cgImage!
        self.layer.addSublayer(layer)
        self.arrowImage = layer;
        CATransaction.commit()
        
        let view:UIActivityIndicatorView = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.white)
        view.frame = CGRect.init(x: 25.0, y: frame.size.height - 38.0, width: 20.0, height: 20.0)
        self.addSubview(view)
        self.activityView = view
        
        self.state = EGOOPullRefreshState.egooPullRefreshNormal
    }
    
    open func getSytyle() -> RefreshTableHeaderViewStyle {
        return .refreshTableHeaderViewStyleDefault
    }
 
    public override init(frame:CGRect){
        super.init(frame:frame)
        self.headerHeight = self.height
        self.initContent()
    }
    
    public func refreshLastUpdatedDate(){
        
     
        
    }
    
    open func setState(_ aState:EGOOPullRefreshState){
        switch aState {
        case EGOOPullRefreshState.egooPullRefreshPulling:
            self.statusLabel?.text = "松开即可更新..."
            CATransaction.begin()
            CATransaction.setAnimationDuration(FLIP_ANIMATION_DURATION)
            let mpiFloat:CGFloat = CGFloat.init((Double.pi/180)*180.0)
            self.arrowImage?.transform = CATransform3DMakeRotation(mpiFloat, 0.0, 0.0, 1.0)
            CATransaction.commit()
        case EGOOPullRefreshState.egooPullRefreshNormal:
            if (self.state == EGOOPullRefreshState.egooPullRefreshPulling) {
                CATransaction.begin()
                CATransaction.setAnimationDuration(FLIP_ANIMATION_DURATION)
                self.arrowImage?.transform = CATransform3DIdentity;
                CATransaction.commit()
            }
            self.statusLabel?.text = "下拉即可更新..."
            self.activityView?.stopAnimating()
            self.activityView?.isHidden = true
            
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            self.arrowImage?.transform = CATransform3DIdentity
            self.arrowImage?.isHidden = false
            CATransaction.commit()
            
            self.refreshLastUpdatedDate()
        case EGOOPullRefreshState.egooPullRefreshLoading:
            self.statusLabel?.text = "读取中..."
            
            self.activityView?.startAnimating()
            self.activityView?.isHidden = false
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            self.arrowImage?.isHidden = true
            CATransaction.commit()
        case EGOOPullRefreshState.egooPullRefreshComplete:
            self.statusLabel?.text =  "已到第一页"
            self.arrowImage?.isHidden = true
        case EGOOPullRefreshState.egooPullRefreshSuccess:
            self.activityView?.stopAnimating()
            self.activityView?.isHidden = true
            self.statusLabel?.text = self.finishMessage
            self.arrowImage?.isHidden = true
        default:
            return
        }
        self.state = aState
    }
    
//    #pragma mark -
//    #pragma mark ScrollView Methods
    public func egoRefreshScrollViewDidScroll(_ scrollView:UIScrollView,isDragging ispDragging:Bool){
        
        var offset:CGPoint = scrollView.contentOffset
        
        if (offset.y == 0) {
            offset.y = -self.headerHeight
            scrollView.contentOffset = offset;
        }
        self.setState(.egooPullRefreshLoading)
        UIView.animate(withDuration: 0.2) {
            scrollView.contentInset = UIEdgeInsets(top: self.headerHeight, left: 0.0, bottom: 0.0, right: 0.0)
        }
    }
    
    public func egoRefreshScrollViewDidScroll(_ scrollView:UIScrollView){
        guard let delegate = self.delegate else {
            return
        }
        if state == .egooPullRefreshLoading {
            var offset:CGFloat  = max(scrollView.contentOffset.y * -1, 0)
            offset = min(offset, self.headerHeight)
            scrollView.contentInset = UIEdgeInsets(top: offset, left: 0.0, bottom: 0.0, right: 0.0)
        } else if (scrollView.isDragging) {
            var _loading:Bool = false
            if delegate.responds(to: #selector(delegate.refreshTableHeaderDataSourceIsLoading(_:))) {
                _loading = delegate.refreshTableHeaderDataSourceIsLoading(self)
            }
            if (self.state == .egooPullRefreshPulling && scrollView.contentOffset.y > -self.headerHeight && scrollView.contentOffset.y < 0.0 && !_loading) {
                self.setState(.egooPullRefreshNormal)
            } else if (self.state == .egooPullRefreshNormal && scrollView.contentOffset.y < -self.headerHeight && !_loading) {
                self.setState(.egooPullRefreshPulling)
            }
            if (scrollView.contentInset.top != 0) {
                scrollView.contentInset = UIEdgeInsets.zero
            }
        }
    }
    
    public func egoRefreshScrollViewDidEndDragging(_ scrollView:UIScrollView){
        guard let delegate = self.delegate else {
            return
        }
        
        var _loading:Bool = false
  
        if delegate.responds(to: #selector(delegate.refreshTableHeaderDataSourceIsLoading(_:))) {
            _loading = delegate.refreshTableHeaderDataSourceIsLoading(self)
        }
        
        if scrollView.contentOffset.y <= -self.headerHeight && !_loading {
            if delegate.responds(to:#selector(delegate.refreshTableHeaderDidTriggerRefresh(_:))) {
                delegate.refreshTableHeaderDidTriggerRefresh(self)
            }
            
            if !isLoadingComplete {
                self.setState(.egooPullRefreshLoading)
            }
            DispatchQueue.main.async {
                scrollView.contentInset = UIEdgeInsets.init(top: self.headerHeight, left: 0, bottom: 0, right: 0)
            }
        }
         
    }
    
    public func egoRefreshScrollViewDataSourceDidFinishedLoading(_ scrollView:UIScrollView){
 
        guard let delegate = self.delegate else {
            return
        }
        if let didFinishedLoading = delegate.refreshTableHeaderDidFinishedLoading {
            didFinishedLoading(self)
        }
        //不要马上同步调用否则看不到scrollview返回的动画
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.01) {
            UIView.animate(withDuration: 0.2, animations: {
                scrollView.contentInset = .zero
            }, completion: {[weak self] (finished) in
                self?.resetToDefaultState(scrollView)
            })
        }
        self.setState(.egooPullRefreshNormal)
    }
    
    public func resetToDefaultState(_ scrollView:UIScrollView){ 
        scrollView.contentInset = .zero
        self.statusLabel?.text = "下拉即可更新..."
        self.statusLabel?.backgroundColor = UIColor.clear
        
        self.arrowImage?.isHidden = false
        self.arrowImage?.transform = CATransform3DIdentity
        self.setState(EGOOPullRefreshState.egooPullRefreshNormal)
    }
}

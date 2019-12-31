//
//  ZGRefreshTableFooterView.swift
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
//MARK:
let  RefreshViewHeight:CGFloat = 50.0
//let  TEXT_COLOR = UIColor.init(colorLiteralRed: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1)
//let  FLIP_ANIMATION_DURATION = 0.18

public enum PullFooterRefreshState {
    case oPullFooterRefreshPulling
    case oPullFooterRefreshNormal
    case oPullFooterRefreshLoading
    case oPullFooterRefreshLoadingComplete
}

//代理
@objc public protocol RefreshTableFooterDelegate : NSObjectProtocol{
    func refreshTableFooterDidTriggerRefresh(_ view:ZGRefreshTableFooterView)//使用默认参数标签，调用时直接写入参数
    func refreshTableFooterDataSourceIsLoading(_ view:ZGRefreshTableFooterView)-> Bool
    //可选实现代理方法
    @objc optional func refreshTableFooterDataSourceLastUpdated(_ view: ZGRefreshTableFooterView) -> Date
}


open class ZGRefreshTableFooterView: UIView {
    open weak var delegate:RefreshTableFooterDelegate?
    open var IsLoading:Bool
    open var IsLoadComplete:Bool
    open var needResetOffsetToZero:Bool
    open var state:PullFooterRefreshState
    open var arrowImage:CALayer?
    open var statusLabel:UILabel?
    open var lastUpdatedLabel:UILabel?
    
    open var activityView:UIActivityIndicatorView?

    required public init?(coder aDecoder: NSCoder) {
        self.IsLoading = false
        self.IsLoadComplete = false
        self.needResetOffsetToZero = false
        self.state = PullFooterRefreshState.oPullFooterRefreshLoadingComplete
        
        super.init(coder: aDecoder)
    }
    
    public func setActivityStyle(_ style:UIActivityIndicatorView.Style) {
        if self.activityView == nil {
            return
        }
        self.activityView?.style = style
        if (style == UIActivityIndicatorView.Style.white) {
            self.lastUpdatedLabel?.textColor = UIColor.white
        }else {
            self.lastUpdatedLabel?.textColor = TEXT_COLOR;
            self.statusLabel?.textColor = TEXT_COLOR;
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        //TODO:pad版的宏定义暂时未不全，需要等到不全后放开此处逻辑
//        if (TBIsPad()) {
//            CGFloat hPadding = 60;
//            CGSize size = [_statusLabel.text sizeWithFont:_statusLabel.font
//                constrainedToSize:CGSizeMake(200, 300)];
//            CGFloat width = size.width + hPadding + _arrowImage.frame.size.width;
//            CGFloat x = (self.width - width) / 2;
//            
//            [CATransaction begin];
//            [CATransaction setValue:(id) kCFBooleanTrue
//                forKey:kCATransactionDisableActions];
//            
//            CGRect rect = _arrowImage.frame;
//            rect.origin.x = x;
//            _arrowImage.frame = rect;
//            [CATransaction commit];
//            
//            rect = _activityView.frame;
//            rect.origin.x = x - 10;
//            _activityView.frame = rect;
//        }
        //FIXME:pad宏定义补全后要放开此处
    }
    public override init(frame:CGRect){
        self.IsLoading = false
        self.IsLoadComplete = false
        self.needResetOffsetToZero = true
        self.state = PullFooterRefreshState.oPullFooterRefreshLoadingComplete
        super.init(frame: frame)
        
        
        self.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        self.backgroundColor = UIColor.clear
        
        var label:UILabel! = UILabel.init(frame: CGRect.init(x: 0.0, y: Double(RefreshViewHeight - 20.0), width: Double(self.frame.size.width), height: 20.0))
        label.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        label.font = UIFont.boldSystemFont(ofSize: 12.0);
        
        label.textColor = TEXT_COLOR;
        label.shadowOffset = CGSize.init(width: 0, height: 1)
        label.backgroundColor = UIColor.clear
        label.textAlignment = NSTextAlignment.center
        self.addSubview(label)
        self.lastUpdatedLabel = label
        
        label = UILabel.init(frame: CGRect.init(x: 0.0, y: Double(RefreshViewHeight - 38.0), width: Double(self.frame.size.width), height: 20.0))
        label.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        label.font = UIFont.boldSystemFont(ofSize: 13.0);
        
        label.textColor = TEXT_COLOR;
        label.shadowOffset = CGSize.init(width: 0, height: 1)
        label.backgroundColor = UIColor.clear
        label.textAlignment = NSTextAlignment.center
        self.addSubview(label)
        self.statusLabel = label
        
        let layer:CALayer = CALayer()
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
    
        layer.frame = CGRect.init(x: 25.0, y: RefreshViewHeight - RefreshViewHeight, width: 15.0, height: 30.0)
        layer.contentsGravity = CALayerContentsGravity.resizeAspect;
        let image1 = ZGImage("bundle://ZGUI/blueArrow_down.png")
        layer.contents =  image1?.cgImage!
        
        if ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion.init(majorVersion: 8, minorVersion: 0, patchVersion: 0)) {
            if UIScreen.main.responds(to: #selector(getter: UIScreen.main.scale)) {
                layer.contentsScale = UIScreen.main.scale
            }
        }
        
        self.layer.addSublayer(layer)
        self.arrowImage = layer;
        CATransaction.commit()
        
        let view:UIActivityIndicatorView = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.white)
        view.frame = CGRect.init(x: 25.0, y: RefreshViewHeight - 38.0, width: 20.0, height: 20.0)
        self.addSubview(view)
        self.activityView = view
        
        self.IsLoadComplete = false
        self.IsLoading = false
        
        self.setState(PullFooterRefreshState.oPullFooterRefreshNormal)
    }
    
//    #pragma mark -
//    #pragma mark Setters
    public func refreshLastUpdatedDate(){
        if self.delegate != nil&&(self.delegate?.responds(to:#selector(self.delegate?.refreshTableFooterDataSourceLastUpdated(_:))))!{
            let date:Date?  = self.delegate?.refreshTableFooterDataSourceLastUpdated!(self)
            let formatter:DateFormatter = DateFormatter.init()
            formatter.amSymbol = "上午"
            formatter.pmSymbol = "下午"
            formatter.dateFormat = "yyyy/MM/dd hh:mm"
            formatter.dateFormat = "MM/dd hh:mm"
            self.lastUpdatedLabel?.text = String.init(format: "最后更新: %@", formatter.string(from: date!))
            UserDefaults.standard.set(self.lastUpdatedLabel?.text, forKey: "RefreshTableView_LastRefresh")
            UserDefaults.standard.synchronize()
        }else {
            
            self.lastUpdatedLabel?.text = nil
        }
    }
    
    public func setState(_ aState:PullFooterRefreshState){//...
        switch aState {
        case PullFooterRefreshState.oPullFooterRefreshPulling:
            self.statusLabel?.text = NSLocalizedString("list.footer.loosen", comment: "松开即可更新...")
            CATransaction.begin()
            CATransaction.setAnimationDuration(FLIP_ANIMATION_DURATION)
            
            let mpiFloat:CGFloat = CGFloat.init((Double.pi/180)*180.0)
            self.arrowImage?.transform = CATransform3DMakeRotation(mpiFloat, 0.0, 0.0, 1.0)
            CATransaction.commit()

        case PullFooterRefreshState.oPullFooterRefreshNormal:
            if (self.state == PullFooterRefreshState.oPullFooterRefreshPulling) {
                CATransaction.begin()
                CATransaction.setAnimationDuration(FLIP_ANIMATION_DURATION)
                self.arrowImage?.transform = CATransform3DIdentity;
                CATransaction.commit()
            }
            self.statusLabel?.text = NSLocalizedString("list.footer.default", comment: "上拉即可加载更多...")
            self.activityView?.stopAnimating()
            self.arrowImage?.isHidden = true
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            self.arrowImage?.isHidden = false
            self.arrowImage?.transform = CATransform3DIdentity
            CATransaction.commit()
            self.refreshLastUpdatedDate()

        case PullFooterRefreshState.oPullFooterRefreshLoading:
            self.statusLabel?.text = NSLocalizedString("list.footer.loadding", comment: "更多数据读取中...")
            
            self.activityView?.startAnimating()
            self.activityView?.isHidden = false
            CATransaction.begin()
            CATransition.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            self.arrowImage?.isHidden = true
            CATransaction.commit()
        case PullFooterRefreshState.oPullFooterRefreshLoadingComplete:
            self.statusLabel?.text = NSLocalizedString("list.footer.loadcomplete", comment: "已到最后一页")
            self.arrowImage?.isHidden = true
        }
        self.state = aState;
    }


    
//    #pragma mark -
//    #pragma mark ScrollView Methods
    public func egoRefreshScrollViewDidScroll(_ scrollView:UIScrollView){
        if (self.state == PullFooterRefreshState.oPullFooterRefreshLoading) {
//            var offset = -RefreshViewHeight;
//            if (scrollView.contentSize.height > scrollView.frame.size.height) {
//                offset = scrollView.contentSize.height - scrollView.frame.size.height;
//                offset = -offset - RefreshViewHeight;
//            }
            scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: CGFloat(RefreshViewHeight), right: 0.0)
        } else if (scrollView.isDragging) {
            var loading:Bool = false
            
            if self.delegate != nil&&(self.delegate?.responds(to:#selector(self.delegate?.refreshTableFooterDataSourceIsLoading(_:))))!{
               loading = self.delegate!.refreshTableFooterDataSourceIsLoading(self)
            }
            
            let compareHeight_1:CGFloat = scrollView.contentOffset.y + (scrollView.frame.size.height)
            var compareHeight_2:CGFloat = scrollView.contentSize.height + RefreshViewHeight
            if (scrollView.contentSize.height < scrollView.frame.size.height) {
                compareHeight_2 = scrollView.frame.size.height + RefreshViewHeight;
            }
            if (self.state == PullFooterRefreshState.oPullFooterRefreshPulling
                && compareHeight_1 < compareHeight_2
                && scrollView.contentOffset.y > 0.0
                    && !loading) {
                self.setState(PullFooterRefreshState.oPullFooterRefreshNormal)
            } else if (self.state == PullFooterRefreshState.oPullFooterRefreshNormal
                && compareHeight_1 > compareHeight_2
                && !loading) {
               self.setState(PullFooterRefreshState.oPullFooterRefreshPulling)
            }
            
            if (scrollView.contentInset.bottom != 0) {
                scrollView.contentInset = UIEdgeInsets.zero
            }
        }
    }
    //当用户停止拖动，并且手指从屏幕中拿开的的时候调用此方法
    public func egoRefreshScrollViewDidEndDragging(_ scrollView:UIScrollView){//...
        var loading:Bool = false
        if self.delegate != nil&&(self.delegate?.responds(to:#selector(self.delegate?.refreshTableFooterDataSourceIsLoading(_:))))!{
            loading = self.delegate!.refreshTableFooterDataSourceIsLoading(self)
        }
        
        let compareHeight_1:CGFloat = scrollView.contentOffset.y + (scrollView.frame.size.height)
        var compareHeight_2:CGFloat = scrollView.contentSize.height + RefreshViewHeight
        if (scrollView.contentSize.height < scrollView.frame.size.height) {
            compareHeight_2 = scrollView.frame.size.height + RefreshViewHeight;
        }
        
        if (compareHeight_1 > compareHeight_2 && !loading) {
           self.setState(PullFooterRefreshState.oPullFooterRefreshLoading)
        }
        
        UIView.animate(withDuration: 0.2){
            scrollView.contentInset = UIEdgeInsets.init(top: -RefreshViewHeight, left: 0, bottom: 0, right: 0)
        }
        if self.delegate != nil&&(self.delegate?.responds(to:#selector(self.delegate?.refreshTableFooterDidTriggerRefresh(_:))))!{
            self.delegate!.refreshTableFooterDidTriggerRefresh(self)
        }
    }
    
    //当页面刷新完毕调用此方法，[delegate RefreshScrollViewDataSourceDidFinishedLoading: scrollView];
    public func egoRefreshScrollViewDataSourceDidFinishedLoading(_ scrollView:UIScrollView?){//...
        if(scrollView != nil){
            //TODO:此处写法需要斟酌
            UIView.animate(withDuration: 0.3){
                scrollView?.contentInset = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
            }
            //FIXME:需要查验此处写法
        }
        
        //[self removeFromSuperview];
        self.frame = CGRect.init(x: self.frame.size.width, y: self.frame.size.height, width: self.frame.size.width, height: (scrollView?.contentSize.height)!)
        
        self.setState(PullFooterRefreshState.oPullFooterRefreshNormal)
    }
    
    
    
    //数据加载完成时调用
    public func loadDataComplete(){
        self.statusLabel?.text = NSLocalizedString("list.footer.loadcomplete", comment: "已到最后一页")
        self.activityView?.stopAnimating()
        self.arrowImage?.isHidden = true
        self.IsLoadComplete = true
    }

    public func resetState(){
        self.statusLabel?.text = NSLocalizedString("list.footer.default", comment: "上拉即可加载更多...")
        self.statusLabel?.backgroundColor = UIColor.clear
        self.activityView?.startAnimating()
        self.IsLoadComplete = false
        self.arrowImage?.isHidden = false
    }
    
    public func resetToDefaultState(_ scrollView:UIScrollView){//...
        if self.needResetOffsetToZero {
            scrollView.contentInset = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        }
        self.statusLabel?.text = NSLocalizedString("list.footer.default", comment: "上拉即可加载更多...")
        self.statusLabel?.backgroundColor = UIColor.clear
        self.activityView?.stopAnimating()
        self.IsLoadComplete = false
        self.arrowImage?.isHidden = false
        var height:CGFloat = scrollView.contentSize.height
        if (height < scrollView.frame.size.height) {
            height = scrollView.frame.size.height
        }
        self.frame = CGRect.init(x: self.frame.size.width, y: height, width: self.frame.size.width, height: self.frame.size.height)
        self.arrowImage?.transform = CATransform3DIdentity;
        self.setState(PullFooterRefreshState.oPullFooterRefreshNormal)
    }
    
    public func stopAnimate (_ scrollView:UIScrollView){//...
        if self.IsLoadComplete {
            self.loadDataComplete()
        }else{
           scrollView.contentInset = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
            self.statusLabel?.text = NSLocalizedString("list.footer.default", comment: "上拉即可加载更多...")
            
            self.statusLabel?.backgroundColor = UIColor.clear
            self.activityView?.stopAnimating()
            self.IsLoadComplete = false
            self.setState(PullFooterRefreshState.oPullFooterRefreshNormal)
            self.arrowImage?.isHidden = false
            self.frame = CGRect.init(x: self.frame.size.width, y: scrollView.contentSize.height, width: self.frame.size.width, height: self.frame.size.height)
            self.arrowImage?.transform = CATransform3DIdentity;
            self.setState(PullFooterRefreshState.oPullFooterRefreshNormal)
        }
    }
}

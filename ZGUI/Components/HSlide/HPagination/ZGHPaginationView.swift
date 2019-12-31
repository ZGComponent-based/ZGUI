//
//  ZGHPaginationView.swift
//  ZGUI
//  -- ZGHPaginationView
//        --HeaderView 
//        --ZGTopScrollBar
//        --ZGHPaginationScrollView
//  ZGHPaginationScrollView需要占据整个窗口大小
//  ZGHPaginationScrollView的contentOffsetY开始是内容的显示部分
//  参考：
//  @link https://github.com/weijingyunIOS/HHHorizontalPagingView
//  Created by zhaogang on 2018/7/25.
//

import UIKit

public protocol ZGHPaginationViewDelegate: NSObjectProtocol {

    func getHeaderHeight() -> CGFloat
    func getTopScrollBarHeight() -> CGFloat
    func getCurrentScrollView() -> UIScrollView?
    func isSwitching() -> Bool
}

class DynamicItem: NSObject, UIDynamicItem {
    var center: CGPoint = .zero
    var transform: CGAffineTransform = CGAffineTransform.init()
    var bounds: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
}

public class ZGHPaginationView<T: ZGHPaginationSubViewDelegate, U: ZGHPaginationScrollViewDelegate>: UIView, UIGestureRecognizerDelegate where U.SubPageViewType == T {
    public weak var delegate: ZGHPaginationViewDelegate?

    public var isDragging: Bool = false
    public var headerView: UIView?
    var currentTouchView: UIView?
    var currentTouchSubSegment: UIView?
    var currentScrollView: UIScrollView?
    
    var allowPullToRefresh: Bool = false
    // 页面向上滚动后 segment据顶部的距离
    public var segmentTopSpace: CGFloat = ZGUIUtil.statusBarHeight() + 44
    public var getOffSetPyHandle:((CGFloat) -> Void)?
    var headerOriginYConstraint: NSLayoutConstraint?
    var contentOffset:CGPoint = .zero
    var observeDict = [UIScrollView:[NSKeyValueObservation]]()

    lazy var animator: UIDynamicAnimator = {
        return UIDynamicAnimator()
    }()

    var inertialBehavior: UIDynamicItemBehavior?

    public lazy var paginationScrollView: ZGHPaginationScrollView<T, U> = {
        let rect = CGRect.init(x: 0, y: 0, width: self.width, height: self.height)
        let pagingScrollView = ZGHPaginationScrollView<T, U>.init(frame: rect)
        pagingScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(pagingScrollView);
        self.sendSubviewToBack(pagingScrollView)
        return pagingScrollView
    }()

    public lazy var topScrollBar: ZGTopScrollBar = {
        // 这里初始给个比较高的值，避免collectionView先加载而出现的警告
        // the behavior of the UICollectionViewFlowLayout is not defined because:
        // the item height must be less than the height of the UICollectionView minus the section
        // insets top and bottom values, minus the content insets top and bottom values.
        let rect = CGRect.init(x: 0, y: 0, width: self.width, height: 40)
        let segmentView = ZGTopScrollBar.init(frame: rect)
        self.addSubview(segmentView)
        return segmentView
    }()

    public override func layoutSubviews() {
        super.layoutSubviews()
//        guard let delegate = self.delegate else {
//            return
//        }
//
//        var headerRect = CGRect.zero
//        let headerHeight = delegate.getHeaderHeight()
//        if let headerView = self.headerView {
//            if headerHeight > 0 {
//                headerRect.size.height = headerHeight
//                headerRect.size.width = self.width
//                headerRect.origin = .zero
//                self.headerView?.frame = headerRect
//            }
//        }
//        let segmentHeight = delegate.getTopScrollBarHeight()
//        var segmentRect = CGRect.zero
//        if segmentHeight > 0 {
//            segmentRect = self.topScrollBar.frame
//            segmentRect.size.width = self.width
//            segmentRect.size.height = segmentHeight
//            segmentRect.origin.y = headerRect.maxY
//            self.topScrollBar.frame = segmentRect
//        }
//        var contentRect = self.paginationScrollView.frame
//        contentRect.size.width = self.width
//        contentRect.size.height = self.height - segmentRect.maxY
//        contentRect.origin.x = 0
//        contentRect.origin.y = segmentRect.maxY
//        self.paginationScrollView.frame = contentRect
    }

    func scrollEnable(_ enabled: Bool) {
        if (enabled) {
            self.topScrollBar.isUserInteractionEnabled = true
            self.paginationScrollView.isScrollEnabled = true
        } else {
            self.topScrollBar.isUserInteractionEnabled = false
            self.paginationScrollView.isScrollEnabled = false
        }
    }
    
    func releaseObserve() {
        let values = self.observeDict.values
        
        for objserveArr in values {
            
            for item in objserveArr {
                item.invalidate()
            }
        }
    }

    deinit {
        releaseObserve()
    }

    func segmentViewEvent() {
        if let currentTouchSubSegment = self.currentTouchSubSegment {

        }
    }
    
    @objc func pan(_ sender:UIPanGestureRecognizer) {
        guard let hView = sender.view, let delegate = self.delegate,
            let currentScrollView = self.currentScrollView else {
            return
        }
        // 偏移计算
        let point = sender.translation(in: hView)
        let contentOffset = currentScrollView.contentOffset
        let border = -delegate.getHeaderHeight() - delegate.getTopScrollBarHeight()
        let offsety:CGFloat = contentOffset.y - point.y * (1/contentOffset.y * border * 0.8);
        currentScrollView.contentOffset = CGPoint(x:contentOffset.x, y:offsety)
        if sender.state == .ended || sender.state == .failed {
            if contentOffset.y <= border {
                // 如果处于刷新
//                if (currentScrollView.hhh_isRefresh) {
//                    return;
//                }
                // 模拟弹回效果
                UIView.animate(withDuration: 0.35) {
                    currentScrollView.contentOffset = CGPoint(x:contentOffset.x, y:border)
                    self.layoutIfNeeded()
                }
            } else {
                // 模拟减速滚动效果
                let velocity = sender.velocity(in: hView).y
                self.deceleratingAnimator(velocity: velocity)
            }
        }
        // 清零防止偏移累计
        sender.setTranslation(.zero, in: hView)
    }
    
    public func configureHeaderView() {
        guard let headerView = self.headerView, let delegate = self.delegate else {
            return
        }
        let headerHeight = delegate.getHeaderHeight()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(headerView)
        
        // 左对齐
        let leftConstraint = NSLayoutConstraint(item: headerView,
                                    attribute: .left,
                                    relatedBy: .equal,
                                    toItem: self,
                                    attribute: .left,
                                    multiplier: 1,
                                    constant: 0)
        let rightConstraint = NSLayoutConstraint(item: headerView,
                                    attribute: .right,
                                    relatedBy: .equal,
                                    toItem: self,
                                    attribute: .right,
                                    multiplier: 1,
                                    constant: 0)
        let topConstraint = NSLayoutConstraint(item: headerView,
                                    attribute: .top,
                                    relatedBy: .equal,
                                    toItem: self,
                                    attribute: .top,
                                    multiplier: 1,
                                    constant: 0)
        let heightConstraint = NSLayoutConstraint(item: headerView,
                                    attribute: .height,
                                    relatedBy: .equal,
                                    toItem: nil,
                                    attribute: .height,
                                    multiplier: 1,
                                    constant: headerHeight)
        self.addConstraint(leftConstraint)
        self.addConstraint(rightConstraint)
        self.addConstraint(topConstraint)
        headerView.addConstraint(heightConstraint)
        self.headerOriginYConstraint = topConstraint
   
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        pan.delegate = self
        headerView.addGestureRecognizer(pan)
    }
    
    public func configTopScrollBar() {
        guard let delegate = self.delegate else {
            return
        }
        let segmentHeight = delegate.getTopScrollBarHeight()
        // 左对齐
        self.topScrollBar.translatesAutoresizingMaskIntoConstraints = false
        let leftConstraint = NSLayoutConstraint(item: self.topScrollBar,
                                                attribute: .left,
                                                relatedBy: .equal,
                                                toItem: self,
                                                attribute: .left,
                                                multiplier: 1,
                                                constant: 0)
        let rightConstraint = NSLayoutConstraint(item: self.topScrollBar,
                                                 attribute: .right,
                                                 relatedBy: .equal,
                                                 toItem: self,
                                                 attribute: .right,
                                                 multiplier: 1,
                                                 constant: 0)
        let topConstraint = NSLayoutConstraint(item: self.topScrollBar,
                                               attribute: .top,
                                               relatedBy: .equal,
                                               toItem: self.headerView != nil ? self.headerView : self,
                                               attribute: self.headerView != nil ? .bottom : .top,
                                               multiplier: 1,
                                               constant: 0)
        let heightConstraint = NSLayoutConstraint(item: self.topScrollBar,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .height,
                                                  multiplier: 1,
                                                  constant: segmentHeight)
        self.addConstraint(leftConstraint)
        self.addConstraint(rightConstraint)
        self.addConstraint(topConstraint)
        self.topScrollBar.addConstraint(heightConstraint)
    }
    
    func contentOffsetWithPan(oldPoint: CGPoint?, newPoint: CGPoint?) {
        guard let delegate = self.delegate,
            let currentScrollView = self.currentScrollView,
            let headerOriginYConstraint = self.headerOriginYConstraint else {
                return
        }
        if delegate.isSwitching() {
            return
        }
        var oldPoint1 = CGPoint.zero
        var newPoint1 = CGPoint.zero
        if let p1 = newPoint {
            newPoint1 = p1
        }
        if let p1 = oldPoint {
            oldPoint1 = p1
        } 
        
        self.currentTouchView = nil
        self.currentTouchSubSegment = nil
 
        let oldOffsetY: CGFloat = oldPoint1.y
        let newOffsetY: CGFloat = newPoint1.y
        let deltaY: CGFloat = newOffsetY - oldOffsetY
        
        let headerViewHeight: CGFloat = delegate.getHeaderHeight()
        let segmentBarHeight: CGFloat = delegate.getTopScrollBarHeight()
        let headerDisplayHeight: CGFloat = headerViewHeight + headerOriginYConstraint.constant
        //
        var py: CGFloat = 0
        if (deltaY >= 0) { //向上滚动
            if (headerDisplayHeight - deltaY <= self.segmentTopSpace) {
                py = -headerViewHeight + self.segmentTopSpace
            } else {
                py = headerOriginYConstraint.constant - deltaY
            }
            if (headerDisplayHeight <= self.segmentTopSpace) {
                py = -headerViewHeight + self.segmentTopSpace
            }
            
            if (!self.allowPullToRefresh) {
                headerOriginYConstraint.constant = py
                
            } else if (py < 0 /*&& !self.currentScrollView.hhh_isRefresh && !self.currentScrollView.hhh_startRefresh*/) {
                headerOriginYConstraint.constant = py
                
            } else {
                
                if (currentScrollView.contentOffset.y >= -headerViewHeight - segmentBarHeight) {
                    //                    currentScrollView.hhh_startRefresh = NO
                }
                headerOriginYConstraint.constant = 0
            }
            
        } else {            //向下滚动
            
            if (headerDisplayHeight + segmentBarHeight < -newOffsetY) {
                py = -headerViewHeight - segmentBarHeight - currentScrollView.contentOffset.y
                
                if !self.allowPullToRefresh {
                    headerOriginYConstraint.constant = py
                    
                } else if py < 0 {
                    headerOriginYConstraint.constant = py
                } else {
                    //                self.currentScrollView.hhh_startRefresh = YES;
                    headerOriginYConstraint.constant = 0
                }
            }
            
        }
        if let b = self.getOffSetPyHandle {
            b(headerOriginYConstraint.constant)
        }
        self.contentOffset = currentScrollView.contentOffset
        //        if ([self.delegate respondsToSelector:@selector(pagingView:scrollTopOffset:)]) {
        //            [self.delegate pagingView:self scrollTopOffset:self.contentOffset.y];
        //        }
        
        //        if let headerView = self.headerView {
        //            var rect = headerView.frame
        //            rect.origin.y = headerOriginYConstraint.constant
        //            headerView.frame = rect
        //        }
    }
    
    func contentInsetWithPan() {
        guard let currentScrollView = self.currentScrollView,
            let delegate = self.delegate else {
            return
        }
        if delegate.isSwitching() {
            return
        }
        let segmentBarHeight = delegate.getTopScrollBarHeight()
        let headerViewHeight = delegate.getHeaderHeight()
        if(self.allowPullToRefresh || currentScrollView.contentOffset.y > -segmentBarHeight) {
            return
        }
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.headerOriginYConstraint?.constant = -headerViewHeight-segmentBarHeight-currentScrollView.contentOffset.y
            self?.layoutIfNeeded()
            self?.headerView?.layoutIfNeeded()
            self?.topScrollBar.layoutIfNeeded()
        }
    }
    
    func contentScrollViewPan(state:UIGestureRecognizer.State) {
        guard let delegate = self.delegate else {
            return
        }
        if delegate.isSwitching() {
            return
        }
        self.paginationScrollView.isScrollEnabled = true
        //failed说明是点击事件
        if (state == .failed) {
            if let currentTouchSubSegment = self.currentTouchSubSegment {
                self.segmentViewEvent()
            } else if let currentTouchView = self.currentTouchView {
                // 处理点击事件
            }
            self.currentTouchView = nil;
            self.currentTouchSubSegment = nil;
            
        } else if (state == .cancelled || state == .ended) {
            self.isDragging = false
        }
    }
    
    func configurePaginationScrollView(_ scrollView: UIScrollView, pageKey:String) {
        guard let delegate = self.delegate else {
            return
        }
 
        self.releaseObserve()
 
        let headerHeight = delegate.getHeaderHeight()
        let segmentHeight = delegate.getTopScrollBarHeight()
 
        let offset:CGFloat = headerHeight + segmentHeight
        let previousOffset = scrollView.contentOffset
        var headerDisplayHeight:CGFloat = 0
        if let c1 = self.headerOriginYConstraint?.constant {
            headerDisplayHeight = headerHeight + c1
        }
        let contentOffsetDeta = headerDisplayHeight + segmentHeight
        // 加到字典中
        
        scrollView.contentInset = UIEdgeInsets(top: offset, left: 0, bottom: scrollView.contentInset.bottom, right: 0)
        if previousOffset.y <= 0 {
            scrollView.contentOffset = CGPoint(x: 0, y: -contentOffsetDeta)
        } else if previousOffset.y != 0 {
            scrollView.contentOffset = CGPoint(x: 0, y: previousOffset.y)
        }
        
        let panGestureObservation = scrollView.panGestureRecognizer.observe(\.state, options: .new) { [weak self] (_, change) in
            
            guard let state = change.newValue else {
                return
            }
            self?.contentScrollViewPan(state:state)
        }
        let contentOffsetObservation = scrollView.observe(\.contentOffset, options: [.new, .old]) {[weak self] (_, change) in
            self?.contentOffsetWithPan(oldPoint: change.oldValue, newPoint: change.newValue)
        }
        
        let contentInsetObservation = scrollView.observe(\.contentInset, options: .new) {[weak self] (_, change) in
            self?.contentInsetWithPan()
        }
        self.observeDict[scrollView] = [panGestureObservation, contentInsetObservation, contentOffsetObservation]
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else {
            return nil
        }
        // 如果处于刷新中，作用在headerView上的手势不响应在currentScrollView上
        //        if (self.currentScrollView.hhh_isRefresh) {
        //            return view;
        //        }
        if let headerView = self.headerView {
            if view.isDescendant(of: headerView) {
                self.paginationScrollView.isScrollEnabled = false
                self.currentTouchView = nil
            }
        }
        return view
    }
    
    func findSubSegmentView(_ view: UIView) -> UIView? {
        guard let cells = self.topScrollBar.collectionView?.visibleCells else {
            return nil
        }
        
        
        return nil
    }
    
    func animationForDeceleratingAnimator(item:DynamicItem) {
        guard let currentScrollView = self.currentScrollView, let inertialBehavior = self.inertialBehavior else {
            return
        }
        let maxOffset:CGFloat = currentScrollView.contentSize.height - currentScrollView.bounds.size.height
        let contentOffset = currentScrollView.contentOffset
        let speed = inertialBehavior.linearVelocity(for: item).y
        var offset = contentOffset.y - speed
        
        if speed >= -0.2 {
            self.animator.removeBehavior(inertialBehavior)
            self.inertialBehavior = nil
        } else if offset >= maxOffset {
            self.animator.removeBehavior(inertialBehavior)
            self.inertialBehavior = nil
            offset = maxOffset
            // 模拟减速滚动到scrollView最底部时，先拉一点再弹回的效果
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                currentScrollView.contentOffset = CGPoint(x:contentOffset.x, y:offset - speed)
                self?.layoutIfNeeded()
            }) { (finished) in
                UIView.animate(withDuration: 0.25, animations: { [weak self] in
                    currentScrollView.contentOffset = CGPoint(x:contentOffset.x, y:offset)
                    self?.layoutIfNeeded()
                })
            }
        }else{
            currentScrollView.contentOffset = CGPoint(x:contentOffset.x, y:offset)
        }
    }

    func deceleratingAnimator(velocity: CGFloat) {
        if let inertialBehavior = self.inertialBehavior {
            self.animator.removeBehavior(inertialBehavior)
        }
        let item = DynamicItem()
        let inertialBehavior = UIDynamicItemBehavior(items: [item])
        let velocityPoint = CGPoint(x: 0, y: velocity * 0.025)
        inertialBehavior.addLinearVelocity(velocityPoint, for: item)
        // 通过尝试取2.0比较像系统的效果
        inertialBehavior.resistance = 2

        inertialBehavior.action = { [weak self] in
            self?.animationForDeceleratingAnimator(item: item)
        };
        self.inertialBehavior = inertialBehavior
        self.animator.addBehavior(inertialBehavior)
    }
    
    //MARK: - header pan delegate
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer, let headerView = self.headerView {
            let point = pan.translation(in: headerView)
            if fabs(point.y) <= fabs(point.x) {
                return false
            }
        }
        
        return true

    }
 
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

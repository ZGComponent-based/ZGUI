//
//  ZGHPaginationScrollView.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/3/22.
//
//

import UIKit

public protocol ZGHPaginationSubViewDelegate : class, Hashable {
    
    func getView() -> UIView;  //返回显示的view
    func setObject(_ object: Any); //刷新界面
    
    var index: Int {get set}; //索引
    
    func prepareForReuse(); //被移入复用池
    func reuseIdentifier() -> String; //复用标识
}

public protocol ZGHPaginationScrollViewDelegate: UIScrollViewDelegate {
    associatedtype SubPageViewType;
    
    //dequeueReusablePageView(withIdentifier identifier:String) -> T?
    func getPageView(atIndex index:Int) -> SubPageViewType?;
    
    func willShow(pageView:SubPageViewType);
    func didShow(pageView:SubPageViewType);
    func didHide(pageView:SubPageViewType);
}
public extension ZGHPaginationScrollViewDelegate {
    func willShow(pageView:SubPageViewType) { //间接使该方法为可选类型
    }
    func didShow(pageView:SubPageViewType) { //间接使该方法为可选类型
    }
    func didHide(pageView:SubPageViewType) { //间接使该方法为可选类型
    }
}



open class ZGHPaginationScrollView<T : ZGHPaginationSubViewDelegate, U : ZGHPaginationScrollViewDelegate> : UIScrollView, UIScrollViewDelegate where U.SubPageViewType==T {
    
    public var enableDragToRight: Bool = false;
    public weak var slideDelegate: U?
    
    public var reusePageSet : Set<T> = Set();
    public var visiblePageSet : Set<T> = Set();
    
    public var selectIndex:Int = 0;
    public var isManualShow: Bool = false;
    
    private var _items : Array<Any>?;
    open var items : Array<Any>? {
        set(newItem) {
            self.cleanAndRecycleAllPageView();
            _items = newItem;
            self.contentSize = self.contentSizeForScrollView();
            
            guard let _ = _items else {
                return;
            }
            let count = _items!.count;
            guard count > 0 else {
                return;
            }
            
            self.selectPageView(withIndex: self.selectIndex, animated: false, forceReload: true, isInit: true);
        }
        get {
            return _items;
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame);
        self.initContent();
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.initContent();
    }
    
    open func initContent() {
        self.isPagingEnabled = true;
        self.showsVerticalScrollIndicator = false;
        self.showsHorizontalScrollIndicator = false;
        self.isDirectionalLockEnabled = true;
        self.canCancelContentTouches = false;
        self.bounces = false;
        self.scrollsToTop = false;
        self.enableDragToRight = true;
        
        super.delegate = self;
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews();
        self.contentSize = self.contentSizeForScrollView();
    }
    
    //MARK: - select pageView with index
    
    public func currentPageView() ->T? {
        if self.visiblePageSet.count>0 {
            return self.visiblePageSet.first
        }
        return nil
    }
    
    //移动到选中的index
    open func selectPageView(withIndex index:Int, animated:Bool, forceReload:Bool = false,isInit:Bool = false) {
        
        guard let _ = self.items else {
            return;
        }
        let count = self.items!.count;
        
        var toIndex = index;
        if index <= 0 || index >= count  {
            toIndex = 0;
        }
        if toIndex == selectIndex && !forceReload {
            return
        }
        self.selectIndex = toIndex;
        
        let currentPageView = self.visiblePageSet.first;
        let currentIndex = currentPageView?.index ?? 0;
        
        let pageDistance = currentIndex - toIndex;
        if abs(pageDistance)>1 {
            //需要移动大于一页时，手动修改frame显示
            self.manualShowPage(withIndex: toIndex, currentIndex:currentIndex, animated:animated);
        }else if abs(pageDistance)==1 {
            //需要移动等于一页时，自动走scrollViewDidScroll显示
            let rect = frameForPage(atIndex: toIndex);
            self.scrollRectToVisible(rect, animated: animated);
        }else {
                //说明不需要移动，但是需要刷新视图
            if isInit{
                //回收当前显示的视图
                self.cleanAndRecycleAllPageView();
                //显示新的视图
                let _ = self.showPageView(atIndex: toIndex);
                if let pageView = self.slideDelegate?.getPageView(atIndex: index)  {
                    self.slideDelegate?.didShow(pageView: pageView)
                }
            }
        }
    }
    
    
    //MARK: show pageView
    
    override open func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        super.scrollRectToVisible(rect, animated: animated)
        
        //如果没有动画则不会调用代理, 手动调用didshow方法
        if !animated {
            self.scrollDidStop()
        }
    }
    
    //需要移动大于一页时，手动修改frame显示
    open func manualShowPage(withIndex index:Int, currentIndex:Int, animated:Bool) {
        self.isManualShow = true;
        
        let pageView :T! = self.showPageView(atIndex: index);
        guard let _ = pageView else {
            return;
        }
        
        let targetIndex = index>currentIndex ? currentIndex+1 : currentIndex-1;
        pageView.getView().frame = self.frameForPage(atIndex: targetIndex);
        
        var rect = self.bounds;
        rect.origin.x = rect.size.width * CGFloat(targetIndex);
        self.scrollRectToVisible(rect, animated: animated);
    }
    
    //需要移动不大于一页时，自动走scrollViewDidScroll显示
    open func autoShowPage() {
        
        if self.isManualShow {
            //如果是手动移的，忽略
            return;
        }
        
        let count = self.items?.count ?? 0;
        guard count > 0 else {
            return;
        }
        
        let visibleBounds = self.bounds;
        let minX = visibleBounds.minX;
        let maxX = visibleBounds.maxX;
        let width = visibleBounds.width;
        
        var firstIndex = Int( floor(minX / width) );
        var secondIndex = Int( floor((maxX-1) / width) );
        
        firstIndex = max(firstIndex, 0); //不能小于0
        secondIndex = min(secondIndex, count-1); //不能大于count-1
        
        //回收不在显示的
        for pageView in self.visiblePageSet {
            let viewIndex = pageView.index;
            //不在显示范围内
            if viewIndex<firstIndex || viewIndex>secondIndex {
                self.movePageViewToReusePool(pageView: pageView);
            }
        }
        
        // 是否需要显示新的视图
        for index in [firstIndex,secondIndex] {
            let isShow = self.isShowPageView(atIndex: index);
            if isShow {
                continue;
            }
            let _ = self.showPageView(atIndex: index);
        }
    }
    
    open func showPageView(atIndex index:Int) -> T? {
        let pageView :T! = self.slideDelegate?.getPageView(atIndex: index)
        guard let _ = pageView else {
            return nil;
        }
        self.configure(pageView: pageView, index: index);
        self.addSubview(pageView.getView());
        self.visiblePageSet.insert(pageView);
        self.slideDelegate?.willShow(pageView: pageView);
        return pageView;
    }
    
    //配置pageView数据，刷新页面
    open func configure(pageView:T, index:Int) {
        pageView.index = index;
        pageView.getView().frame = self.frameForPage(atIndex: index);
        let obj = self.items?[index];
        guard let _ = obj else {
            return;
        }
        pageView.setObject(obj!);
    }
    
    //滑动停止,处理visiblePageSet和reusePageSet等
    open func scrollDidStop() {
        
        if self.isManualShow {
            self.isManualShow = false;
            for pageView in self.visiblePageSet {
                if pageView.index != self.selectIndex {
                    self.movePageViewToReusePool(pageView: pageView);
                }
            }
            
            let currentPageView :T! = self.visiblePageSet.first;
            guard let _ = currentPageView else {
                return;
            }
            let frame = self.frameForPage(atIndex: currentPageView.index);
            currentPageView.getView().frame = frame;
            self.scrollRectToVisible(frame, animated: false);
        }
        
        let currentPageView :T! = self.visiblePageSet.first;
        guard let _ = currentPageView else {
            return;
        }
        self.selectIndex = currentPageView.index;
        self.slideDelegate?.didShow(pageView: currentPageView);
    }
    
    // 根据index判断pageView是否已经显示
    open func isShowPageView(atIndex index:Int) -> Bool {
        var isShow = false;
        
        for pageView in self.visiblePageSet {
            if pageView.index == index {
                isShow = true;
                break;
            }
        }
        return isShow;
    }
    
    //MARK: - reuse pageView
    
    //复用pageView，实现func getPageView(atIndex index:Int) -> SubPageViewType?时一定要调该方法。
    open func dequeueReusablePageView(withIdentifier identifier:String) -> T? {
        for pageView in self.reusePageSet {
            if pageView.reuseIdentifier() == identifier {
                self.removePageViewFromReusePool(pageView: pageView);
                return pageView;
            }
        }
        return nil;
    }
    
    
    //将pageView移入复用池
    open func movePageViewToReusePool(pageView:T) {
        self.reusePageSet.insert(pageView);
        pageView.getView().removeFromSuperview();
        pageView.prepareForReuse();
        
        self.visiblePageSet.remove(pageView);
        self.slideDelegate?.didHide(pageView: pageView);
    }
    
    //将pageView移出复用池
    open func removePageViewFromReusePool(pageView:T) {
        self.reusePageSet.remove(pageView);
        self.visiblePageSet.insert(pageView);
    }
    
    //清空子视图，将visiblePageSet移入复用池，然后清空
    open func cleanAndRecycleAllPageView() {
        
        //将visiblePageSet移入复用池，然后清空
        for pageView in self.visiblePageSet {
            self.movePageViewToReusePool(pageView: pageView);
        }
    }
    
    
    //MARK: - calculate frame and contentSize
    
    open func frameForPage(atIndex index:Int) -> CGRect {
        var bounds = self.bounds;
        bounds.origin.x = bounds.size.width * CGFloat(index);
        return bounds;
    }
    
    open func contentSizeForScrollView() -> CGSize {
        let size = self.frame.size;
        let count = CGFloat(self.items?.count ?? 0);
        return CGSize(width:size.width * count, height:size.height);
    }
    
    
    
    //MARK: - scrollView delegate
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.autoShowPage();
        if let d1 = self.slideDelegate as? ZGBaseScrollPageVCL {
            d1.scrollViewDidScroll(scrollView)
        }
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollDidStop();
        if let d1 = self.slideDelegate as? ZGBaseScrollPageVCL {
            d1.scrollViewDidEndDecelerating(scrollView);
        }
    }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.scrollDidStop();
        if let d1 = self.slideDelegate as? ZGBaseScrollPageVCL {
            d1.scrollViewDidEndScrollingAnimation(scrollView);
        }
    }
    
    //MARK: -
    
    open func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.slideDelegate?.scrollViewDidZoom?(scrollView);
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let d1 = self.slideDelegate as? ZGBaseScrollPageVCL {
            d1.scrollViewWillBeginDragging(scrollView)
        }
    }
    
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.slideDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset);
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.slideDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate);
    }
    
    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.slideDelegate?.scrollViewWillBeginDecelerating?(scrollView);
    }
    
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.slideDelegate?.viewForZooming?(in: scrollView);
    }
    
    open func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        self.slideDelegate?.scrollViewWillBeginZooming?(scrollView, with: view);
    }
    
    open func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.slideDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale);
    }
    
    open func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if let scrollsToTop=self.slideDelegate?.scrollViewShouldScrollToTop?(scrollView) {
            return scrollsToTop;
        }
        return self.scrollsToTop;
    }
    
    open func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        self.slideDelegate?.scrollViewDidScrollToTop?(scrollView);
    }
    
    
    //MARK: - gestureRecognizer delegate
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer {
            let gr = gestureRecognizer as! UIPanGestureRecognizer;
            let velocityX = gr.velocity(in: self.superview).x;
            
            let maxX = self.contentSize.width - self.frame.size.width;
            if !self.enableDragToRight {
                if velocityX > 0 && self.contentOffset.x <= 0 { //向右拽
                    return false;
                }else if velocityX < 0 && self.contentOffset.x >= maxX { //向左拽
                    return false;
                }
            }
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer);
    }
}

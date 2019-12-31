//
//  ZGScrollVCL.swift
//  ZGUIDemo
// 
//
//

import UIKit
public enum ZGUIVerticalDirection{
    case defualt
    case up
    case down
}
open  class ZGScrollVCL: ZGBaseViewCTL,UIScrollViewDelegate,ZGRefreshTableHeaderDelegate {
    public var previousOffset : CGPoint = CGPoint.zero
    
    public weak var refreshHeaderView: ZGRefreshTableHeaderView?
    
    ///用户操作的滚动方向
    public var verticalDirection : ZGUIVerticalDirection = .defualt
    ///用户操作导致的滚动
    public var isInteractionScroll : Bool = false
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open func loadItems(){
        
    }
    
    //MARK: - UIScrollViewDelegate
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.previousOffset = scrollView.contentOffset
        self.isInteractionScroll = true
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.isInteractionScroll = false
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if !decelerate {
            self.isInteractionScroll = false
        }
        self.updateRefreshHeader(scrollView, willDecelerate: decelerate)
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView){
        if !self.isInteractionScroll{
            //如果不是用户的交互则直接返回
            return
        }
        
        let offSet = scrollView.contentOffset
        if offSet.y - self.previousOffset.y > 0 {
            //向上滑动
            self.verticalDirection = .up
        }else if(offSet.y - self.previousOffset.y < 0){
            //向下滑动
            self.verticalDirection = .down
        }else{
            self.verticalDirection = .defualt
        }
        guard let refreshHeaderView = self.refreshHeaderView else {
            return
        }
        let wd = scrollView.frame.size.width
        
        //下拉刷新
        let headerHeight = refreshHeaderView.headerHeight
        if (refreshHeaderView.delegate != nil && scrollView.contentOffset.y < 0) {
            refreshHeaderView.frame = CGRect.init(x:0, y:0 - headerHeight,width: wd, height:headerHeight);
            refreshHeaderView.egoRefreshScrollViewDidScroll(scrollView)
        }
    }
    
    //MARK: - ZGRefreshTableHeaderDelegate
    open func addRefreshView(toScrollView scrollView:UIScrollView?){
        guard let scrollView = scrollView else {
            return
        }
        
        if self.refreshHeaderView == .none {
            let width : CGFloat = (self.view.frame.size.width)
            let refreshTableHeight:CGFloat = 60
            let rect = CGRect.init(x: 0.0, y: -refreshTableHeight, width: width, height: refreshTableHeight)
            
            let refreshView = ZGRefreshTableHeaderView.init(frame: rect)
            
            self.refreshHeaderView = refreshView
            self.refreshHeaderView?.delegate = self
            scrollView.addSubview(refreshView)
            
            refreshView.setActivityStyle(.gray)
        }
        self.refreshHeaderView?.delegate = self
    }
    
    open func closeRefreshLoading(animated:Bool=false, scrollView:UIScrollView?) {
        guard let scrollView = scrollView else {
            return
        }
        if animated {
            self.refreshHeaderView?.egoRefreshScrollViewDataSourceDidFinishedLoading(scrollView)
        } else {
            self.refreshHeaderView?.resetToDefaultState(scrollView)
        }
    }
    
    open func startRefreshLoading(scrollView:UIScrollView?) {
        guard let model = self.model,
            let collectionView = scrollView,
            let refreshHeaderView = self.refreshHeaderView else {
                return
        }
        if (model.loading) {
            return
        }
        model.loading = true
        let inset = UIEdgeInsets.init(top: refreshHeaderView.headerHeight, left: 0, bottom: 0, right: 0)
        collectionView.contentInset = inset
        self.refreshHeaderView?.setState(.egooPullRefreshLoading)
    }
    
    open func updateRefreshHeader(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let refreshHeaderView = self.refreshHeaderView else {
            return
        }
        
        //向下拉时contentOffset.y的值为负数
        if (refreshHeaderView.delegate != nil && scrollView.contentOffset.y < 0){
            refreshHeaderView.egoRefreshScrollViewDidEndDragging(scrollView)
        }
    }
    
    open func refreshTableHeaderDidTriggerRefresh(_ view: ZGRefreshTableHeaderView) {
        guard let model = self.model else {
            return
        }
        if (model.loading) {
            return
        }
        model.loading = true
        model.pageNumber = 1
        self.loadItems()
    }
    
    open func refreshTableHeaderDataSourceIsLoading(_ view: ZGRefreshTableHeaderView) -> Bool {
        guard let model = self.model else {
            return false
        }
        return model.loading
    }
}

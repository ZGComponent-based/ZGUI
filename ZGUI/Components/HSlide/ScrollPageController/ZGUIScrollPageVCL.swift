//
//  ZGUIScrollPageVCL.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/4/6.
//
//

import UIKit

open class ZGUIScrollPageVCL<SubVCL: ZGBaseViewCTL> : ZGBaseScrollPageVCL,ZGTopScrollBarDelegate,ZGHPaginationScrollViewDelegate where SubVCL:ZGHPaginationSubViewDelegate{
    
    public typealias SubPageViewType = SubVCL;
    
    fileprivate var _dataSource: ZGTopScrollBarDataSource?;
    open var dataSource: ZGTopScrollBarDataSource? {
        set {
            _dataSource = newValue;
            self.topScrollBar.dataSource = newValue;
            self.pagingScrollView.items = newValue?.allItems;
        }
        get {
            return _dataSource;
        }
    }
    open func reload(dropDownFootView footView:UIView?) {
        self.topScrollBar.reload(dropDownFootView: footView);
    }
    
    open var topScrollBar: ZGTopScrollBar!;
    open var pagingScrollView:ZGHPaginationScrollView<SubVCL, ZGUIScrollPageVCL>!;
    
    open var enableDragToRight: Bool {
        set {
            self.pagingScrollView.enableDragToRight = newValue;
        }
        get {
            return self.pagingScrollView.enableDragToRight;
        }
    }
    
    public let kTopScrollBarHeight: CGFloat = 37;
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.topScrollBar = ZGTopScrollBar.init(frame: CGRect.init(x: 0, y: 0, width: self.view.width, height: kTopScrollBarHeight));
        self.topScrollBar.delegate = self;
        //        self.topScrollBar.autoresizingMask = .flexibleHeight;
        self.view.addSubview(self.topScrollBar);
        self.layoutTopScrollBar();
        
        self.pagingScrollView = ZGHPaginationScrollView.init(frame: CGRect.init(x: 0, y: self.topScrollBar.bottom, width: self.view.width, height: self.view.height-self.topScrollBar.bottom));
        self.pagingScrollView.slideDelegate = self;
        self.pagingScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        self.view.addSubview(self.pagingScrollView);
        self.layoutPagingScrollView();
    }
    
    open func layoutTopScrollBar() {
        self.topScrollBar.setBottomLineHeight(2)
    }
    
    open func layoutPagingScrollView() {
        
    }
    
    open func contentViewDidMove(from fromIndex:Int,to toIndex:Int, progress:CGFloat) {
    }
    
    open func adjustTopBarBottomLine(_ scrollView:UIScrollView) {
        let progress = self.getScrollPageProgress(scrollView);
        self.topScrollBar.adjustBottomLine(from: self.oldIndex, to: self.currentIndex, progress: progress);
    }
    
    
    public func getObject(at index:Int) -> ZGTopScrollBarBaseItem? {
        guard let ds = self.dataSource else {
            return nil;
        }
        guard index>=0 && index<ds.allItems.count else {
            return nil;
        }
        
        let item = ds.allItems[index];
        return item;
    }
    
    //MARK: - ZGHPaginationScrollViewDelegate
    
    //override
    open func getPageView(atIndex index:Int) -> SubVCL? {
        return nil;
    }
    
    //子类调用必须调用super
    open func willShow(pageView:SubVCL) {
    }
    
    //子类调用必须调用super
    open func didHide(pageView:SubVCL) {
        pageView.viewWillDisappear(false);
        pageView.viewDidDisappear(false);
    }
    
    //子类调用必须调用super
    open func didShow(pageView:SubVCL) {
        self.topScrollBar.selectItem(at: IndexPath.init(item: pageView.index, section: 0));
    }
    
    
    
    
    
    //MARK: - scrollView delegate
    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.dragStart {
            self.adjustTopBarBottomLine(scrollView);
        }
    }
    
    //MARK: - ZGTopScrollBarDelegate
    open func topScrollBar(_ topScrollBar:ZGTopScrollBar, didSelectItemAt indexPath:IndexPath, object:Any) {
        guard let ds = self.dataSource else {
            return;
        }
        guard ds.allItems.count>0 else {
            return;
        }
        self.pagingScrollView.selectPageView(withIndex: indexPath.item, animated: true);
    }
    
    open func getDropDownViewSuperView(withScrollTagBar scrollTagBar:ZGTopScrollBar) -> UIView {
        return self.view;
    }
    
    open func getDropDownViewFrame(withScrollTagBar scrollTagBar:ZGTopScrollBar) -> CGRect {
        return CGRect.init(x: 0, y: self.topScrollBar.bottom, width: self.view.width, height: self.view.height-self.topScrollBar.bottom);
    }
    
    open func dropDownViewWillShow(withScrollTagBar scrollTagBar:ZGTopScrollBar) {
        
    }
    open func dropDownViewWillHide(withScrollTagBar scrollTagBar:ZGTopScrollBar) {
        
    }
}

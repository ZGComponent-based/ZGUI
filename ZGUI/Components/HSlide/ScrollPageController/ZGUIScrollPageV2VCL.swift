//
//  ZGUIScrollPageV2VCL.swift
//  ZGUI
//
//  Created by zhaogang on 2018/7/26.
//

import UIKit

open class ZGUIScrollPageV2VCL<SubVCL: ZGBaseViewCTL>:
    ZGBaseScrollPageVCL,
    ZGHPaginationViewDelegate,
    ZGTopScrollBarDelegate,
    ZGHPaginationScrollViewDelegate {
    
    public typealias SubPageViewType = SubVCL
    public var _isSwitching: Bool = false
    fileprivate var _dataSource: ZGTopScrollBarDataSource?;
    open var dataSource: ZGTopScrollBarDataSource? {
        set {
            _dataSource = newValue;
            self.paginationView.topScrollBar.dataSource = newValue
            self.paginationView.paginationScrollView.items = newValue?.allItems
        }
        get {
            return _dataSource
        }
    }
    
    public var currentPage:SubVCL?
    
    deinit {
        self.paginationView.delegate = nil
    }
    
    //override
    open func getPageView(atIndex index: Int) -> SubVCL? {
        return nil;
    }
    
    open func getObject(at index: Int) -> ZGTopScrollBarBaseItem? {
        
        guard let ds = self.dataSource else {
            return nil
        }
        guard index>=0 && index<ds.allItems.count else {
            return nil
        }
        
        let item = ds.allItems[index]
        return item
    }
    
    public var paginationView: ZGHPaginationView<SubVCL, ZGUIScrollPageV2VCL>!
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.paginationView.layoutSubviews()
    }
    
    open func getPageTopMargin() -> CGFloat {
        return ZGUIUtil.statusBarHeight() + 44
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        let headerHeight = self.getHeaderHeight()
        let hView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: headerHeight))
        hView.backgroundColor = UIColor.blue
        let pageY = self.getPageTopMargin()
        self.paginationView = ZGHPaginationView.init(frame: CGRect.init(x: 0,
                                                                        y: pageY,
                                                                        width: self.view.width,
                                                                        height: self.view.height - pageY))
        self.paginationView.delegate = self
        self.paginationView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(self.paginationView)
        self.view.addSubview(hView)
        self.paginationView.headerView = hView
        self.paginationView.configureHeaderView()
        self.paginationView.configTopScrollBar()
        
        self.paginationView.topScrollBar.delegate = self
        self.view.backgroundColor = UIColor.white
        self.paginationView.paginationScrollView.slideDelegate = self
        if pageY > 0 {
            self.paginationView.segmentTopSpace = 0
        }
    }
    
    func setCurrentPageView(_ pageView: SubVCL) {
        self.currentPage = pageView
        if let scrollView = self.getCurrentScrollView() {
            self.paginationView.currentScrollView = scrollView
            self.paginationView.configurePaginationScrollView(scrollView, pageKey: "\(pageView.index)")
        }
    }
    
    //子类调用必须调用super
    open func willShow(pageView: SubVCL) {
        self._isSwitching = true
        self.setCurrentPageView(pageView)
    }
    
    //子类调用必须调用super
    open func didHide(pageView: SubVCL) {
        pageView.viewWillDisappear(false);
        pageView.viewDidDisappear(false);
    }
    
    open func adjustTopBarBottomLine(_ scrollView:UIScrollView) {
        let progress = self.getScrollPageProgress(scrollView);
        self.paginationView.topScrollBar.adjustBottomLine(from: self.oldIndex, to: self.currentIndex, progress: progress);
    }
    
    //子类调用必须调用super
    open func didShow(pageView: SubVCL) {
        self.setCurrentPageView(pageView)
        self.paginationView.topScrollBar.selectItem(at: IndexPath.init(item: pageView.index, section: 0));
        self._isSwitching = false
    }
    
    //MARK: - scrollView delegate
    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.dragStart {
            self.adjustTopBarBottomLine(scrollView);
        }
    }
    
    //MARK: - ZGTopScrollBarDelegate
    open func topScrollBar(_ topScrollBar: ZGTopScrollBar, didSelectItemAt indexPath: IndexPath, object: Any) {
        guard let ds = self.dataSource else {
            return
        }
        guard ds.allItems.count>0 else {
            return
        }
        self.paginationView.paginationScrollView.selectPageView(withIndex: indexPath.item, animated: true)
    }
    
    open func getDropDownViewSuperView(withScrollTagBar scrollTagBar: ZGTopScrollBar) -> UIView {
        return self.paginationView;
    }
    
    open func getDropDownViewFrame(withScrollTagBar scrollTagBar: ZGTopScrollBar) -> CGRect {
        return CGRect.init(x: 0,
                           y: self.paginationView.topScrollBar.bottom,
                           width: self.view.width,
                           height: self.view.height-self.paginationView.topScrollBar.bottom);
    }
    
    open func dropDownViewWillShow(withScrollTagBar scrollTagBar: ZGTopScrollBar) {
        
    }
    
    open func dropDownViewWillHide(withScrollTagBar scrollTagBar: ZGTopScrollBar) {
        
    }
    
    //MARK: - ZGHPaginationViewDelegate Methods
    open func getCurrentScrollView() -> UIScrollView? {
        return nil
    }
    
    public func isSwitching() -> Bool {
        return _isSwitching
    }
    
    open func getHeaderHeight() -> CGFloat {
        return 0
    }
    
    open func getTopScrollBarHeight() -> CGFloat {
        return 0
    }
}

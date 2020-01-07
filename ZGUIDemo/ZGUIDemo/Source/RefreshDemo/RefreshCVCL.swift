//
//  RefreshCVCL.swift
//  ZGUIDemo
//
//  Created by LeAustinHan on 2017/4/20.
//
//

import UIKit
import ZGUI

class RefreshCVCL: ZGCollectionVCL {
 
    var isLoading:Bool!
    var refreshControl:UIRefreshControl!
    
    func loadCollectionView() {
        if self.collectionView != nil {
            return
        }
        
        var rect = self.view.bounds
        rect.origin.y = ZGUIUtil.statusBarHeight() + 44
        rect.size.height = self.view.height - rect.origin.y
        
        let layout =  self.collectionViewLayout()
        let collectionView = UICollectionView(frame: rect, collectionViewLayout: layout)
        self.collectionView = collectionView
        self.collectionView?.delegate = self
        self.collectionView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.collectionView?.backgroundColor = UIColor.white
        self.collectionView?.alwaysBounceVertical = true
        self.view.addSubview(collectionView)
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigatorView = self.createNavigator()
        navigatorView.navigatorItem.title = "页面提示"
        self.view.addSubview(navigatorView)
        self.zbNavigatorView = navigatorView
        
        self.loadCollectionView()
        self.addRefreshView()
        
        self.registerClass()
        let model1 = RefreshModel()
        self.model = model1
        model1.items = model1.rootItems()
        self.reloadData() 
        
        
        self.view.backgroundColor = UIColor.darkGray
        self.refreshHeaderView?.backgroundColor = UIColor.purple
        
//        let rr = UIRefreshControl()
//        rr.tintColor = UIColor.gray
//        self.collectionView?.addSubview(rr)
//        rr.addTarget(self, action: #selector(didChangeRefresh), for: .valueChanged)
//        self.refreshControl = rr
    }
    
    @objc func didChangeRefresh() {
        let deadlineTime = DispatchTime.now() + .seconds(3)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.refreshControl.endRefreshing()
        }

    }
    
    @objc func goBack() {
        print("goBack Action")
    }
    
    
    open override func registerClass(){
        super.registerClass()
        self.collectionView?.register(RefreshCell.self, forCellWithReuseIdentifier: RefreshCell.tbbzIdentifier())
    }
    
    override func reloadData(){
        guard let items =  self.model?.items else {
            return
        }
        
        let ds = RefreshDataSource.init(items: items as! Array<ZGBaseUIItem>)
        self.dataSource = ds
 
        self.startRefreshLoading()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {
            self.model?.loading = false
            self.closeRefreshLoading(animated: true)
        }
    }
}

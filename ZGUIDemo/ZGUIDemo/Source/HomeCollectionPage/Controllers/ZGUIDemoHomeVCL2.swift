//
//  ZGUIDemoHomeVCL2.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2018/7/27.
//  Copyright © 2018 zhaogang. All rights reserved.
//
import UIKit
import ZGUI

class ZGUIDemoHomeVCL2: ZGCollectionVCL {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 这快比较关键
        self.extendedLayoutIncludesOpaqueBars = false
        self.automaticallyAdjustsScrollViewInsets = false
        self.edgesForExtendedLayout = []
        
        self.view.backgroundColor = UIColor.white 
        if self.collectionView == nil {
            let rect = self.view.bounds
            self.createCollectionView(rect)
            self.collectionView?.backgroundColor = UIColor.lightGray
        }
        self.registerClass()
        
        self.view.backgroundColor = UIColor.lightGray
        self.view.clipsToBounds = false
    }
    
    deinit {
        print("release \(self)")
    }
    
    override func loadItems() {
        
        self.model?.loadItems(nil, completion: { [weak self](dict) in
            self?.reloadData()
            }, failure: { (error) in
                
        })
    }
    
    override func reloadData(){
        guard let items =  self.model?.items else {
            return
        }
        let ds = ZGUIDemoHomeDataSource.init(sectionItems:items as! Array<Array<ZGBaseUIItem>>, sections:self.model?.sections)
        self.dataSource = ds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    open override func registerClass(){
        super.registerClass()
        self.collectionView?.register(ZGUIDemoHomeCell.self, forCellWithReuseIdentifier: ZGUIDemoHomeCell.tbbzIdentifier())
        
        self.collectionView?.register(ZGUIDemoHomeHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ZGUIDemoHomeHeaderView.tbbzIdentifier())
        self.collectionView?.register(ZGUIDemoHomeHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: ZGUIDemoHomeHeaderView.tbbzIdentifier())
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 10
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt \(indexPath)")
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    //MARK: - ZGHPaginationSubViewDelegate
    
    override func getView() -> UIView {
        return self.view
    }
    
    func scrollDealListToVisibleRect()  {
        guard let listModel  = self.model as? ZGUIDemoHomeModel else {
            return
        }
        guard var visibleRect = listModel.visibleRect else {
            return
        }
        
        if visibleRect.size.width > 0.1 {
            visibleRect.origin.y = ((visibleRect.origin.y) < 0) ? 0 : (visibleRect.origin.y)
            listModel.visibleRect = visibleRect
            self.collectionView?.setContentOffset(visibleRect.origin, animated: false)
        } else {
            self.collectionView?.setContentOffset(CGPoint.zero, animated: false)
        }
    }
    
    override func setObject(_ object: Any) {
        super.setObject(object)
        guard let item = self.topbarItem as? ZGTopScrollBarItem else {
            return
        }
        
        if item.model == nil {
            item.model = ZGUIDemoHomeModel()
        }
        
        self.model = item.model
        if let model1 = self.model as? ZGUIDemoHomeModel {
            model1.pageIndex = self.index
        }
        
        if self.model.items.isEmpty{
            loadItems()
        }else{
            reloadData()
            self.scrollDealListToVisibleRect()
            if self.model.pageNumber == 1 && self.model.loading {
                self.startRefreshLoading()
            }
        }
    }
    
    open override func prepareForReuse() {
        guard let collectionView = self.collectionView, let listModel  = self.model as? ZGUIDemoHomeModel else {
            return
        }
        
        var visibleRect = CGRect.zero
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        
        listModel.visibleRect = visibleRect
        
        //恢复页面原始状态
        self.closeRefreshLoading(animated: false)
        
        var rect = collectionView.bounds
        rect.origin.y = 0
        collectionView.scrollRectToVisible(rect, animated: false)
        collectionView.contentSize = rect.size
    }
    
    override func reuseIdentifier() -> String {
        return "ZGUIDemoHomeVCL"
    }
}

//
//  ZGCollectionView.swift
//  Pods
//
//  Created by zhaogang on 2017/8/7.
//
//

import UIKit

open class ZGCollectionView: UICollectionView,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    private var _tbDataSource:ZGCollectionViewDataSource?
    open var tbDataSource:ZGCollectionViewDataSource? {
        get {
            return _tbDataSource
        }
        set (newValue) {
            if newValue != _tbDataSource {
                _tbDataSource = newValue
            }
            self.dataSource = newValue
        }
    }
    deinit {
        self.delegate = nil
        self.dataSource = nil
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    open func collectionView (_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
                              sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView.dataSource is ZGCollectionViewDataSource) {
            let dc:ZGCollectionViewDataSource = self.dataSource as! ZGCollectionViewDataSource
            let object = dc.collectionView(collectionView, objectForRowAtIndexPath: indexPath)
            if let obj1 = object {
                let cellType = dc.collectionView(collectionView, cellClassForObject: obj1)
                return cellType.collectionView(collectionView, layout: collectionViewLayout, sizeForObject: obj1)
            }
        }
        return CGSize.zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        
    }
    
    //override
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{
        if (collectionView.dataSource is ZGCollectionViewDataSource) {
            let dc:ZGCollectionViewDataSource = self.dataSource as! ZGCollectionViewDataSource
            let object = dc.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, objectForSection: section)
            if let obj = object{
                let viewType = dc.collectionView(collectionView, reusableViewClassForObject: obj)
                return viewType.collectionView(collectionView: collectionView, layout: collectionViewLayout, sizeForObject: obj)
            }
        }
        return CGSize.zero
    }
    
    //override
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize{
        if (collectionView.dataSource is ZGCollectionViewDataSource) {
            let dc:ZGCollectionViewDataSource = self.dataSource as! ZGCollectionViewDataSource
            let object = dc.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionFooter, objectForSection: section)
            if let obj = object{
                let viewType = dc.collectionView(collectionView, reusableViewClassForObject: obj)
                return viewType.collectionView(collectionView: collectionView, layout: collectionViewLayout, sizeForObject: obj)
            }
        }
        return CGSize.zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 5
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 5
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    //MARK: - Register Class
    open func registerClass(){
        ZGCollectionReusableView.register(for: self, kind: UICollectionView.elementKindSectionHeader)
        ZGCollectionReusableView.register(for: self, kind: UICollectionView.elementKindSectionFooter)
    }
}

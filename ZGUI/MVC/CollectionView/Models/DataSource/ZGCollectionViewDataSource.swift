//
//  ZGCollectionViewDataSource.swift
//  ZGUIDemo
//

//
//

import UIKit

open class ZGCollectionViewDataSource: NSObject,UICollectionViewDataSource {
    
    open var sectionItems:[[ZGBaseUIItem]]? //多个section
    open var items:[ZGBaseUIItem]?//一个section
    open var sectionViewItems : [ZGCollectionReusableViewItem]?//section header footer对应的item数组
    
    public init(items:[ZGBaseUIItem],sections:[ZGCollectionReusableViewItem]? =  nil) {
        self.items = items
        self.sectionViewItems = sections
    }
    
    public init(sectionItems:[[ZGBaseUIItem]],sections:[ZGCollectionReusableViewItem]? =  nil) {
        self.sectionItems = sectionItems
        self.sectionViewItems = sections
    }
    
    //override
    open func collectionView(_ collectionView: UICollectionView, cellClassForObject object: ZGBaseUIItem) -> ZGCollectionViewCell.Type {
        return object.mapViewType()
    }
    
    //打点sdk用
    @objc open func collectionView(collectionView: UICollectionView, objectForRowAtIndexPath indexPath: IndexPath) -> ZGBaseUIItem? {
        return self.collectionView(collectionView, objectForRowAtIndexPath:indexPath)
    }
    
    // MARK: - 私有方法
    open func collectionView(_ collectionView: UICollectionView, objectForRowAtIndexPath indexPath: IndexPath) -> ZGBaseUIItem? {
        var retItems = self.items
        if let section = self.sectionItems{
            if indexPath.section >= 0 && indexPath.section < section.count {
                retItems = section[indexPath.section]
            }
        }
        
        if let sourceItems = retItems{
            if indexPath.row >= 0 && indexPath.row < sourceItems.count {
                return sourceItems[indexPath.row]
            }
        }
        
        return nil
    }
    
    // MARK: - UICollectionViewDataSource
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var retItems = self.items
        if let section1 = self.sectionItems{
            if section >= 0 && section < section1.count {
                retItems = section1[section]
            }
        }
        
        return retItems?.count ?? 0
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        collectionView.collectionViewLayout.invalidateLayout()
        return self.sectionItems?.count ?? 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let obj : ZGBaseUIItem? = self.collectionView(collectionView, objectForRowAtIndexPath: indexPath)
        
        guard let object = obj  else {
            return UICollectionViewCell()
        }
        
        let cellType = self.collectionView(collectionView, cellClassForObject: object)
        let identifier = cellType.tbbzIdentifier()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        if let cell2 = cell as? ZGCollectionViewCell {
            cell2.setObject(object)
        }
        return cell;
    } 
    
    ///MARK: - 设置collectionView各个section的header和footer
    
    open func collectionView(_ collectionView: UICollectionView,viewForSupplementaryElementOfKind kind:String, objectForSection section: Int) -> ZGCollectionReusableViewItem?{
        return findReusableViewItem(kind, sectionIndex: section)
    }
    
    func findReusableViewItem(_ kind:String, sectionIndex: Int)->ZGCollectionReusableViewItem?{
        guard let retItems = self.sectionViewItems else {
            return nil
        }
        let kind1 = ZGCollectionReusableViewKind(rawValue: kind)
        for reusableViewItem in retItems{
            if reusableViewItem.sectionIndex == sectionIndex && reusableViewItem.kind == kind1 && !reusableViewItem.isHidden {
                return reusableViewItem
            }
        }
        
        return nil
    }
    
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView : UICollectionReusableView!
        let object : ZGCollectionReusableViewItem? = self.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, objectForSection: indexPath.section)
        if let obj = object {
            let viewType = self.collectionView(collectionView, reusableViewClassForObject: obj);
            let identifier = viewType.tbbzIdentifier()
            let kind = obj.kind
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind.rawValue, withReuseIdentifier: identifier, for: indexPath)
            
            let reusableView2 = reusableView as! ZGCollectionReusableView
            reusableView2.setObject(obj)
        }else{
            //不取复用会崩溃
            //reusableView = UICollectionReusableView()
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ZGCollectionReusableView.tbbzIdentifier(), for: indexPath)
        }
    
        return reusableView
        
    }
    
    //override
    open func collectionView(_ collectionView: UICollectionView, reusableViewClassForObject object: ZGCollectionReusableViewItem) -> ZGCollectionReusableView.Type {
        return object.mapReusableViewType()
    }
}

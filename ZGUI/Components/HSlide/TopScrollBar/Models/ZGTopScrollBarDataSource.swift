//
//  ZGTopScrollBarDataSource.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/3/24.
//
//

import UIKit

open class ZGTopScrollBarDataSource: NSObject, UICollectionViewDataSource {
    
    public typealias ItemType = ZGTopScrollBarBaseItem;

    //是否有下拉展开按钮
    open var isNeedDropDown: Bool = false;
    //当下拉时，滚动栏是否显示定制文案，例如首页横滑的“显示全部分类”。只有当needExpand为YES时才有效
    open var dropDownText: NSAttributedString?;
    
    
    open var items: Array<ItemType>!;
    //置顶item，例如首页横滑的“推荐“。
    open var stickItem: ItemType?;
    //包含stickItem和items所有element的数组，如果stickItem为nil，则和items元素一样。
    open var allItems: Array<ItemType>!;

    //下拉视图的dataSource
    open var dropDownDataSource: ZGTopScrollDropDownDataSource?;
    
    
    open weak var topScrollBar: ZGTopScrollBar?;
    open weak var sectionHeadView: UIView?;
    
    
    public init(items: Array<ItemType>, stickItem:ItemType?, dropDownFootView footView:UIView?) {
        super.init();
        
        self.items = items;
        self.stickItem = stickItem;
        
        self.allItems = items;
        if let stickItem1 = stickItem {
            self.allItems.insert(stickItem1, at: 0);
        }
        
        self.dropDownDataSource = ZGTopScrollDropDownDataSource.init(items: self.allItems, footView:footView);
    }
    
    open func collectionView(_ collectionView:UICollectionView, objectForItemAt indexPath:IndexPath) -> ItemType? {
        if indexPath.item == -1 {
            return self.stickItem;
        }else if (indexPath.item>=0 && indexPath.item<self.items.count) {
            return self.items[indexPath.item];
        }
        return nil;
    }
    
    open func collectionView(_ collectionView:UICollectionView, cellClassFor object:ItemType) -> ZGCollectionViewCell.Type {
        if object is ZGTopScrollBarTextItem {
            return ZGTopScrollBarTextCell.self;
        }else if object is ZGTopScrollBarImageItem {
            return ZGTopScrollBarImageCell.self;
        }
        return ZGCollectionViewCell.self;
    }
    
    open func sectionViewClassForCollectionView(_ collectionView:UICollectionView) -> ZGTopScrollBarSectionBaseView.Type {
        if self.stickItem is ZGTopScrollBarTextItem {
            return ZGTopScrollBarSectionTextView.self;
        }else if self.stickItem is ZGTopScrollBarImageItem {
            return ZGTopScrollBarSectionImageView.self;
        }
        return ZGTopScrollBarSectionBaseView.self;
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let obj = self.collectionView(collectionView, objectForItemAt: indexPath);
        guard let object = obj else {
            return UICollectionViewCell.init();
        }
        let cellClass = self.collectionView(collectionView, cellClassFor: object);
        let identifier = cellClass.tbbzIdentifier();
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        if let baseCell = cell as? ZGCollectionViewCell  {
            baseCell.setObject(object as! ZGBaseUIItem);
        }
        return cell;
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView.init();
        }
        guard let _ = self.stickItem else {
            return UICollectionReusableView.init();
        }
        
        let cellClass = self.sectionViewClassForCollectionView(collectionView);
        let identifier = cellClass.tbbzIdentifier();
        let sectionView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath);
        if let baseSectionView = sectionView as? ZGTopScrollBarSectionBaseView {
            baseSectionView.setObject(self.stickItem! as! ZGBaseUIItem);
            baseSectionView.viewDelegate = self.topScrollBar;
        }
        self.sectionHeadView = sectionView;
        return sectionView;
    }
    
}

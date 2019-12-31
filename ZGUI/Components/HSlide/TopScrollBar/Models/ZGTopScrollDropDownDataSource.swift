//
//  ZGTopScrollDropDownDataSource.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/3/31.
//
//

import UIKit

open class ZGTopScrollDropDownDataSource: NSObject, UICollectionViewDataSource  {
    
    public typealias ItemType = ZGTopScrollBarDataSource.ItemType;

    open var items: Array<ItemType>!;
    open var footView: UIView?;
    
    open var lineHeight: CGFloat = 45;
    open var columnCount: Int = 4;

    open var lineCount: Int {
        get {
            var lineCount = 0;
            if self.items.count % self.columnCount == 0 {
                lineCount = self.items.count / self.columnCount;
            }else {
                lineCount = self.items.count / self.columnCount + 1;
            }
            return lineCount;
        }
    }
    
    public init(items: Array<ItemType>, footView: UIView?) {
        super.init();
        self.items = items;
        self.footView = footView;
    }
    
    open func contentViewSize() -> CGSize {
        
        let bounds = UIScreen.main.bounds;
        var contentSize = CGSize.init(width: bounds.width, height: self.lineHeight * CGFloat(self.lineCount));
        if let view = self.footView {
            contentSize.height += view.frame.height;
        }
        return contentSize;
    }
    
    open func collectionView(_ collectionView:UICollectionView, objectForItemAt indexPath:IndexPath) -> ItemType? {
        if indexPath.item >= 0, indexPath.item < self.items.count {
            return self.items[indexPath.item];
        }
        return nil;
    }
    
    open func collectionView(_ collectionView:UICollectionView, cellClassFor object:ItemType) -> ZGCollectionViewCell.Type {
        if object is ZGTopScrollBarTextItem {
            return ZGTopScrollDropTextCell.self;
        }else if object is ZGTopScrollBarImageItem {
            return ZGTopScrollDropImageCell.self;
        }
        return ZGCollectionViewCell.self;
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let object :ItemType! = self.collectionView(collectionView, objectForItemAt: indexPath);
        guard let _ = object else {
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
}

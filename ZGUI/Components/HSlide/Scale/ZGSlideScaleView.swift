//
//  ZGSlideScaleView.swift
//  ZGUI
//
//  Created by zhaogang on 2017/12/20.
//

import UIKit

open class ZGSlideScaleView: UICollectionView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    open var items: [ZGSlideScaleItem]?
    public var itemSpacing: CGFloat = 30
    public var currentIndex:Int = 0

    private var _tbDataSource: ZGCollectionViewDataSource?
    open var tbDataSource: ZGCollectionViewDataSource? {
        get {
            return _tbDataSource
        }
        set(newValue) {
            if newValue != _tbDataSource {
                _tbDataSource = newValue
            }
            self.dataSource = newValue
        }
    }

    public func currentImage() -> UIImage? {
 
        guard let arr = self.visibleCells as? [ZGSlideScaleCell] else {
            return nil
        }
      
        for cell in arr {
            if let item = cell.item as? ZGSlideScaleItem {
                if item.itemIndex == currentIndex {
                    return cell.imageView.defaultImage
                }
            }
        }
        return nil
    }
    
    deinit {
        self.delegate = nil
        self.dataSource = nil
    }

    // MARK: - 显示

    /// 横向滚动视图，默认支持图片预览 
    ///
    /// - parameter inView:    父视图
    /// - parameter frame:     在父视图中的显示区域
    /// - parameter centerDistanceTrigger: 当视图滑动时距离中心centerDistanceTrigger时触发缩放
    /// - parameter scaleFactor:    增加的缩放比例，如果为0则不缩放
    /// - parameter attributeAlpha:    默认每个子视图的透明度
    /// - parameter itemSpacing:  子视图之间的间距
    ///
    /// - returns: ZGSlideScaleView 实例
    open class func show(inView: UIView,
                         frame: CGRect,
                         centerDistanceTrigger: CGFloat = 100,
                         scaleFactor: CGFloat = 0.2,
                         attributeAlpha: CGFloat = 0.5,
                         itemSpacing: CGFloat = 40) -> ZGSlideScaleView {
        let layout = ZGSlideScaleLayout()
        layout.centerDistanceTrigger = centerDistanceTrigger
        layout.scaleFactor = scaleFactor
        layout.attributeAlpha = attributeAlpha
        layout.scrollDirection = .horizontal
        
        let collectionView = ZGSlideScaleView.init(frame: frame, collectionViewLayout: layout)
        collectionView.itemSpacing = itemSpacing
        collectionView.delegate = collectionView
        collectionView.registerClass()
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast

        inView.addSubview(collectionView)

        collectionView.backgroundColor = UIColor.clear
        layout.slideCallBack = {[weak collectionView](attributes) in
            collectionView?.currentIndex = attributes.indexPath.row
        }
 
        return collectionView
    }

    open func setViewItems(_ viewItems: [ZGSlideScaleItem]) {
        self.items = viewItems
        self.tbDataSource = ZGCollectionViewDataSource(items: viewItems)
        self.reloadData()
    }

    //MARK: - UICollectionViewDelegateFlowLayout
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView.dataSource is ZGCollectionViewDataSource) {
            let dc: ZGCollectionViewDataSource = self.dataSource as! ZGCollectionViewDataSource
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
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
   

    //override
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if (collectionView.dataSource is ZGCollectionViewDataSource) {
            let dc: ZGCollectionViewDataSource = self.dataSource as! ZGCollectionViewDataSource
            let object = dc.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, objectForSection: section)
            if let obj = object {
                let viewType = dc.collectionView(collectionView, reusableViewClassForObject: obj)
                return viewType.collectionView(collectionView: collectionView, layout: collectionViewLayout, sizeForObject: obj)
            }
        }
        return CGSize.zero
    }

    //override
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if (collectionView.dataSource is ZGCollectionViewDataSource) {
            let dc: ZGCollectionViewDataSource = self.dataSource as! ZGCollectionViewDataSource
            let object = dc.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionFooter, objectForSection: section)
            if let obj = object {
                let viewType = dc.collectionView(collectionView, reusableViewClassForObject: obj)
                return viewType.collectionView(collectionView: collectionView, layout: collectionViewLayout, sizeForObject: obj)
            }
        }
        return CGSize.zero
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.itemSpacing
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    //使前后项都能居中显示
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let itemCount = collectionView.numberOfItems(inSection: section)
        if itemCount < 1 {
            return .zero
        }

        let firstIndexPath = IndexPath.init(row: 0, section: section)
        let lastIndexPath = IndexPath.init(row: itemCount - 1, section: section)
        let firstSize = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: firstIndexPath)
        let lastSize = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: lastIndexPath)

        return UIEdgeInsets.init(
                top: 0,
                left: (collectionView.width - firstSize.width) / 2,
                bottom: 0,
                right: (collectionView.width - lastSize.width) / 2)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let items = self.items else {
            return
        }
        self.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        self.currentIndex = indexPath.row
    }

    //MARK: - Register Class
    open func registerClass() {
        ZGCollectionReusableView.register(for: self, kind: UICollectionView.elementKindSectionHeader)
        ZGCollectionReusableView.register(for: self, kind: UICollectionView.elementKindSectionFooter)
        ZGSlideScaleCell.register(for: self)
    }
}

//
//  ZGSlideScaleLayout.swift
//  ZGUI
//  参照：http://www.cnblogs.com/rossoneri/p/5115335.html#_label6
//  Created by zhaogang on 2017/12/20.
//

import UIKit

public class ZGSlideScaleLayout: UICollectionViewFlowLayout {

    public var centerDistanceTrigger: CGFloat = 80
    public var scaleFactor: CGFloat = 0.2
    public var attributeAlpha: CGFloat = 0.5
    
    public var slideCallBack:((UICollectionViewLayoutAttributes) -> Void)?

    //这里设置放大范围
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard  let collectionView = self.collectionView else {
            return nil
        }
        guard let array = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        let visibleRect = CGRect.init(origin: collectionView.contentOffset, size: collectionView.bounds.size)

        for attributes in array {
            //如果cell在屏幕上则进行缩放
            if attributes.frame.intersects(rect) {

                attributes.alpha = self.attributeAlpha

                let distance: CGFloat = visibleRect.midX - attributes.center.x //距离中点的距离
                let absDistance = abs(distance)

                if (abs(distance) < self.centerDistanceTrigger) {
                    var delta: CGFloat = distance / self.centerDistanceTrigger
                    delta = abs(delta)
                    let zoom: CGFloat = 1 + self.scaleFactor * (1 - delta) //放大渐变
                    attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0)
                    attributes.zIndex = 1
                    var alpha1: CGFloat = (1 - delta)
                    if alpha1 < self.attributeAlpha {
                        alpha1 = self.attributeAlpha
                    }
                    attributes.alpha = alpha1
                }
            }
        }

        return array
    }

    //scroll 停止对中间位置进行偏移量校正
    override public func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard  let collectionView = self.collectionView else {
            return proposedContentOffset
        }

        var offsetAdjustment: CGFloat = .greatestFiniteMagnitude
        ////  |-------[-------]-------|
        ////  |滑动偏移|可视区域 |剩余区域|
        //是整个collectionView在滑动偏移后的当前可见区域的中点
        let centerX: CGFloat = proposedContentOffset.x + (collectionView.bounds.width / 2.0)

        let targetRect: CGRect = CGRect.init(x: proposedContentOffset.x, y: 0.0, width: collectionView.bounds.width, height: collectionView.bounds.height)

        guard let array = self.layoutAttributesForElements(in: targetRect) else {
            return proposedContentOffset
        }
        for item in array {
            let itemCenterX: CGFloat = item.center.x

            if (abs(itemCenterX - centerX) < abs(offsetAdjustment)) { // 找出最小的offset 也就是最中间的item 偏移量
                offsetAdjustment = itemCenterX - centerX;
                if let slideCallBack = self.slideCallBack {
                    slideCallBack(item)
                }
            }
        }

        return CGPoint.init(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }

    //边界发生变化时是否重新布局（视图滚动的时候也会触发）
    //会重新调用prepareLayout和调用
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

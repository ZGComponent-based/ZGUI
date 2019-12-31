//
//  ZGImagePreviewPageControl.swift
//  Pods
//
//  Created by zhaogang on 2017/7/13.
//
//

import UIKit

public class ZGImagePreviewPageControl: ZGImagePreviewBottomView  {
    var pageControl:UIPageControl!
    
    public override func setItem(_ item:ZGImagePreviewBottomItemProtocol) {
        super.setItem(item)
        
        guard let bottomItem =  self.item else {
            return
        }

        self.setTotal(bottomItem.total)
        let item2 = bottomItem as! ZGImagePreviewPageControlItem
        
        if let pageIndicatorTintColor = item2.pageIndicatorTintColor {
            self.pageControl.pageIndicatorTintColor = pageIndicatorTintColor
        }
        
        if let currentPageIndicatorTintColor = item2.currentPageIndicatorTintColor {
            self.pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        let pControl = UIPageControl(frame:CGRect.init(x: 0, y: 0, width: 150, height: 30))
        
        self.addSubview(pControl)
        self.pageControl = pControl
        
        self.isUserInteractionEnabled = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setCurrentIndex(_ index:Int, item:ZGImagePreviewItem) -> Void {
        self.pageControl.currentPage = index
        
    }
    
    public func setTotal(_ total:Int) -> Void {
        self.pageControl.numberOfPages = total

        var frame = self.pageControl.frame
        frame.size = self.pageControl.size(forNumberOfPages: total)
        frame.origin.x = (self.width - frame.size.width) / 2
        frame.origin.y = (self.height - frame.size.height) / 2
        self.pageControl.frame = frame
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
}

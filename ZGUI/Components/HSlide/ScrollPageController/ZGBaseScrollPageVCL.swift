//
//  ZGBaseScrollPageVCL.swift
//  ZGUIDemo
//
//  Created by frank zhaogang on 2017/4/6.
//
//

import UIKit

open class ZGBaseScrollPageVCL: ZGBaseViewCTL, UIScrollViewDelegate {

    open var oldOffSetX: CGFloat = 0;
    open var oldIndex: Int = 0;
    open var currentIndex: Int = 0;
    open var dragStart: Bool = false;
    
    override open func viewDidLoad() {
        super.viewDidLoad();
        
        self.edgesForExtendedLayout = [];
        self.extendedLayoutIncludesOpaqueBars = false;
        self.automaticallyAdjustsScrollViewInsets = false;

    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    open func getScrollPageProgress(_ scrollView:UIScrollView) -> CGFloat {
        let offSetX = scrollView.contentOffset.x;
        
        let MaxOffsetX = scrollView.contentSize.width-scrollView.width;
        let maxIndex = Int(scrollView.contentSize.width/scrollView.width);
        if offSetX > MaxOffsetX {
            self.oldIndex = maxIndex;
            self.currentIndex = self.oldIndex;
            return 0.0;
        }else if offSetX < 0 {
            self.oldIndex = 0;
            self.currentIndex = self.oldIndex;
            return 0.0;
        }
        
        let tempProgress = offSetX / scrollView.width;
        var progress = tempProgress - floor(tempProgress);
        
        if offSetX - self.oldOffSetX > 0 {
            //向右
            self.oldIndex = Int( floor(offSetX/scrollView.width) );
            self.currentIndex = self.oldIndex+1;

        }else if offSetX - self.oldOffSetX < 0 {
            self.currentIndex = Int( floor(offSetX/scrollView.width) );
            self.oldIndex = self.currentIndex+1;
            progress = 1 - progress;
        }else {
            progress = 0.0;
            self.currentIndex = self.oldIndex;
        }
        
        return progress;
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.oldOffSetX = scrollView.contentOffset.x;
        self.dragStart = true;
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.dragStart = false;
    }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.dragStart = false;
    }
}

//
//  ZGImagePreviewBottomView.swift
//  Pods
//
//  Created by zhaogang on 2017/7/13.
//
//

import UIKit

open class ZGImagePreviewBottomView: UIView {
    
    public var item:ZGImagePreviewBottomItemProtocol?
    
    open func setItem(_ item:ZGImagePreviewBottomItemProtocol) {
        self.item = item
    }
 
    open func setCurrentIndex(_ index:Int, item:ZGImagePreviewItem) -> Void {
        
        
    }

}

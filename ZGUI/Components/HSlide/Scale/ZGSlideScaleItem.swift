//
//  ZGSlideScaleItem.swift
//  ZGUI
//
//  Created by zhaogang on 2017/12/20.
//

import UIKit

open class ZGSlideScaleItem: ZGBaseUIItem {
    
    public var imageUrl:String?
    open override func mapViewType() -> ZGCollectionViewCell.Type {
        return ZGSlideScaleCell.self
    }
    
    public init(imageUrl:String?, size:CGSize) {
        super.init()
        self.size = size
        guard let url = imageUrl else {
            return
        }
        self.imageUrl = url
    }
}

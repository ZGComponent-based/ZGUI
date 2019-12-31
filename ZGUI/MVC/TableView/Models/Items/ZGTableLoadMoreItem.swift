//
//  ZGCollectionLoadMoreItem.swift
//
//  Created by huangyuanqing on 2017/3/30.
//

import UIKit

open class ZGTableLoadMoreItem: ZGTableReusableViewItem {
    open var text: String?
    open var loading: Bool =  false
    open var failed: Bool = false
    open var hasNext: Bool = false
    
    open override func mapReusableViewType() -> ZGTableReusableView.Type {
        return ZGTableLoadMoreView.self
    }
    
    
    public required init() {
        super.init()
        self.size = CGSize.init(width: UIScreen.main.bounds.width, height: 44)
    }
}

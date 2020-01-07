//
//  ZGUIDemoHomeHeaderItem.swift
//  ZGUIDemo
//
//  Created by temp on 2017/3/28.
//
//

import UIKit
import ZGUI

class ZGUIDemoHomeSectionItem: ZGCollectionReusableViewItem {
    var title : String?
    
    class func defualtItem(title:String, section: Int, kind:ZGCollectionReusableViewKind)->ZGUIDemoHomeSectionItem{
        let item = ZGUIDemoHomeSectionItem()
        let w = UIScreen.main.bounds.size.width
        item.size = CGSize.init(width: w, height: 44)
        item.kind = kind
        item.title = title
        item.sectionIndex = section
        return item
    }
    
    override func mapReusableViewType() -> ZGCollectionReusableView.Type {
        return ZGUIDemoHomeHeaderView.self
    }
    
}

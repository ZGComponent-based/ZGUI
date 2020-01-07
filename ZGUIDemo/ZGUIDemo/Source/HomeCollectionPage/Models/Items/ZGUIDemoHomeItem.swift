//
//  ZGUIDemoHomeItem.swift
//  ZGUIDemo
//
//  Created by temp on 2017/3/23.
//
//

import UIKit
import ZGUI

class ZGUIDemoHomeItem: ZGBaseUIItem {
    var title : String?

    open class func defualItem(_ index:Int) -> ZGUIDemoHomeItem{
        let item = ZGUIDemoHomeItem()
        let width = (UIScreen.main.bounds.width - 30) / 2.0
        
        item.size = CGSize.init(width: width, height: 100)
        item.title = "demoCell" + "\(index)"
        return item
    }
    
    override func mapViewType() -> ZGCollectionViewCell.Type {
        return ZGUIDemoHomeCell.self
    }
    
    
}

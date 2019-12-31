//
//  ZGCollectionReusableViewItem.swift
//  ZGUIDemo
// 
//
//

import UIKit

public enum ZGTableSectionType:Int {
    case header = 0
    case footer = 1
}

open class ZGTableReusableViewItem:ZGBaseUIItem{
    //返回item对应的Type
    open func mapReusableViewType() -> ZGTableReusableView.Type {
        return ZGTableReusableView.self
    }
    public var sectionIndex : Int = 0
    //显示在侧边的字母索引
    public var indexCharactor :String? = nil
    public var kind : ZGTableSectionType = .header
    public var isHidden : Bool = false
    
    required public override init() {
        super.init()
    }
}


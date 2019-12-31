//
//  ZGCollectionReusableViewItem.swift
//  ZGUIDemo
// 
//
//

import UIKit
public enum ZGCollectionReusableViewKind:String{
    case header = "UICollectionElementKindSectionHeader"
    case footer = "UICollectionElementKindSectionFooter"
}

open class ZGCollectionReusableViewItem:ZGBaseUIItem{
    //返回item对应的Type
    open func mapReusableViewType() -> ZGCollectionReusableView.Type{
        return ZGCollectionReusableView.self
    }
    open var sectionIndex : Int = 0
    open var kind : ZGCollectionReusableViewKind = .footer
    open var isHidden : Bool = false
    
    required public override init() {
        super.init()
    }
}


//
//  ZGUIDemoHomeItem.swift
//  ZGUIDemo
//
//  Created by temp on 2017/3/23.
//
//

import UIKit
import ZGUI

public enum ZGUIDemoRootEnum {
    case image
    case home
    case hScroll
    case refresh
    case cycle
    case preview
    case loading
    case toast
    case pageTip
    case alert
    case album
    case qrcode
    case slideScale
    case table
    case HVScroll
}

class ZGUIDemoRootItem: ZGBaseUIItem {
    var title : String?
    var type: ZGUIDemoRootEnum = .image
    
    override func mapViewType() -> ZGCollectionViewCell.Type {
        return ZGUIDemoRootCell.self
    }
}

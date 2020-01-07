//
//  RefreshItem.swift
//  ZGUIDemo
//
//  Created by LeAustinHan on 2017/4/20.
//
//

import UIKit
import ZGUI

class RefreshItem: ZGBaseUIItem {
    var title : String?
    var type: ZGUIDemoRootEnum = .image
    
    override func mapViewType() -> ZGCollectionViewCell.Type {
        return RefreshCell.self
    }
    
    public init (size:CGSize!){
        super.init()
        self.size = size
    }
}

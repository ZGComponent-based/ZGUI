//
//  ZGUIDemoPageSubItem.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/4/6.
//
//

import UIKit
import ZGUI

class ZGUIDemoPageSubTextItem: ZGBaseUIItem,ZGTopScrollBarTextItem {
    var isLight: Bool = false
    
    var isLeft: Bool = false
    
    var selectIsBold: Bool = false
    
    var selectFontSize: CGFloat = 15
    
    var isShowRedBadgeValue: Bool = false
    
    var isBold: Bool = false
    
    var lineWidth: CGFloat = 5.0
    
    var selectedLineColor: UIColor = UIColor.brown
    
    var fontSize: CGFloat = 15
    
    var isSelect: Bool = false
    
    var pageReuseIdentifier: String = ""
    var text: String = ""
    var normalTextColor: UIColor = .white
    var selectedTextColor: UIColor = .white
}

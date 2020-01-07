//
//  ZGUIDemoHomeModel.swift
//  ZGUIDemo
//
//  Created by temp on 2017/3/23.
//
//

import UIKit
import ZGNetwork
import ZGUI

class ZGUIDemoHomeModel: ZGModel {
    var pageIndex:Int = 0
    
    override func loadItems(_ paramters: [String:Any]?=nil, completion: @escaping ([String:Any]?) -> Void, failure: @escaping (ZGNetworkError) -> Void) {
        var item1:[ZGBaseUIItem] = []
        for i in 0...8{
            let homeItem = ZGUIDemoHomeItem.defualItem(i)
            item1.append(homeItem)
        }
        var item2 : [ZGBaseUIItem] = []
        for i in 9...18{
            let homeItem = ZGUIDemoHomeItem.defualItem(i)
            item2.append(homeItem)
        }
        var item3 : [ZGBaseUIItem] = []
        for i in 18...28{
            let homeItem = ZGUIDemoHomeItem.defualItem(i)
            item3.append(homeItem)
        }
        
        self.items.append(item1)
        self.items.append(item2)
        self.items.append(item3)
        
        let header1 = ZGUIDemoHomeSectionItem.defualtItem(title: "我是section0的头视图", section: 0, kind: .header)
        let footer1 = ZGUIDemoHomeSectionItem.defualtItem(title: "我是section0的尾视图", section: 0, kind: .footer)
        
        let header2 = ZGUIDemoHomeSectionItem.defualtItem(title: "我是section1的头视图", section: 1, kind: .header)
        let header3 = ZGUIDemoHomeSectionItem.defualtItem(title: "我是section2的头视图", section: 2, kind: .header)
        let footer2 = ZGUIDemoHomeSectionItem.defualtItem(title: "我是section1的尾视图", section: 1, kind: .footer)
        
        var sections : [ZGCollectionReusableViewItem] = []
        sections.append(header1)
        sections.append(header2)
        sections.append(header3)
        sections.append(footer1)
        sections.append(footer2)
        self.sections = sections
        
        
        completion(nil)
    }
}

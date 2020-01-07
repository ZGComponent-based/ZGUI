//
//  TableDemoModel.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2018/2/9.
//  Copyright © 2018年 zhaogang. All rights reserved.
//

import UIKit
import ZGUI
import ZGNetwork

class TableDemoModel: ZGModel {
    var sectionViewItems : [ZGTableReusableViewItem]?
    func genItems() -> [ZGTableReusableViewItem] {
        var pItems = [ZGTableReusableViewItem]()
        for i in 0..<10 {
            let item = TableItem()
            item.size.height = 40
            item.resetTitle("zhe\(i)")
            item.refreshLayout()
            pItems.append(item)
        }
        return pItems
    }
    
    func genGroupItems() -> [[ZGTableReusableViewItem]] {
        self.sectionViewItems = [ZGTableReusableViewItem]()
        var pItems = [[ZGTableReusableViewItem]]()
        var titles = ["A","B","C","D","E"]
        for i in 0..<5 {
            let header = TabelHeaderSection()
            header.size.height = 25
            header.resetTitle(titles[i])
            header.sectionIndex = i
            header.refreshLayout()
            header.kind = .header
            self.sectionViewItems?.append(header)
            
            var items1 = [ZGTableReusableViewItem]()
            for i in 0..<10 {
                let item = TableItem()
                item.size.height = 40
                item.resetTitle("zhe\(i)")
                item.refreshLayout()
                items1.append(item)
            }
            pItems.append(items1)
        }
        return pItems
    }

    override func loadItems(_ parameters: [String : Any]?,
                            completion: @escaping ([String : Any]?) -> Void,
                            failure: @escaping (ZGNetworkError) -> Void) {
        self.items = self.genGroupItems()
        completion(nil)
    }
}

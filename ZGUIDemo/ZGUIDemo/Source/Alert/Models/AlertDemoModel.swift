//
//  AlertDemoModel.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/8/28.
//

import UIKit
import ZGUI
import ZGNetwork

class AlertDemoModel: ZGModel {
    
    func wrapperItems() {
        let item1 = AlertDemoItem(style: .normal, content: "这个内容少一些", title: nil, buttonCount: 1)
        let item2 = AlertDemoItem(style: .normal, content: "这个内容少一些", title: "标题部分", buttonCount: 1)
        let item3 = AlertDemoItem(style: .normal, content: "这个内容多一些这个内容多一些这个内容多一些这个内容多一些这个内容多一些这个内容多一些", title: nil, buttonCount: 2)
        let item4 = AlertDemoItem(style: .normal, content: "这个内容少一些这个内容多一些这个内容多一些这个内容多一些这个内容多一些这个内容多一些", title: "标题", buttonCount: 2)
        
        let item5 = AlertDemoItem(style: .remind, content: "这个内容少一些", title: nil, buttonCount: 1)
        let item6 = AlertDemoItem(style: .remind, content: "这个内容少一些", title: "标题部分", buttonCount: 1)
        let item7 = AlertDemoItem(style: .remind, content: "这个内容多一些这个内容多一些这个内容多一些这个内容多一些这个内容多一些这个内容多一些", title: nil, buttonCount: 2)
        let item8 = AlertDemoItem(style: .remind, content: "这个内容少一些这个内容多一些这个内容多一些这个内容多一些这个内容多一些这个内容多一些", title: "标题", buttonCount: 2)
        
        self.items = [item1, item2, item3, item4, item5, item6, item7, item8]
    }
    
    override func loadItems(_ parameters: [String : Any]?,
                            completion: @escaping ([String : Any]?) -> Void,
                            failure: @escaping (ZGNetworkError) -> Void) {
        self.wrapperItems()
        completion (nil)
    }
}

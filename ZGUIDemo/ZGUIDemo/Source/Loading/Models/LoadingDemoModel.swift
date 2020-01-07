//
//  AlertDemoModel.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/8/28.
//

import UIKit
import ZGUI
import ZGNetwork

class LoadingDemoModel: ZGModel {
    
    func wrapperItems() {
        let item1 = LoadingDemoItem(style: .pageLoading, title: "全页面加载", loadingText: "数据加载中...")
        let item2 = LoadingDemoItem(style: .popup, title: "弹出小窗口加载", loadingText: "加载中...")
        let item3 = LoadingDemoItem(style: .trasparent, title: "背景透明加载", loadingText: nil)
 
        self.items = [item1, item2, item3]
    }
    
    override func loadItems(_ parameters: [String : Any]?,
                            completion: @escaping ([String : Any]?) -> Void,
                            failure: @escaping (ZGNetworkError) -> Void) {
        self.wrapperItems()
        completion (nil)
    }
}

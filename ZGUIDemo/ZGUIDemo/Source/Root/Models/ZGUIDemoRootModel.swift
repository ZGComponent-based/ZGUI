//
//  ZGUIDemoHomeModel.swift
//  ZGUIDemo
//
//  Created by temp on 2017/3/23.
//
//

import UIKit
import ZGUI

class ZGUIDemoRootModel: ZGModel {
    
    func rootItems() ->[ZGUIDemoRootItem]  {
        var items = [ZGUIDemoRootItem]()
        
        let width = (UIScreen.main.bounds.width - 30) / 2.0
        let size = CGSize.init(width: width, height: 80)
        
        let imageItem = ZGUIDemoRootItem()
        imageItem.size = size
        imageItem.title = "图片组件"
        imageItem.type = .image
        
        let collectionItem = ZGUIDemoRootItem()
        collectionItem.size = size
        collectionItem.title = "collectionView"
        collectionItem.type = .home
        
        let scrollItem = ZGUIDemoRootItem()
        scrollItem.size = size
        scrollItem.title = "横滑滚动controller"
        scrollItem.type = .hScroll
        
        let collectionItemRefresh = ZGUIDemoRootItem()
        collectionItemRefresh.size = size
        collectionItemRefresh.title = "刷新控件Demo"
        collectionItemRefresh.type = .refresh
        
        
        let cycle = ZGUIDemoRootItem()
        cycle.size = size
        cycle.title = "循环banner"
        cycle.type = .cycle
        
        let preview = ZGUIDemoRootItem()
        preview.size = size
        preview.title = "图片预览"
        preview.type = .preview
        
        
        let loadingItem = ZGUIDemoRootItem()
        loadingItem.size = size
        loadingItem.title = "Loading加载"
        loadingItem.type = .loading
        
        
        let toastItem = ZGUIDemoRootItem()
        toastItem.size = size
        toastItem.title = "Toast提示"
        toastItem.type = .toast
        
        let tipItem = ZGUIDemoRootItem()
        tipItem.size = size
        tipItem.title = "页面提示"
        tipItem.type = .pageTip
        
        let alertItem = ZGUIDemoRootItem()
        alertItem.size = size
        alertItem.title = "Alert弹窗"
        alertItem.type = .alert
        
        
        let albumItem = ZGUIDemoRootItem()
        albumItem.size = size
        albumItem.title = "相册组件"
        albumItem.type = .album
        
        let codeItem = ZGUIDemoRootItem()
        codeItem.size = size
        codeItem.title = "生成二维码"
        codeItem.type = .qrcode
        
        let slideItem = ZGUIDemoRootItem()
        slideItem.size = size
        slideItem.title = "横滑缩放"
        slideItem.type = .slideScale
        
        let tableItem = ZGUIDemoRootItem()
        tableItem.size = size
        tableItem.title = "TableDemo"
        tableItem.type = .table
        
        let hvScrollItem = ZGUIDemoRootItem()
        hvScrollItem.size = size
        hvScrollItem.title = "水平垂直滚动测试"
        hvScrollItem.type = .HVScroll
        
        items.append(imageItem)
        items.append(collectionItem)
        items.append(scrollItem)
        items.append(collectionItemRefresh)
        items.append(cycle)
        items.append(preview)
        items.append(loadingItem)
        items.append(toastItem)
        items.append(tipItem)
        
        items.append(alertItem)
        items.append(albumItem)
        
        items.append(codeItem)
        items.append(slideItem)
        
        items.append(tableItem)
        items.append(hvScrollItem)
        return items
    }
}

//
//  ZGAlbumCollectionModel.swift
//  ZGUI
//
//  Created by zhaogang on 2017/11/3.
//
import Photos
import UIKit
import ZGNetwork

open class ZGAlbumCollectionModel: ZGModel {
    var assets:[PHAsset]?
    var bottomItem:ZGAlbumBottomItem?
    
    init(assets:[PHAsset]?) {
        super.init()
        self.assets = assets
    }
    
    lazy var itemsService: ZGAlbumCollectionService = {
        return ZGAlbumCollectionService()
    }()
    
    func getSelectedCount() -> Int {
        var retCout:Int = 0
        guard let items = self.items as? [ZGAlbumCollectionItem] else {
            return 0
        }
        for item in items {
            if item.selcted {
                retCout += 1
            }
        }
        return retCout
    }
    
    func getSelectTotalSize() -> String? {
        var storeSize:Double = 0
        guard let items = self.items as? [ZGAlbumCollectionItem] else {
            return nil
        }
        for item in items {
            if item.selcted {
                storeSize += item.storeSize
            }
        }
        if storeSize > 0 {
            let m = storeSize / 1024.0
            return String(format: "%.2fM", m)
        }
        return nil
    }
    
    func getSelectAssets() -> [ZGAlbumCollectionItem]? {
        guard let items = self.items as? [ZGAlbumCollectionItem] else {
            return nil
        }
        var retAssets = [ZGAlbumCollectionItem]()
        for item in items {
            if item.selcted {
                retAssets.append(item)
            }
        }
        if retAssets.count > 0 {
            return retAssets
        } else {
            return nil
        }
    }
    
    func resetBottomItem() {
        var retCout:Int = self.getSelectedCount()
        if let bottomItem = self.bottomItem {
            if retCout > 0 {
                let selColor = "#000000"
                bottomItem.resetLeftTitle(color: selColor)
                bottomItem.resetRightTitle(color: selColor, count: retCout)
                let originalImage = ZGUIUtil.bundleForImage("bottom_origin_sel.png")
                let totalSize = self.getSelectTotalSize()
                bottomItem.resetOriginalTitle(color: selColor, image: originalImage, totalSize: totalSize)
                bottomItem.refreshLayout()
            } else {
                self.bottomItem = self.itemsService.getBottomItem()
            }
            bottomItem.defaultAssets = self.items as? [ZGAlbumCollectionItem]
            bottomItem.selectedAssets = self.getSelectAssets()
        }
    }
    
    override open func loadItems(_ parameters: [String : Any]?, completion: @escaping ([String : Any]?) -> Void, failure: @escaping (ZGNetworkError) -> Void) {
        self.bottomItem = self.itemsService.getBottomItem()
        self.itemsService.loadDefaultItems(assets:self.assets) {[weak self] (items) in
            if let items = items {
                self?.items = items
            }
            completion(nil)
        }
    }
}

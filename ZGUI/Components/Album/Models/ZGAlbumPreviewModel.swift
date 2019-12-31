//
//  ZGAlbumPreviewModel.swift
//  ZGUI
//
//  Created by zhaogang on 2017/11/6.
//

import UIKit
import ZGUI
import ZGNetwork

class ZGAlbumPreviewModel: ZGModel {
    var bottomItem:ZGAlbumBottomItem?
    var selectedItem:ZGAlbumCollectionItem?

    override func loadItems(_ parameters: [String : Any]?, completion: @escaping ([String : Any]?) -> Void, failure: @escaping (ZGNetworkError) -> Void) {
        self.bottomItem = parameters?["bottomItem"] as? ZGAlbumBottomItem
        self.selectedItem = parameters?["selectedItem"] as? ZGAlbumCollectionItem
        
        if let albumItems = self.bottomItem?.defaultAssets {
            var pItems = [ZGImagePreviewItem]()
            for item in albumItems {
                let item1 = ZGImagePreviewItem(imageUrl: "")
                item1.asset = item.imageAsset
                pItems.append(item1)
            }
            self.items = pItems
        }
        completion(nil)
    }
}

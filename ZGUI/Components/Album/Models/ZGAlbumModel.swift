//
//  ZGAlbumModel.swift
//  ZGUI
//
//  Created by zhaogang on 2017/11/3.
//

import UIKit
import ZGNetwork

open class ZGAlbumModel: ZGModel {
    lazy var itemsService: ZGAlbumItemService = {
        return ZGAlbumItemService()
    }()
    
    override open func loadItems(_ parameters: [String : Any]?, completion: @escaping ([String : Any]?) -> Void, failure: @escaping (ZGNetworkError) -> Void) {
        self.itemsService.loadDefaultItems {[weak self] (items) in
            if let items = items {
                self?.items = items
            }
            completion(nil)
        }
    }
}

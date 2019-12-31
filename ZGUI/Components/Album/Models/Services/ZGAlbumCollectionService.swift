//
//  ZGAlbumCollectionService.swift
//  ZGUI
//
//  Created by zhaogang on 2017/11/3.
//

import UIKit
import Photos

class ZGAlbumCollectionService: NSObject {
    static let spacing:CGFloat = 5
    
    func getBottomItem() -> ZGAlbumBottomItem {
        let width:CGFloat = UIScreen.main.bounds.width
        let rect = CGRect.init(x: 0, y: 0, width: width, height: 44)
        let item = ZGAlbumBottomItem(frame: rect, total: 9)
        item.resetLeftTitle()
        item.resetRightTitle(count: 0)
        let image = ZGUIUtil.bundleForImage("bottom_origin_default.png")
        item.resetOriginalTitle(image: image, totalSize:nil)
        item.refreshLayout()
        
        return item
    }

    func getItems(assets: [PHAsset]?) -> [ZGAlbumCollectionItem]? {
        guard let assets = assets else {
            return nil
        }
        let screenWidth:CGFloat = UIScreen.main.bounds.size.width
        let itemWidth:CGFloat = floor((screenWidth - ZGAlbumCollectionService.spacing*5) / 4)
        let size = CGSize.init(width: itemWidth, height: itemWidth)
        var items = [ZGAlbumCollectionItem]()
        
        var index:Int = 0
        for asset in assets {
            index += 1
            let item = ZGAlbumCollectionItem(size: size, asset: asset)
            items.append(item)
            item.itemIndex = index
            item.resetSelect(false)

        }
        return items
    }
    
    func loadDefaultItems(assets: [PHAsset]?, completionHandler:  @escaping ([ZGAlbumCollectionItem]?) -> Void) -> Void {
        DispatchQueue.global().async {
            
            let rowItems = self.getItems(assets:assets)
            
            DispatchQueue.main.async {
                completionHandler(rowItems)
            }
        }
    }
}

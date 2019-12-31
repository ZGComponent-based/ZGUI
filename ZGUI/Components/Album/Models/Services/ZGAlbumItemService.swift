//
//  ZGAlbumItemService.swift
//  ZGUI
//
//  Created by zhaogang on 2017/11/3.
//

import UIKit
import Photos

open class ZGAlbumItemService: NSObject {
    
    func getAssets(with assetCollection:PHFetchResult<PHAssetCollection>) -> [PHAsset] {
        var assets = [PHAsset]()
        assetCollection.enumerateObjects({ (collection, index, stop) in
            let result = PHAsset.fetchAssets(in: collection, options: nil)
            result.enumerateObjects({ (asset, index, stop) in
                if asset.mediaType == .image {
                    assets.append(asset)
                }
            })
        })
        return assets
    }
    
    func getAlbumItem(with title:String?, collectionType:PHAssetCollectionType,  subType:PHAssetCollectionSubtype) -> ZGAlbumItem {
        let width:CGFloat = UIScreen.main.bounds.width
        let size = CGSize.init(width: width, height: 60)
        
        let albumItem1 = ZGAlbumItem(size:size)
        
        let userLibraties: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: collectionType, subtype: subType, options: nil)
        albumItem1.assets = self.getAssets(with: userLibraties)
        var count = 0
        if let count1 = albumItem1.assets?.count {
            count = count1
        }
        
        albumItem1.imageAsset = albumItem1.assets?.last
        albumItem1.resetTitle(title, count: count)
        let imagePath = ZGUIUtil.bundleForImage("right_arrow@2x.png")
        albumItem1.resetArrowImage(imagePath, size: CGSize.init(width: 8, height: 15))
        albumItem1.resetBottomLine()
        albumItem1.refreshLayout()
        return albumItem1
    }
 
    func getAlbums() -> [ZGAlbumItem] {
        var items = [ZGAlbumItem]()
        
        //相机胶卷
        let albumItem1 = self.getAlbumItem(with: "相机胶卷", collectionType: .smartAlbum, subType: .smartAlbumUserLibrary)
        items.append(albumItem1)
         
        if #available(iOS 9.0, *) {
            let albumItem2 = self.getAlbumItem(with: "屏幕快照", collectionType: .smartAlbum, subType: .smartAlbumScreenshots)
            items.append(albumItem2)
        }
        
        if #available(iOS 10.3, *) {
            let albumItem3 = self.getAlbumItem(with: "Live Photo", collectionType: .smartAlbum, subType: .smartAlbumLivePhotos)
            items.append(albumItem3)
        }
        
        var index = 0
        for item in items {
            index += 1
            item.itemIndex = index
        }
        
        return items
    }
    
    func loadDefaultItems(completionHandler:  @escaping ([ZGAlbumItem]?) -> Void) -> Void {
        DispatchQueue.global().async {
 
            let rowItems = self.getAlbums()
            
            DispatchQueue.main.async {
                completionHandler(rowItems)
            }
        }
    }
}

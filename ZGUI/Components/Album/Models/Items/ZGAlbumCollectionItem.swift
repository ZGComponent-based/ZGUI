//
//  ZGAlbumCollectionItem.swift
//  ZGUI
//
//  Created by zhaogang on 2017/11/3.
//

import UIKit
import Photos

public class ZGAlbumCollectionItem: ZGBaseUIItem {
    var arrowImage:String?
    var selcted:Bool = false
    var imageAsset:PHAsset
    var image:UIImage?
    var arrowFrame:CGRect = .zero
    var countHandler:(() -> Int)?
    
    //占用的存储空间, 按K
    var storeSize:Double = 0
    
    init(size:CGSize, asset:PHAsset) {
        self.imageAsset = asset
        super.init()
        self.size = size
    }

    public override func mapViewType() -> ZGCollectionViewCell.Type {
        return ZGAlbumCollectionCell.self
    }
    
    func loadIimage(completion: @escaping (UIImage?, Int?) -> Swift.Void)  {
        let size = CGSize.init(width: 200, height: 200)
        let options:PHImageRequestOptions = PHImageRequestOptions.init()
        options.resizeMode = .exact
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        PHCachingImageManager.default().requestImage(for: imageAsset,
                                                     targetSize: size,
                                                     contentMode: PHImageContentMode.aspectFill,
                                                     options: options) { [weak self] (image, info) in
                                                        completion(image, self?.itemIndex)
        }
        loadImageStoreSize()
    }
    
    func loadImageStoreSize()  {
        if self.storeSize > 0 {
            return
        }
        let options:PHImageRequestOptions = PHImageRequestOptions.init()
        options.resizeMode = .exact
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        PHCachingImageManager.default().requestImageData(for: imageAsset, options: options) {[weak self] (data, dataUTI, orientation, params) in
            if let data = data {
                 self?.storeSize = Double(data.count) / 1024.0
            }
        }
    }
    
    func resetSelect(_ selectedParam:Bool) {
        self.selcted = selectedParam
        if selectedParam {
            self.arrowImage = ZGUIUtil.bundleForImage("album_sel.png")
        } else {
            self.arrowImage = ZGUIUtil.bundleForImage("album_sel_default@2x.png")
        }
        self.arrowFrame.size = CGSize.init(width: 30, height: 30)
        self.arrowFrame.origin.x = self.size.width - self.arrowFrame.width
    }
}

//
//  ZGImagePreviewItem.swift
//  Pods
//
//  Created by zhaogang on 2017/7/12.
//
//

import UIKit
import Photos

public class ZGImagePreviewItem: NSObject {
    public var userData:Any?
    public var imageUrl:String
    public var bigImageUrl:String
    public var defaultImageUrl:String?
    public var failedImageUrl:String?
    public var identifier:String = "ZGImagePreview"
    
    public var asset:PHAsset?
    func loadImage(completion: @escaping (UIImage?, PHAsset) -> Swift.Void)  {
        guard let imageAsset = self.asset else {
            return
        }
        
        let options:PHImageRequestOptions = PHImageRequestOptions.init()
        options.resizeMode = .exact
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        PHCachingImageManager.default().requestImageData(for: imageAsset, options: options) {[weak self] (data, dataUTI, orientation, params) in
            var image:UIImage? = nil
            if let data = data {
                image = UIImage(data: data)
            }
            completion(image, imageAsset)
        }
    }
    
    //是否长按保存图片，默认false
    public var enableSavePhoto:Bool = false
    
    //是否可以放大查看原图
    public var enableScale:Bool = false
    
    //是否平铺图片，默认为false, 根据屏幕宽度正常展示图片，如果为true则代表填充整个视图
    public var isFlatPattern:Bool = false
    
    public var index:Int = 0
    
    public init(imageUrl:String, defaultImageUrl:String? = nil, failedImageUrl:String? = nil) {
        self.imageUrl = imageUrl
        self.bigImageUrl = imageUrl
        self.defaultImageUrl = defaultImageUrl
        self.failedImageUrl = failedImageUrl
        
        super.init()
    }
}

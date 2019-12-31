//
//  ZGAlbumExtension.swift
//  ZGUI
//
//  Created by zhaogang on 2017/11/3.
//
import Photos

extension PHAsset {
    
    @discardableResult
    func requestImage(size: CGSize, block: @escaping ((Dictionary<String, Any>) -> Void)) -> PHImageRequestID {
        let options = PHImageRequestOptions.init()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        return self.requestImage(options: options, size: size, block: block)
    }
    
    @discardableResult
    func requestImage(options: PHImageRequestOptions, size: CGSize, block: @escaping ((Dictionary<String, Any>) -> Void)) -> PHImageRequestID {
        return PHCachingImageManager.default().requestImage(for: self, targetSize: size, contentMode: PHImageContentMode.aspectFill, options: options) { (image, info) in
     
        }
    }

}

//
//  ZGAlbumItem.swift
//  ZGUI
//
//  Created by zhaogang on 2017/11/3.
//

import UIKit
import Photos

public class ZGAlbumItem: ZGBaseUIItem {
    var titleLabel:NSAttributedString?
    var titleLabelFrame:CGRect = .zero
    
    var selectedCountLabel:NSAttributedString?
    var selectedCountLabelFrame:CGRect = .zero
    
    var arrowImage:String?
    var arrowImageFrame:CGRect = .zero
    
    var leftImageFrame:CGRect = .zero
    
    let marginLeft:CGFloat = 15
    var bottomLineFrame:CGRect = .zero
    
    var assets: [PHAsset]?
    var imageAsset:PHAsset?
    var title:String?
    
    public init(size:CGSize) {
        super.init()
        self.size = size
    }
    
    public override func mapViewType() -> ZGCollectionViewCell.Type {
        return ZGAlbumCell.self
    }
    
    func loadIimage(completion: @escaping (UIImage?, Int?) -> Swift.Void)  {
        
        guard let imageAsset = self.imageAsset else {
            return
        }
        let size = CGSize.init(width: 120, height: 120)
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
    }
    
    public func resetTitle(_ title:String?, count:Int) {
        
        guard let title = title else {
            return
        }
        self.title = title
        
        let mainSize:CGFloat = 15
        let text1 = "<font color='#000000' size='\(mainSize)'>\(title) </font>"
        let text2 = "<font color='#9b9b9b' size='\(mainSize)'>(\(count))</font>"
        let text = text1 + text2
        
        self.titleLabel = ZGUILabelStyle.attributedStringOfHtmlText(text)
        if let attributedText = self.titleLabel {
            self.titleLabelFrame.size = attributedText.textSize(constrainedToSize: CGSize.init(width: Int.max, height: 100))
        }
    }
    
    public func resetSelectedCount(_ title:String?) {
        
        guard let title = title else {
            return
        }
        
        let mainSize:CGFloat = 15
        let text = "<font color='#ffffff' size='\(mainSize)'>\(title)</font>"
        
        self.selectedCountLabel = ZGUILabelStyle.attributedStringOfHtmlText(text)
        if let attributedText = self.selectedCountLabel {
            self.selectedCountLabelFrame.size = attributedText.textSize(constrainedToSize: CGSize.init(width: Int.max, height: 100))
        }
    }
    
    public func resetBottomLine() {
        let width:CGFloat = self.size.width - self.marginLeft
        let height:CGFloat = 0.5
        self.bottomLineFrame.size = CGSize.init(width: width, height: height)
    }
    
    public func resetArrowImage(_ imagePath:String?, size:CGSize) {
        self.arrowImage = imagePath
        self.arrowImageFrame.size = size
    }
    
    public func refreshLayout() {
        let imageWidth:CGFloat = self.size.height - 2
        self.leftImageFrame.size = CGSize.init(width: imageWidth, height:  imageWidth)
        self.leftImageFrame.origin.x = self.marginLeft
        self.leftImageFrame.origin.y = (self.size.height - self.leftImageFrame.height) / 2
        
        self.arrowImageFrame.origin.y = (self.size.height - self.arrowImageFrame.height) / 2
        self.arrowImageFrame.origin.x = self.size.width - self.arrowImageFrame.width - self.marginLeft
        
        self.titleLabelFrame.origin.y = 15
        self.titleLabelFrame.origin.x = self.leftImageFrame.origin.x + self.leftImageFrame.width + 10
        
        self.selectedCountLabelFrame.origin.x = self.arrowImageFrame.origin.x - self.selectedCountLabelFrame.width - 5
        self.selectedCountLabelFrame.origin.y = (self.size.height - self.selectedCountLabelFrame.height) / 2
        
        self.bottomLineFrame.origin.x = self.marginLeft
        self.bottomLineFrame.origin.y = self.size.height - self.bottomLineFrame.height
    }
}

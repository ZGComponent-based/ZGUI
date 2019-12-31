//
//  ZGSlideScaleCell.swift
//  ZGUI
//
//  Created by zhaogang on 2017/12/20.
//

import UIKit

open class ZGSlideScaleCell: ZGCollectionViewCell {
    
    public lazy var imageView: ZGImageView = {
        return self.addImageView()
    }()
    
    open override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
//        self.imageView.frame = self.bounds
    }
    open override func initContent() {
        super.initContent()
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }
    open override func setObject(_ obj: ZGBaseUIItem) {
        super.setObject(obj)
        
        guard let item = self.item as? ZGSlideScaleItem else {
            return
        }
        
        self.imageView.urlPath = item.imageUrl
    }
    
}

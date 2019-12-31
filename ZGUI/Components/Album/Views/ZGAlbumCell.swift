//
//  ZGAlbumCell.swift
//  ZGUI
//
//  Created by zhaogang on 2017/11/3.
//

import UIKit

public class ZGAlbumCell: ZGCollectionViewCell {
    weak var titleLabel:UILabel!
    weak var selectedCountLabel:UILabel!
    weak var arrowImage:ZGImageView!
    weak var leftImage:ZGImageView!
    weak var lineLayer:CALayer!
    
    public override func initContent() {
        super.initContent()
        
        self.titleLabel = self.addLabel()
        self.selectedCountLabel = self.addLabel()
        self.arrowImage = self.addImageView()
        if self.lineLayer == nil {
            let layer:CALayer = CALayer()
            self.layer.addSublayer(layer)
            self.lineLayer = layer
        }
        self.leftImage = self.addImageView()
        self.leftImage.backgroundColor = UIColor.color(withHex: 0xEEEEE0)
        self.lineLayer.backgroundColor = UIColor.color(withHex: 0xf3f3f3).cgColor
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let item = self.item as? ZGAlbumItem else {
            return
        }
        
        self.titleLabel.frame = item.titleLabelFrame
        self.arrowImage.frame = item.arrowImageFrame
        self.selectedCountLabel.frame = item.selectedCountLabelFrame
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        self.lineLayer.frame = item.bottomLineFrame
        CATransaction.commit()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        self.titleLabel.attributedText = nil
        self.selectedCountLabel.attributedText = nil
        self.arrowImage.unsetImage()
        self.leftImage.unsetImage()
    }
    
    public override func setObject(_ obj: ZGBaseUIItem) {
        super.setObject(obj)
        
        guard let item = self.item as? ZGAlbumItem else {
            return
        }
        
        self.titleLabel.attributedText = item.titleLabel
        self.selectedCountLabel.attributedText = item.selectedCountLabel
        self.arrowImage.urlPath = item.arrowImage
        self.leftImage.frame = item.leftImageFrame
        
        let itemIndex = item.itemIndex
        item.loadIimage {[weak self] (image, index) in
            if let index = index, let itemIndex = itemIndex {
                self?.leftImage.setImage(image)
            }
        }
        
        self.layoutSubviews()
    }
}

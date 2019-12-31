//
//  ZGAlbumBottomView.swift
//  ZGUI
//
//  Created by zhaogang on 2017/11/3.
//

import UIKit

class ZGAlbumBottomView: ZGImagePreviewBottomView {
    
    lazy var originalImage: ZGImageView = {
        let imageView = ZGImageView()
        self.addSubview(imageView)
        imageView.backgroundColor = UIColor.clear
        return imageView
    }()
    
    lazy var lineLayer: CALayer = {
        let layer1 = CALayer()
        self.layer.addSublayer(layer1)
        layer1.backgroundColor = UIColor.color(withHex: 0xd2d2d2).cgColor
        return layer1
    }()
    
    lazy var leftLabel: UIButton = {
        let label = UIButton(type:.custom)
        self.addSubview(label)
        return label
    }()
    
    lazy var rightLabel: UIButton = {
        let label = UIButton(type:.custom)
        self.addSubview(label) 
        return label
    }()
    
    lazy var originalLabel: UIButton = {
        let label = UIButton(type:.custom)
        self.addSubview(label)
        return label
    }()
    
    lazy var countLabel: UIButton = {
        let label = UIButton(type:.custom)
        self.addSubview(label)
        return label
    }()

    override func setItem(_ item: ZGImagePreviewBottomItemProtocol) {
        super.setItem(item)
        
        guard let item = self.item as? ZGAlbumBottomItem else {
            return
        }
        
        self.leftLabel.setAttributedTitle(item.leftTitle, for: .normal)
        self.rightLabel.setAttributedTitle(item.rightTitle, for: .normal)
        self.countLabel.setAttributedTitle(item.countTitle, for: .normal)
        self.originalLabel.setAttributedTitle(item.originalTitle, for: .normal)
        self.countLabel.backgroundColor = UIColor.red
        self.countLabel.layer.masksToBounds = true
        self.originalImage.unsetImage()
        self.originalImage.urlPath = item.originalImage
        self.layoutSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let item = self.item as? ZGAlbumBottomItem else {
            return
        }
        
        self.countLabel.frame = item.countFrame
        self.rightLabel.frame = item.rightTitleFrame
        self.leftLabel.frame = item.leftTitleFrame
        self.originalLabel.frame = item.originalTitleFrame
        self.originalImage.frame = item.originalImageFrame
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        self.lineLayer.frame = item.topLineFrame
        self.countLabel.layer.cornerRadius = self.countLabel.height/2
        CATransaction.commit()
    }
 
}

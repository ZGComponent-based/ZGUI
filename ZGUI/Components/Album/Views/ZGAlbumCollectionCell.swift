//
//  ZGAlbumCollectionCell.swift
//  ZGUI
//
//  Created by zhaogang on 2017/11/3.
//

import UIKit

class ZGAlbumCollectionCell: ZGCollectionViewCell {
    
    weak var selectButton:UIButton!
    weak var selectAreaButton:UIButton!
    weak var albumImage:ZGImageView!
    
    @objc func btnHandler(_ sender:UIButton) {
        guard let item = self.item as? ZGAlbumCollectionItem else {
            return
        }
        
        item.resetSelect(!item.selcted)
        if let countHandler = item.countHandler {
            let count = countHandler()
            if count > 9 {
                item.resetSelect(!item.selcted)
            } else {
                self.selectButton.setImage(item.arrowImage, placeholderImage: nil, for: .normal)
            }
        }
        
    }
    
    public override func initContent() {
        super.initContent()
        
        self.albumImage = self.addImageView()
        self.albumImage.backgroundColor = UIColor.color(withHex: 0xEEEEE0)
        self.selectButton = self.addButton()
        self.selectAreaButton = self.addButton()
        self.selectAreaButton.addTarget(self, action: #selector(btnHandler(_:)), for: .touchUpInside)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let item = self.item as? ZGAlbumCollectionItem else {
            return
        }
        
        self.albumImage.frame = self.bounds
        self.selectButton.frame = item.arrowFrame
        
        var rect = self.selectAreaButton.frame
        rect.size = CGSize.init(width: 44, height: 44)
        rect.origin.x = self.width - rect.width
        self.selectAreaButton.frame = rect
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        self.albumImage.unsetImage()
    }
    
    public override func setObject(_ obj: ZGBaseUIItem) {
        super.setObject(obj)
        
        guard let item = self.item as? ZGAlbumCollectionItem else {
            return
        } 
        self.selectButton.setImage(item.arrowImage, placeholderImage: nil, for: .normal)
        
        let itemIndex = item.itemIndex
        item.loadIimage {[weak self] (image, index) in
            if let index = index, let itemIndex = itemIndex {
                self?.albumImage.setImage(image, enableAnimation: true)
            }
        }
        
        self.layoutSubviews()
    }
}

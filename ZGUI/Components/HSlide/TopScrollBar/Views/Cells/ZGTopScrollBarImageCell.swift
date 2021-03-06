//
//  ZGTopScrollBarImageCell.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/3/27.
//
//

import UIKit
import FLAnimatedImage

open class ZGTopScrollBarImageCell: ZGCollectionViewCell {

    open var gifImageView:FLAnimatedImageView!
    
    override public init(frame: CGRect) {
        super.init(frame: frame);
        self.initContentView();
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.initContentView();
    }
    
    deinit {
        if let _ = self.gifImageView.animatedImage {
            self.gifImageView.stopAnimating();
            self.gifImageView.animatedImage = nil;
        }
    }
    
    open func initContentView() {
        self.backgroundColor = UIColor.clear;
        self.contentView.backgroundColor = UIColor.clear;
        
        self.gifImageView = FLAnimatedImageView.init();
        self.gifImageView.contentMode = .scaleAspectFit;
        self.gifImageView.backgroundColor = UIColor.clear;
        self.contentView.addSubview(self.gifImageView);
    }
    
    override open func setObject(_ obj: ZGBaseUIItem) {
        super.setObject(obj);
        guard let item = self.item as? ZGTopScrollBarImageItem else {
            return;
        }
        self.backgroundColor = UIColor.clear;

        var data = item.imageData;
        if item.imageSelectData != nil && item.isSelect {
            data = item.imageSelectData!;
        }
        
        if let _ = self.gifImageView.animatedImage {
            if data == self.gifImageView.animatedImage.data {
                //防止每次都设置图片，导致gif图片每次都重置
                return;
            }else {
                self.gifImageView.stopAnimating();
                self.gifImageView.animatedImage = nil;
            }
        }else {
            self.gifImageView.image = nil;
        }
        
        let image = FLAnimatedImage.init(animatedGIFData: data);
        if let _ = image {
            self.gifImageView.animatedImage = image;
        }else {
            self.gifImageView.image = UIImage.init(data: data);
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews();
        guard let item = self.item as? ZGTopScrollBarImageItem else {
            return;
        }
        self.gifImageView.frame = self.bounds.insetBy(dx: item.horizontalPadding, dy: item.verticalPadding);
    }

}

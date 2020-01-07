//
//  AlertDemoItem.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/8/28.
//

import UIKit
import ZGUI

class AlertDemoCell: ZGCollectionViewCell {
    weak var lineLayer:CALayer!
    weak var titleLabel:UILabel!
 
    override func initContent() {
        super.initContent()
        self.titleLabel = self.addLabel()
        let layer:CALayer = CALayer()
        self.layer.addSublayer(layer)
        self.lineLayer = layer
        
        self.lineLayer.backgroundColor = UIColor.color(withHex: 0xd1d1d1).cgColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initContent()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let item = self.item as? AlertDemoItem else {
            return
        }
        
        self.titleLabel.frame = item.titleLabelFrame
        
        var rect = self.lineLayer.frame
        rect.origin.x = 0
        rect.size.width = self.width
        rect.size.height = 0.5
        rect.origin.y = self.height - rect.size.height
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        self.lineLayer.frame = rect
        CATransaction.commit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.titleLabel.attributedText = nil
    }
    
    override func setObject(_ obj: ZGBaseUIItem) {
        super.setObject(obj)
        
        guard let item = self.item as? AlertDemoItem else {
            return
        }
        
        self.titleLabel.attributedText = item.titleLabel
    }
}

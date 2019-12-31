//
//  ZGNormalNoTitleAlert.swift
//  Pods
//
//  Created by zhaogang on 2017/8/25.
//
//

import UIKit

class ZGNormalNoTitleAlert: ZGAlertView {

    weak var contentLabel:UILabel!
    var vLineLayer:CALayer!
    var contentVerticalMargin:CGFloat = 28 //如果文字高度+上下间距大于topMinHeight, 则文字垂直拒中
    
    //最多只支持两个按钮
    override func setItem(_ item:ZGAlertItem) {
        super.setItem(item)
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 12
        
        guard let content = item.content else {
            return
        }
        self.contentLabel = self.addLabel()
        self.addButtons(item: item)
        self.contentLabel.text = content
        self.contentLabel.lineBreakMode = .byCharWrapping
        self.lineLayer = self.addLineLayer()
        self.vLineLayer = self.addLineLayer()
        
        if let items = item.buttonItems {
            self.vLineLayer.isHidden = items.count < 2
        }
        
        self.contentLabel.textColor = UIColor.color(withHex: 0x666666)
        
        self.layoutSubviews()
    }
 
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let content = self.contentLabel.text else {
            return
        }
        
        let marginLeft:CGFloat = 14
        
        let topMinHeight:CGFloat = 108 //内容部分的最低高度
        
        let labelWidth:CGFloat = self.width - marginLeft*2
        var labelSize = CGSize.init(width: labelWidth, height: CGFloat(Int.max))
        
        if let font = self.contentLabel.font {
            let attributes = [NSAttributedString.Key.font:font]
            labelSize = content.textSize(attributes: attributes, constrainedToSize: labelSize)
        }
        //布局文字
        var rect = self.contentLabel.frame
        rect.origin.x = (self.width - rect.width) / 2
        
        var contentHeight:CGFloat = labelSize.height + contentVerticalMargin*2
        if contentHeight < topMinHeight {
            contentHeight = topMinHeight
        }
        
        rect.origin.y = (contentHeight - labelSize.height) / 2
        rect.size = labelSize
        self.contentLabel.frame = rect
 
        var lineRect = self.lineLayer.frame
        lineRect.origin.x = 0
        lineRect.size.width = self.width
        lineRect.size.height = 0.5
        lineRect.origin.y = contentHeight
        
        
        var vlineRect = self.vLineLayer.frame
        vlineRect.origin.x = self.width / 2
        vlineRect.size.width = 0.5
        vlineRect.size.height = self.buttonHeight
        vlineRect.origin.y = contentHeight
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        self.lineLayer.frame = lineRect
        self.vLineLayer.frame = vlineRect
        CATransaction.commit()
        
        self.realHeight = contentHeight + self.buttonHeight
    }
}

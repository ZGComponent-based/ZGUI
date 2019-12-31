//
//  ZGNormalAlert.swift
//  Pods
//
//  Created by zhaogang on 2017/8/25.
//
//

import UIKit

class ZGNormalAlert: ZGAlertView {
    weak var contentLabel:UILabel!
    weak var titleLabel:UILabel!
    
    lazy var vLineLayer: CALayer = {
        return self.addLineLayer()
    }()
    
    var marginTop:CGFloat = 50
    var titleContentGap:CGFloat = 14
    
    public var titleFont = UIFont.boldSystemFont(ofSize: 16)
    public var contentFont = UIFont.systemFont(ofSize: 10)
    
    //最多只支持两个按钮
    override func setItem(_ item:ZGAlertItem) {
        super.setItem(item)
        if let f1 = item.titleFont {
            self.titleFont = f1
        }
        if let f1 = item.contentFont {
            self.contentFont = f1
        }
        
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 12
        
        guard let title = item.title, let content = item.content else {
            return
        }
        self.titleLabel = self.addLabel()
        self.contentLabel = self.addLabel()
        
        self.titleLabel.text = title
        self.titleLabel.font = self.titleFont
        self.titleLabel.textColor = UIColor.colorOfHexText("#3E434C")
        
        self.contentLabel.font = self.contentFont
        self.contentLabel.textColor = UIColor.colorOfHexText("#3E434C")
        self.contentLabel.text = content
        
        self.addButtons(item: item)
        
        self.lineLayer = self.addLineLayer()
        if let items = item.buttonItems {
            self.vLineLayer.isHidden = items.count < 2
        }
        
        self.layoutSubviews()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let content = self.contentLabel?.text, let title = self.titleLabel?.text else {
            return
        }
        
        var titleRect = self.titleLabel.frame
        var contentRect = self.contentLabel.frame
        
        let marginLeft:CGFloat = 14
        let marginBottom:CGFloat = 32 //文字距离底部按钮之间的距离
        
        let labelWidth:CGFloat = self.width - marginLeft*2
        
        //布局标题
        titleRect.size = CGSize.init(width: labelWidth, height: CGFloat(Int.max))
        var attributes = [NSAttributedString.Key.font:self.titleFont]
        titleRect.size = title.textSize(attributes: attributes, constrainedToSize: titleRect.size)
        titleRect.origin.x = (self.width - titleRect.width) / 2
        titleRect.origin.y = marginTop
        self.titleLabel.frame = titleRect
        
        
        //布局标题
        contentRect.size = CGSize.init(width: labelWidth, height: CGFloat(Int.max))
        attributes = [NSAttributedString.Key.font:self.contentFont]
        contentRect.size = content.textSize(attributes: attributes, constrainedToSize: contentRect.size)
        contentRect.origin.x = (self.width - contentRect.width) / 2
        contentRect.origin.y = titleRect.origin.y + titleRect.height + titleContentGap
        self.contentLabel.frame = contentRect
 
        var lineRect = self.lineLayer.frame
        lineRect.origin.x = 0
        lineRect.size.width = self.width
        lineRect.size.height = 0.5
        lineRect.origin.y = contentRect.origin.y + contentRect.height + marginBottom
        
        var vlineRect = self.vLineLayer.frame
        vlineRect.origin.x = self.width / 2
        vlineRect.size.width = 0.5
        vlineRect.size.height = self.buttonHeight
        vlineRect.origin.y = self.height - self.buttonHeight
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        self.lineLayer.frame = lineRect
        self.vLineLayer.frame = vlineRect
        CATransaction.commit()
        
        self.realHeight = lineRect.origin.y + self.buttonHeight
    }
}

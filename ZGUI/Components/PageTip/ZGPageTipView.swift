//
//  ZGPageTipView.swift
//  Pods
//
//  Created by zhaogang on 2017/8/8.
//
//

import UIKit

open class ZGPageTipView: ZGImageView {
public typealias ZGPageTipHandler = (ZGPageTipItem) -> Void
    
    public var tipHandler:ZGPageTipHandler?
    
    public weak var titleLabel:UILabel?
    public weak var detailLabel:UILabel?
    public weak var errorLabel:UILabel? //显示在右下角底部的文字
    public weak var imageView:ZGImageView?
    public weak var button:UIButton?
    
    public var item:ZGPageTipItem?
    
    @objc func btnHandler(_ sender:UIButton) {
        self.tapSelf()
    }
    
    @objc func tapSelf()  {
        guard let item = self.item else {
            return
        }
        if let tipHandler = self.tipHandler {
            tipHandler(item)
        }
    }
    
    func addLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        self.addSubview(label)
        return label
    }
    
    func addButton() -> UIButton {
        let button = UIButton(type: .custom)
        self.addSubview(button)
        return button
    }
    
    func addImage() -> ZGImageView {
        let imageView = ZGImageView()
        self.addSubview(imageView)
        imageView.backgroundColor = UIColor.clear
        imageView.isUserInteractionEnabled = false
        return imageView
    }
    
    func setTipItem(_ item:ZGPageTipItem) {
        self.item = item
        
        if let title = item.title {
            if self.titleLabel == nil {
                self.titleLabel = self.addLabel()
            }
            self.titleLabel?.attributedText = title
            self.titleLabel?.textAlignment = .center
        }
        
        if let detail = item.detail {
            if self.detailLabel == nil {
                self.detailLabel = self.addLabel()
            }
            self.detailLabel?.attributedText = detail
        }
        
        if let errorText = item.errorText {
            if self.errorLabel == nil {
                self.errorLabel = self.addLabel()
            }
            self.errorLabel?.attributedText = errorText
        }
        
        if item.buttonTitle != nil {
            if self.button == nil {
                self.button = self.addButton()
                self.button?.setAttributedTitle(item.buttonTitle, for: .normal)
                self.button?.addTarget(self, action: #selector(btnHandler(_:)), for: .touchUpInside)
                if item.isHomeworkDetai {
                    self.button?.backgroundColor = UIColor.colorOfHexText("#2D5BFF")
                    self.button?.layer.cornerRadius = 23
                } else {
                    self.button?.backgroundColor = UIColor.white
                    self.button?.layer.borderColor = UIColor.color(withHex: 0x333333).cgColor
                    self.button?.layer.borderWidth = 0.5
                    self.button?.layer.cornerRadius = 5
                }
                self.button?.layer.masksToBounds = true
            }
        }
        
        if let imageBundle = item.centerImage {
            if self.imageView == nil {
                self.imageView = self.addImage()
                self.imageView?.urlPath = imageBundle
            }
        }
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let item = self.item else {
            return
        }
        
        self.titleLabel?.frame = item.titleFrame
        self.detailLabel?.frame = item.detailFrame
        self.errorLabel?.frame = item.errorTextFrame
        self.button?.frame = item.buttonTitleFrame
        self.imageView?.frame = item.centerImageFrame
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapSelf))
        self.addGestureRecognizer(tap)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

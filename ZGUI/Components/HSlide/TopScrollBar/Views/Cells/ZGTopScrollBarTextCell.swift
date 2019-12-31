//
//  ZGTopScrollBarTextCell.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/3/27.
//
//

import UIKit

open class ZGTopScrollBarTextCell: ZGCollectionViewCell {
    
    open var titleLabel:UILabel!;
    open var test_titleLabel:NSAttributedString?
    open var test_titleLabelFrame:CGRect = .zero
    open var redBageValueLabel:UILabel!;
    open var test_redBageValueLabel:NSAttributedString?
    open var test_redBageValueLabelFrame:CGRect = .zero
    
    override public init(frame: CGRect) {
        super.init(frame: frame);
        self.initContentView();
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.initContentView();
    }
    
    open func initContentView() {
        self.backgroundColor = UIColor.clear;
        self.contentView.backgroundColor = UIColor.clear;
        
        self.titleLabel = UILabel()
        self.titleLabel.textColor = UIColor.black;
        self.titleLabel.textAlignment = .center;
        self.titleLabel.backgroundColor = UIColor.clear;
        self.contentView.addSubview(self.titleLabel);
        
        self.test_redBageValueLabelFrame.size = CGSize(width: 5, height: 5)
        self.redBageValueLabel = UILabel()
        self.redBageValueLabel.backgroundColor = UIColor.red;
        self.contentView.addSubview(self.redBageValueLabel);
    }
    
    //ZGTopScrollBarBaseItem
    override open func setObject(_ obj: ZGBaseUIItem) {
        super.setObject(obj);
        guard let item = self.item as? ZGTopScrollBarTextItem else {
            return;
        }
        if let analysisItem = item as? ZGTopScrollBarItem {
            //            self.analysis_name = analysisItem.analysis_name
            //            self.analysis_parameter = analysisItem.analysis_parameter
        }
        
        self.backgroundColor = UIColor.clear;
        if item.isLeft {
            self.titleLabel.textAlignment = .left;
        } else {
            self.titleLabel.textAlignment = .center;
        }
        self.titleLabel.font = UIFont.systemFont(ofSize: item.fontSize)
        if item.isBold {
            self.titleLabel.font = UIFont.boldSystemFont(ofSize: item.fontSize)
        }
        if item.isLight {
            self.titleLabel.font = UIFont.init(name: "PingFangSC-Light", size: item.fontSize)
        }
        if item.isSelect && item.selectIsBold {
            self.titleLabel.font = UIFont.boldSystemFont(ofSize: item.selectFontSize)
        }
        self.titleLabel.text = item.text;
        self.titleLabel.textColor = item.isSelect ? item.selectedTextColor : item.normalTextColor;
        //        self.titleLabel.font = item.isSelect ? UIFont.boldSystemFont(ofSize: 15) : UIFont.systemFont(ofSize: 15);
        guard let test_font = item.fontSize as? CGFloat else {
            return
        }
        guard let test_select_font = item.selectFontSize as? CGFloat else {
            return
        }
        let aa = Int(test_font)
        let bb = Int(test_select_font)
        let test_fontStr = String(aa)
        let test_select_fontStr = String(bb)
        let test_text = String.init(format: "<font color='%@' size='%@'>%@</font>","#7A808D",test_fontStr,item.text)
        let test_select_text = String.init(format: "<font color='%@' size='%@' bold='1'>%@</font>","#7A808D",test_select_fontStr,item.text)
        if item.isSelect {
            self.test_titleLabel = ZGUILabelStyle.attributedStringOfHtmlText(test_text)
        } else {
            self.test_titleLabel = ZGUILabelStyle.attributedStringOfHtmlText(test_select_text)
        }
        if let attributedText = self.test_titleLabel {
            self.test_titleLabelFrame.size = attributedText.textSize(constrainedToSize: CGSize.init(width: CGFloat(Int.max), height:  CGFloat(Int.max)))
        }
        self.test_titleLabelFrame.origin.x = (self.bounds.size.width - self.test_titleLabelFrame.width - 3 - self.test_redBageValueLabelFrame.width) / 2
        self.test_titleLabelFrame.origin.y = (self.bounds.size.height - self.test_titleLabelFrame.height) / 2
        if item.isSelect {
            self.test_redBageValueLabelFrame.origin.x = self.test_titleLabelFrame.maxX + 7
            self.test_redBageValueLabelFrame.origin.y = self.test_titleLabelFrame.origin.y - 2.5
        } else {
            self.test_redBageValueLabelFrame.origin.x = self.test_titleLabelFrame.maxX + 3
            self.test_redBageValueLabelFrame.origin.y = self.test_titleLabelFrame.origin.y
        }
        if item.isShowRedBadgeValue {
            self.titleLabel.frame = self.bounds;
            self.redBageValueLabel.frame = self.test_redBageValueLabelFrame
            self.redBageValueLabel.layer.cornerRadius = self.test_redBageValueLabelFrame.height / 2
            self.redBageValueLabel.layer.masksToBounds = true
        } else {
            self.redBageValueLabel.frame = .zero
            self.titleLabel.frame = self.bounds;
        }
        self.layoutSubviews()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews();
    }
}


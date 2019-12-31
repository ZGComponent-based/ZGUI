//
//  ZGTopScrollBarSectionTextView.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/3/27.
//
//

import UIKit

open class ZGTopScrollBarSectionTextView: ZGTopScrollBarSectionBaseView {

    open var titleLabel:UILabel!;
    
    override public init(frame: CGRect) {
        super.init(frame: frame);
        
        self.titleLabel = UILabel.init(frame: self.bounds);
        self.titleLabel.font = UIFont.systemFont(ofSize: 15);
        self.titleLabel.textColor = UIColor.black;
        self.titleLabel.textAlignment = .center;
        self.titleLabel.backgroundColor = UIColor.clear;
        self.contentView.addSubview(self.titleLabel);
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func setObject(_ obj: ZGBaseUIItem) {
        super.setObject(obj);
        guard let item = self.item as? ZGTopScrollBarTextItem else {
            return;
        }
        self.titleLabel.text = item.text;
        self.titleLabel.textColor = item.isSelect ? item.selectedTextColor : item.normalTextColor;
        self.titleLabel.font = item.isSelect ? UIFont.boldSystemFont(ofSize: 15) : UIFont.systemFont(ofSize: 15);
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews();
        self.titleLabel.frame = self.bounds;
    }
}

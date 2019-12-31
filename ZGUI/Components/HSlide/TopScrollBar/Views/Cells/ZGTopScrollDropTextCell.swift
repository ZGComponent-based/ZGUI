//
//  ZGTopScrollDropTextCell.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/3/31.
//
//

import UIKit

open class ZGTopScrollDropTextCell: ZGTopScrollBarTextCell {
    
    open override func initContentView() {
        super.initContentView();
        self.titleLabel.font = UIFont.systemFont(ofSize: 14);
    }
    
    override open func setObject(_ obj: ZGBaseUIItem) {
        super.setObject(obj);

        guard let item = self.item as? ZGTopScrollBarTextItem else {
            return;
        }
        self.titleLabel.font = item.isSelect ? UIFont.boldSystemFont(ofSize: 14) : UIFont.systemFont(ofSize: 14);
        
        if !item.isChangeDropColor {
            self.titleLabel.textColor = item.isSelect ? UIColor.red : UIColor.color(withHex: 0x4D5765);
        }
    }
}


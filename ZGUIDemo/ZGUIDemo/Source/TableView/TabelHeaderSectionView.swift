//
//  TabelHeaderSectionView.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2018/2/9.
//  Copyright © 2018年 zhaogang. All rights reserved.
//

import UIKit
import ZGUI

class TabelHeaderSectionView: ZGTableReusableView {

    lazy var titleLabel: UILabel = {
        return self.addNormalLabel()
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let item = self.item as? TabelHeaderSection else {
            return
        }
        self.titleLabel.frame = item.titleFrame
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.attributedText = nil
    }
    
    override func setObject(_ obj: ZGBaseUIItem) {
        super.setObject(obj)
        
        guard let item = self.item as? TabelHeaderSection else {
            return
        }
        self.titleLabel.attributedText = item.title
    }
    
}

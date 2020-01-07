//
//  TableItem.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2018/2/9.
//  Copyright © 2018年 zhaogang. All rights reserved.
//

import UIKit
import ZGUI

class TabelHeaderSection : ZGTableReusableViewItem {
    var title : NSAttributedString?
    var titleFrame:CGRect = .zero
    
    override func mapReusableViewType() -> ZGTableReusableView.Type {
        return TabelHeaderSectionView.self
    }
    
    func resetTitle(_ title:String?)  {
        guard let title = title else {
            return
        }
        self.indexCharactor = title
        let text = "<font size='15' color='#333333' bold='1' >\(title)</font>"
        if let attributedText = ZGUILabelStyle.attributedStringOfHtmlText(text) {
            self.title = attributedText
            self.titleFrame.size = attributedText.textSize(constrainedToSize: CGSize.init(width: 100, height: 50))
        }
    }
    
    func refreshLayout()  {
        self.titleFrame.origin.x = 15
        self.titleFrame.origin.y = (self.size.height - self.titleFrame.height) / 2
    }
}

class TableItem: ZGTableReusableViewItem {

    var title : NSAttributedString?
    var titleFrame:CGRect = .zero
    
    func resetTitle(_ title:String?)  {
        guard let title = title else {
            return
        }
        let text = "<font size='15' color='#333333' bold='1' >\(title)</font>"
        if let attributedText = ZGUILabelStyle.attributedStringOfHtmlText(text) {
            self.title = attributedText
            self.titleFrame.size = attributedText.textSize(constrainedToSize: CGSize.init(width: 100, height: 50))
        }
    }
    
    func refreshLayout()  {
        self.titleFrame.origin.x = 15
        self.titleFrame.origin.y = (self.size.height - self.titleFrame.height) / 2
    }
    
    override func mapTableViewType() -> ZGTableViewCell.Type {
        return TableDemoCell.self
    }
}

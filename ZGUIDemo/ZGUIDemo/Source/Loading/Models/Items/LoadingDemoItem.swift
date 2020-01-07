//
//  AlertDemoItem.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/8/28.
//

import UIKit
import ZGUI

enum LoadingStyle : Int {
    case pageLoading
    case popup
    case trasparent
}

class LoadingDemoItem: ZGBaseUIItem {
    
    var titleLabel:NSAttributedString?
    var titleLabelFrame:CGRect = .zero
 
    var style:LoadingStyle?
    var text:String?
    
    static var alertIndex:Int = 0
    

    override func mapViewType() -> ZGCollectionViewCell.Type {
        return LoadingDemoCell.self
    }
    
    func resetTile(_ title:String) {
        let text = "<font color='#6b6b6b' size='15'>\(title)</font>"
        self.titleLabel = ZGUILabelStyle.attributedStringOfHtmlText(text)
        if let attributedText = self.titleLabel {
            self.titleLabelFrame.size = attributedText.textSize(constrainedToSize: CGSize.init(width: Int.max, height: 100))
        }
        self.titleLabelFrame.origin.y = (self.size.height - self.titleLabelFrame.height) / 2
        self.titleLabelFrame.origin.x = 10
    }
    
    init(style:LoadingStyle, title:String, loadingText:String?) {
        super.init()
        self.size.width = UIScreen.main.bounds.size.width
        self.size.height = 44
        self.style = style
        self.text = loadingText
        self.resetTile(title)
    }
 
}

//
//  ZGImageUploadModel.swift
//  ZGUI
//
//  Created by zhaogang on 2017/12/15.
//

import UIKit
import ZGNetwork

class ZGImageUploadModel: NSObject {

    var title:NSAttributedString?
    var cancelTitle:NSAttributedString?
    var okTitle:NSAttributedString?
    
    var titleSize:CGSize = .zero
    var cancelTitleSize:CGSize = .zero
    var okTitleSize:CGSize = .zero
    
    var imageData:Data
    
    init(imageData:Data) {
        self.imageData = imageData
        super.init()
    }
    
    func resetTitle(_ title:String) {
        let text = "<font color='#4a4a4a' size='15' >\(title)</font>"
        self.title = ZGUILabelStyle.attributedStringOfHtmlText(text)
        if let attributedText = self.title {
            self.titleSize = attributedText.textSize(constrainedToSize: CGSize.init(width: Int.max, height: 100))
        }
    }
    
    func resetCancelTitle(_ title:String) {
        let text = "<font color='#4a4a4a' size='15' >\(title)</font>"
        self.cancelTitle = ZGUILabelStyle.attributedStringOfHtmlText(text)
    }
    
    func resetOkTitle(_ title:String) {
        let text = "<font color='#DC9F28' size='15' >\(title)</font>"
        self.okTitle = ZGUILabelStyle.attributedStringOfHtmlText(text)
    }
     
}

//
//  ZGAlbumBottomItem.swift
//  ZGUI
//
//  Created by zhaogang on 2017/11/3.
//

import UIKit
import Photos

class ZGAlbumBottomItem: NSObject, ZGImagePreviewBottomItemProtocol {
    var saveHandler: ((ZGImagePreviewItem) -> Void)?
    
    func view() -> ZGImagePreviewBottomView {
        return ZGAlbumBottomView(frame:frame)
    }
    
    var frame: CGRect 
    var total: Int = 0
    
    var leftTitle:NSAttributedString?
    var rightTitle:NSAttributedString?
    var originalTitle:NSAttributedString?
    var countTitle:NSAttributedString?
    
    var leftTitleFrame:CGRect = .zero
    var rightTitleFrame:CGRect = .zero
    var rightImageFrame:CGRect = .zero
    var originalTitleFrame:CGRect = .zero
    
    var originalImage:String?
    var rightImage:String?
    
    var hLineFrame:CGRect = .zero
    var originalImageFrame:CGRect = .zero
    var countFrame:CGRect = .zero
    
    var topLineFrame:CGRect = .zero
    
    //
    var defaultAssets:[ZGAlbumCollectionItem]?
    var selectedAssets:[ZGAlbumCollectionItem]?
    
    public init(frame:CGRect, total:Int) {
        self.frame = frame
        self.total = total
        super.init()
        
    }
    
    func resetLeftTitle(color:String = "#aeaeae") {
        let text = "<font size='15' color='\(color)'>预览</font>"
        self.leftTitle = ZGUILabelStyle.attributedStringOfHtmlText(text)
        if let attributedText = self.leftTitle {
            self.leftTitleFrame.size =  attributedText.textSize(constrainedToSize: CGSize.init(width: 200, height: 30))
            self.leftTitleFrame.size.height = self.frame.height
            self.leftTitleFrame.size.width += 10
        }
    }
    
    func resetRightTitle(color:String = "#aeaeae", count:Int) {
        var text = "<font size='15' color='\(color)'>完成</font>"
        self.rightTitle = ZGUILabelStyle.attributedStringOfHtmlText(text)
        if let attributedText = self.rightTitle {
            self.rightTitleFrame.size =  attributedText.textSize(constrainedToSize: CGSize.init(width: 200, height: 30))
            self.rightTitleFrame.size.height = self.frame.height
            self.rightTitleFrame.size.width += 10
        }
        if count < 1 {
            self.countFrame = .zero
            self.countTitle = nil
            return
        }
        text = "<font size='15' color='#ffffff'>\(count)</font>"
        self.countTitle = ZGUILabelStyle.attributedStringOfHtmlText(text)
        if let attributedText = self.countTitle {
            self.countFrame.size =  attributedText.textSize(constrainedToSize: CGSize.init(width: 30, height: 30))
            self.countFrame.size.height += 4
            self.countFrame.size.width = self.countFrame.height
        }
    }
    
    func resetOriginalTitle(color:String = "#aeaeae", image:String, totalSize:String?) {
        
        var text = "<font size='15' color='\(color)'>原图</font>"
        if let totalSize = totalSize {
            text = "<font size='15' color='\(color)'>原图(\(totalSize))</font>"
        }
        
        self.originalTitle = ZGUILabelStyle.attributedStringOfHtmlText(text)
        if let attributedText = self.originalTitle {
            self.originalTitleFrame.size =  attributedText.textSize(constrainedToSize: CGSize.init(width: 200, height: 30))
            self.originalTitleFrame.size.height = self.frame.height
            self.originalTitleFrame.size.width += 10
        }
        self.originalImage = image
        self.originalImageFrame.size = CGSize.init(width: 24, height: 24)
    }
    
    func refreshLayout() {
        let marginLeft :CGFloat = 5
        self.leftTitleFrame.origin.x = marginLeft
        self.leftTitleFrame.origin.y = (self.frame.height - self.leftTitleFrame.height) / 2
        
        self.originalImageFrame.origin.x = self.leftTitleFrame.origin.x + self.leftTitleFrame.width + 10
        self.originalImageFrame.origin.y = (self.frame.height - self.originalImageFrame.height) / 2
        
        self.originalTitleFrame.origin.x = self.originalImageFrame.origin.x + self.originalImageFrame.width + 2
        self.originalTitleFrame.origin.y = (self.frame.height - self.originalTitleFrame.height) / 2
        
        self.rightTitleFrame.origin.x = self.frame.width - self.rightTitleFrame.width - marginLeft
        self.rightTitleFrame.origin.y = (self.frame.height - self.rightTitleFrame.height) / 2
        
        self.countFrame.origin.x = self.rightTitleFrame.origin.x - self.countFrame.width - 5
        self.countFrame.origin.y = (self.frame.height - self.countFrame.height) / 2
        
        self.rightImageFrame.origin.x = self.rightTitleFrame.origin.x - self.rightImageFrame.width - marginLeft
        self.rightImageFrame.origin.y = (self.frame.height - self.rightImageFrame.height) / 2
        
        self.topLineFrame.size = CGSize.init(width: self.frame.width, height: 0.5)
        
    }
}

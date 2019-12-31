//
//  ZGPageTipItem.swift
//  Pods
//
//  Created by zhaogang on 2017/8/8.
//
//

import UIKit
import ZGNetwork

open class ZGPageTipItem: NSObject {
    open var title:NSAttributedString?
    open var titleFrame:CGRect = .zero
    
    open var detail:NSAttributedString?
    open var detailFrame:CGRect = .zero
    
    open var errorText:NSAttributedString?
    open var errorTextFrame:CGRect = .zero
    
    open var buttonTitle:NSAttributedString?
    open var buttonTitleFrame:CGRect = .zero
    
    open var centerImage:String?
    open var centerImageFrame:CGRect = .zero
    
    open var isHomeworkDetai:Bool = false
    
    open var size:CGSize
    
    func resetTitle(_ title:String?,_ font:String?,_ color:String?,_ face:String? )  {
        guard let title = title else {
            return
        }
        var titleFont = "14"
        var titleColor = "#8E9DAE"
        if let font = font {
            titleFont = font
        }
        if let color = color {
            titleColor = color
        }
        var titleFace = "PingFangSC-Light"
        if let face = face {
            titleFace = face
        }
        
        let text = String.init(format: "<font color='%@' size='%@' face='%@'>%@</font>", titleColor,titleFont,titleFace,title)
        self.title = ZGUILabelStyle.attributedStringOfHtmlText(text)
        if let attributedText = self.title {
            self.titleFrame.size = attributedText.textSize(constrainedToSize: CGSize.init(width: 280, height: 50))
        }
    }
    
    func resetDetail(_ title:String?)  {
        guard let title = title else {
            return
        }
        var titleFont = "14"
        var titleColor = "#8E9DAE"

        let text = String.init(format: "<font color='%@' size='%@' face='PingFangSC-Light'>%@</font>", titleColor,titleFont,title)
        self.detail = ZGUILabelStyle.attributedStringOfHtmlText(text)
        if let attributedText = self.detail {
            self.detailFrame.size = attributedText.textSize(constrainedToSize: CGSize.init(width: 280, height: 50))
        }
    }
    
    func resetButton(_ title:String?,_ isHomeworkDetai:Bool?)  {
        guard let title = title else {
            return
        }
        guard let isHomeworkDetai = isHomeworkDetai else {
            return
        }
        if isHomeworkDetai {
            let text = String.init(format: "<font color='%@' size='16'>%@</font>", "#FFFFFF",  title)
            self.buttonTitle = ZGUILabelStyle.attributedStringOfHtmlText(text)
            if let attributedText = self.buttonTitle {
                self.buttonTitleFrame.size = attributedText.textSize(constrainedToSize: CGSize.init(width: 280, height: 50))
                self.buttonTitleFrame.size.width += 64
                self.buttonTitleFrame.size.height = 46
            }
        } else {
            let text = String.init(format: "<font color='%@' size='15'>%@</font>", "#333333",  title)
            self.buttonTitle = ZGUILabelStyle.attributedStringOfHtmlText(text)
            if let attributedText = self.buttonTitle {
                self.buttonTitleFrame.size = attributedText.textSize(constrainedToSize: CGSize.init(width: 280, height: 50))
                self.buttonTitleFrame.size.width += 40
                self.buttonTitleFrame.size.height += 10
            }
        }
    }
    
    func resetImage(_ imageBundle:String?,_ imageSize:CGSize?) {
        guard let imageBundle = imageBundle else {
            return
        }
        var size = CGSize(width: 115, height: 115)
        if let imageSize = imageSize {
            size = imageSize
        }
        self.centerImage = imageBundle
        self.centerImageFrame.size = size
    }
    
    //图片、标题、描述、按钮垂直居中
    func refreshLayout() {
        //垂直间距
        var centerHeight:CGFloat = self.centerImageFrame.height
        let titleImageGap:CGFloat = 20 //标题和图片的间隔
        let titleDescGap:CGFloat = 20 //标题和描述的间隔
        let titleButtonGap:CGFloat = 85 //标题和按钮的间隔
        
        if title != nil {
            centerHeight += titleImageGap
            centerHeight += self.titleFrame.height
        }
        
        if detail != nil {
            centerHeight += titleDescGap
            centerHeight += self.detailFrame.height
        }
        
        if buttonTitle != nil {
            centerHeight += titleButtonGap
            centerHeight += self.buttonTitleFrame.height
        }
        
        var topY:CGFloat = (self.size.height - centerHeight) / 2
        if self.centerImage != nil {
            self.centerImageFrame.origin.y = topY
            self.centerImageFrame.origin.x = (self.size.width - self.centerImageFrame.width) / 2
            topY = self.centerImageFrame.origin.y + self.centerImageFrame.height
        }
        
        if self.title != nil {
            if topY > 0 {
                self.titleFrame.origin.y = topY + titleImageGap
            } else {
                self.titleFrame.origin.y = topY
            }
            self.titleFrame.origin.x = (self.size.width - self.titleFrame.width) / 2
            topY = self.titleFrame.origin.y
        }
        
        if self.detail != nil {
            self.detailFrame.origin.y = self.titleFrame.maxY + 10
            self.detailFrame.origin.x = (self.size.width - self.detailFrame.width) / 2
            topY = self.detailFrame.origin.y
        }
        
        if self.buttonTitle != nil {
            self.buttonTitleFrame.origin.y = topY + titleButtonGap
            self.buttonTitleFrame.origin.x = (self.size.width - self.buttonTitleFrame.width) / 2
        }
        
    }
    
    public init(title:String? = nil,
                titleFont:String? = nil,
                titleColor:String? = nil,
                face:String? = nil,
                detail:String? = nil,
                isHomeworkDetail:Bool = false,
                buttonTitle:String? = nil,
                error:ZGNetworkError? = nil,
                imageBundle:String? = nil,
                imageSize:CGSize? = nil,
                isEmpty:Bool = false,
                size:CGSize) {
        self.size = size
        super.init()
        self.resetTitle(title, titleFont, titleColor, face)
        self.isHomeworkDetai = isHomeworkDetail
        self.resetButton(buttonTitle, isHomeworkDetail)
        self.resetImage(imageBundle, imageSize)
        self.resetDetail(detail)
        self.refreshLayout()
        
    }
}

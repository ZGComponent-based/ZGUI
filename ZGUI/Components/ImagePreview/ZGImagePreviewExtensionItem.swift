//
//  ZGImagePreviewExtensionItem.swift
//  Pods
//
//  Created by zhaogang on 2017/7/13.
//
//

import UIKit

public typealias ZGImagePreviewPullingHandler = () -> Void

public class ZGImagePreviewPullingItem :NSObject {
    
    var pullingText:String
    var triggerText:String
    public var textColor:UIColor?
    public var fontSize:CGFloat = 12
    //宽*高 = 18 * 18
    var arrowImageUrl:String
    
    public var handler:ZGImagePreviewPullingHandler?
    
    public init(arrowImageUrl:String, pullingText:String, triggerText:String) {
        self.arrowImageUrl = arrowImageUrl
        self.pullingText = pullingText
        self.triggerText = triggerText
        super.init()
    }
}

public protocol ZGImagePreviewBottomItemProtocol :class {
    func view() -> ZGImagePreviewBottomView
    var saveHandler:((ZGImagePreviewItem) -> Void)? {get set}
    var frame:CGRect {get set}
    var total:Int {get set}
}

public class ZGImagePreviewPageControlItem :NSObject, ZGImagePreviewBottomItemProtocol {
    public var frame:CGRect
    public var total:Int
    public var saveHandler:((ZGImagePreviewItem) -> Void)?
    
    public var pageIndicatorTintColor:UIColor?
    public var currentPageIndicatorTintColor:UIColor?
 
    public init(frame:CGRect, total:Int) {
        self.frame = frame
        self.total = total
        super.init()
    }
    
    public func view() -> ZGImagePreviewBottomView {
        return ZGImagePreviewPageControl(frame:frame)
    }
}

public class ZGImagePreviewCountItem :NSObject, ZGImagePreviewBottomItemProtocol {
    public var frame:CGRect
    public var total:Int
    public var enableSavePhoto:Bool = false
    public var saveHandler:((ZGImagePreviewItem) -> Void)?
    
    public init(frame:CGRect, total:Int) {
        self.frame = frame
        self.total = total
        super.init()
    }
    
    public func view() -> ZGImagePreviewBottomView {
        return ZGImagePreviewCountView(frame:frame)
    }
    
}

//用于过场动画，比如商品详情点击图片进入预览模式，会有个图片缩放的动画
public class ZGImagePreviewPathItem:NSObject {
    var pathView:UIView
    var pathImage:UIImage
    var pathIndex:Int
    
    public init(pathView:UIView, pathImage:UIImage, pathIndex:Int) {
        self.pathView = pathView
        self.pathImage = pathImage
        self.pathIndex = pathIndex
        
        super.init()
    }
}

public class ZGImagePreviewExtensionItem: NSObject {
    public var pullingItem:ZGImagePreviewPullingItem?
    public var bottomItem:ZGImagePreviewBottomItemProtocol?
    public var topItem:ZGImagePreviewBottomItemProtocol?
    public var pathItem:ZGImagePreviewPathItem?
    
}

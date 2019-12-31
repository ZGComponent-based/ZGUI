//
//  ZGImagePreview.swift
//  Pods
//
//  Created by zhaogang on 2017/7/12.
//
//

import UIKit
import ZGCore
public class ZGImagePreviewBox: UIView, ZGHPaginationScrollViewDelegate, UIScrollViewDelegate  {
    public var items:[ZGImagePreviewItem]
    weak var pagingScrollView:ZGHPaginationScrollView<ZGImagePreviewItemView, ZGImagePreviewBox>!
    weak var pullView:ZGImagePreviewPull?
    weak var bottomView:ZGImagePreviewBottomView?
    weak var topView:ZGImagePreviewBottomView?
    var pathItem:ZGImagePreviewPathItem?
    weak var animationView:ZGImageView?
    var tapHandler:ZGPreviewTapHandler?
    weak var currentPageView:ZGImagePreviewItemView?
    
    public func setCurrentIndex(_ index:Int, animated:Bool = false) {
        self.pagingScrollView.selectPageView(withIndex: index, animated: animated)
    }
    
    public func selectIndex() -> Int {
        return self.pagingScrollView.selectIndex
    }
    
    func addTopView(_ item:ZGImagePreviewBottomItemProtocol) {
        if self.topView != nil {
            return
        }
        let view = item.view()
        self.addSubview(view)
        self.topView = view
        self.topView?.setItem(item)
        
        if let page = self.pagingScrollView.currentPageView() {
            if let pageItem = page.item {
                self.topView?.setCurrentIndex(page.index, item: pageItem)
            }
        }
    }
    
    func addBottomView(_ item:ZGImagePreviewBottomItemProtocol) {
        if self.bottomView != nil {
            return
        }
        let view = item.view()
        self.addSubview(view)
        self.bottomView = view
        self.bottomView?.setItem(item)
        item.saveHandler = {[weak self](item) in
            if let pageView = self?.currentPageView{
                pageView.openPhotoAlbum()
            }
        }
        
        if let page = self.pagingScrollView.currentPageView() {
            if let pageItem = page.item {
                self.bottomView?.setCurrentIndex(page.index, item: pageItem)
            }
        }
    }
    
    func addPullingViewWithItem(_ item:ZGImagePreviewPullingItem) {
        if self.pullView != nil {
            return
        }
        
        let gX:CGFloat = self.pagingScrollView.contentSize.width
        let gY:CGFloat = (self.pagingScrollView.frame.size.height-ZGImagePreviewPull.pullHeight)/2
        let rect = CGRect.init(x:gX, y:gY, width:self.pagingScrollView.frame.size.height, height:ZGImagePreviewPull.pullHeight)
        let pullingView = ZGImagePreviewPull(frame:rect)
        self.pagingScrollView.addSubview(pullingView)
        self.pullView = pullingView
        
        pullingView.setPullingItem(item)
        
        let offset:CGFloat = ZGImagePreviewPull.pullHeight/2
        
        pullingView.transform = CGAffineTransform(rotationAngle: CGFloat((90.0 * Double.pi) / 180.0))
        pullingView.statusLabel.transform = CGAffineTransform(rotationAngle: CGFloat(-(90.0 * Double.pi) / 180.0))
        
        pullingView.center = CGPoint.init(x:gX+offset, y:gY+offset)
        var rect12 = pullingView.statusLabel.frame
        rect12.origin = .zero
        pullingView.statusLabel.frame = rect12
    }
    
    public init(items:[ZGImagePreviewItem], extensionItem:ZGImagePreviewExtensionItem? = nil, frame:CGRect) {
        self.items = items
        super.init(frame:frame)
        
        let scrollView = ZGHPaginationScrollView<ZGImagePreviewItemView, ZGImagePreviewBox>(frame:self.bounds)
        self.addSubview(scrollView)
        self.pagingScrollView = scrollView
        self.pagingScrollView.slideDelegate = self
        self.pagingScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.pagingScrollView.bounces = true
        self.pagingScrollView.alwaysBounceHorizontal = true
        
        self.pagingScrollView.items = items
        
        if let pullingItem = extensionItem?.pullingItem {
            self.addPullingViewWithItem(pullingItem)
        }
        
        if let bottomItem = extensionItem?.bottomItem {
            self.addBottomView(bottomItem)
        }
        
        if let topItem = extensionItem?.topItem {
            self.addTopView(topItem)
        }
        
        self.pathItem = extensionItem?.pathItem
        //执行过场动画
        if let pathItem = self.pathItem {
            self.animationForPathItem(pathItem)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clickCallBack(itemView:ZGImagePreviewItemView) {
        if let clickHandler = self.tapHandler {
            clickHandler(itemView)
        }
    }
    
    public func getPageView(atIndex index:Int) -> ZGImagePreviewItemView? {
        let count  = self.items.count
        if count < 1 {
            return nil
        }
        if index > count-1 {
            return nil
        }
        let item = self.items[index]
        var pageView = self.pagingScrollView.dequeueReusablePageView(withIdentifier: item.identifier)
        if pageView == nil {
            pageView = ZGImagePreviewItemView()
            pageView?.tapHandler = { [weak self](itemView) in
                if self?.animationView != nil {
                    self?.removeAnimationView(completion: {(finished) in
                        self?.clickCallBack(itemView: itemView)
                    })
                } else {
                    self?.clickCallBack(itemView: itemView)
                }
                
            }
        }
        return pageView
    }
    
    public func willShow(pageView: ZGImagePreviewItemView) {
        self.currentPageView = pageView
    }
    
    public func didShow(pageView: ZGImagePreviewItemView) {
        guard let item = pageView.item else {
            return
        }
        self.currentPageView = pageView
        if let topView = self.topView {
            topView.setCurrentIndex(pageView.index, item: item)
        }
        if let bottomView = self.bottomView {
            bottomView.setCurrentIndex(pageView.index, item: item)
        }
    }
    
    public func didHide(pageView: ZGImagePreviewItemView) {
        
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let pullingView = self.pullView else {
            return
        }
        
        let boxWidth:CGFloat = scrollView.frame.size.width
        let sWidth:CGFloat = boxWidth + scrollView.contentOffset.x
        var readyShowPullingHeight:CGFloat = scrollView.contentSize.height
        if readyShowPullingHeight < boxWidth {
            readyShowPullingHeight = boxWidth
        }
        
        if sWidth > readyShowPullingHeight {
            var ht:CGFloat = scrollView.contentSize.width
            if (ht < scrollView.frame.size.width) {
                ht = scrollView.frame.size.width
            }
            pullingView.containerDidScroll(scrollView)
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let pullingView = self.pullView else {
            return
        }
        let boxWidth:CGFloat = scrollView.frame.size.width
        let ht:CGFloat = boxWidth + scrollView.contentOffset.x
        let readyShowPullingHeight = scrollView.contentSize.width
        if ht > readyShowPullingHeight {
            pullingView.containerDidEndDragging(scrollView)
        }
    }
    
    //MARK: - 过场动画
    func animationForPathItem(_ item:ZGImagePreviewPathItem) {
        if self.animationView == nil {
            let imageView = ZGImageView()
            self.addSubview(imageView)
            self.animationView = imageView
        }
        
        guard let sView = item.pathView.superview, let animationView = self.animationView else {
            return
        }
        
        self.pagingScrollView.selectPageView(withIndex: item.pathIndex, animated: false)
        
        self.pagingScrollView.isHidden = true
        
        let pt:CGPoint = sView.convert(item.pathView.frame.origin, to: self)
        var r2 = item.pathView.frame
        r2.origin = pt
        
        animationView.frame = r2
        animationView.setImage(item.pathImage, enableAnimation: false)
        
        let targetFrame = self.getAnimationViewFrameForImage(imageSize: item.pathImage.size)
        
        let scaleX = targetFrame.width / animationView.width
        let scaleY = targetFrame.height / animationView.height
        
        let translatedX:CGFloat = 0 -  animationView.frame.origin.x + ((scaleX-1)/2)*animationView.width
        
        // 不做缩放时需要移动的距离加上超出比例的距离/2, 垂直居中
        let translatedY = targetFrame.origin.y - animationView.frame.origin.y + ((scaleY-1)/2)*animationView.height
        UIView.animate(withDuration: 0.3, animations: {
            
            animationView.transform = CGAffineTransform.identity
                .translatedBy(x: translatedX, y: translatedY)
                .scaledBy(x: scaleX, y: scaleY)
            
        }) { (finish) in
            let pageView = self.pagingScrollView.currentPageView()
            pageView?.contentImgView.defaultImage = item.pathImage
            self.pagingScrollView.isHidden = false
            animationView.isHidden = true
        }
    }
    
    func removeAnimationView(completion: ((Bool) -> Void)? = nil) {
        guard let item = self.pathItem else {
            if let completion = completion {
                completion(true)
            }
            return
        }
        guard let _ = item.pathView.superview, let animationView = self.animationView else {
            if let completion = completion {
                completion(true)
            }
            return
        }
        
        let pageView = self.pagingScrollView.currentPageView()
        _ = pageView?.contentImgView.image
        if let pView = pageView {
            var image:UIImage? = pView.contentImgView.image
            if image == nil {
                image = pView.contentImgView.gifImage()
            }
            animationView.transform = .identity
            animationView.setImage(image, enableAnimation: false)
            animationView.frame = pView.contentImgView.frame
            animationView.isHidden = false
        }
        self.pagingScrollView.isHidden = true
        
        var pt :CGPoint = .zero
        if let sView = item.pathView.superview {
            pt = sView.convert(item.pathView.frame.origin, to: self)
        }
        var pRect = item.pathView.frame
        pRect.origin = pt
        
        let scaleX = pRect.width / animationView.width
        let scaleY = pRect.height / animationView.height
        
        let translatedX:CGFloat = pRect.origin.x - ((1-scaleX)/2)*animationView.width
        let translatedY = pRect.origin.y - animationView.frame.origin.y + ((scaleY-1)/2)*animationView.height
        UIView.animate(withDuration: 0.3, animations: {
            animationView.transform = CGAffineTransform.identity
                .translatedBy(x: translatedX, y: translatedY)
                .scaledBy(x: scaleX, y: scaleY)
        }) { (finish) in
            animationView.removeFromSuperview()
            self.removeFromSuperview()
            if let completion = completion {
                completion(finish)
            }
        }
    }
    
    func getAnimationViewFrameForImage(imageSize:CGSize) -> CGRect {
        var imageFrame:CGRect = .zero
        let size:CGSize = ZGUIImageUtil.scaleSizeOfImageSize(imageSize, bounds: self.bounds)
        imageFrame.size = size
        let deta:CGFloat = 2
        
        if  size.width < self.bounds.size.width {
            imageFrame.origin.x = floor((self.bounds.size.width - size.width) / deta)
        } else {
            imageFrame.origin.x = 0
        }
        
        if imageFrame.size.height < self.bounds.size.height {
            imageFrame.origin.y = floor((self.bounds.size.height - size.height) / deta)
        } else {
            imageFrame.origin.y = 0
        }
        
        //        self.animationView?.frame = imageFrame
        return imageFrame
    }
    
}

public class ZGImagePreviewManager {
    
    public class func showPreview(itemView:ZGImageView?, pItems:[ZGImagePreviewItem], imageIndex:Int, inView:UIView? = nil) {
        
        var mainWindow1:UIView? = ZGUIUtil.getMainWindow()
        if let view1 = inView {
            mainWindow1 = view1
        }
        guard let mainWindow = mainWindow1 else {
            return
        }
        
        var items = [ZGImagePreviewItem]()
        
        for item1 in pItems {
            let item = ZGImagePreviewItem(imageUrl: item1.bigImageUrl,
                                          defaultImageUrl: item1.defaultImageUrl,
                                          failedImageUrl: item1.failedImageUrl)
            item.enableSavePhoto = true
            item.enableScale = true
            item.isFlatPattern = false
            item.asset = item1.asset
            items.append(item)
        }
        let screenBounds = UIScreen.main.bounds
        
        let height:CGFloat = screenBounds.size.height
        let width:CGFloat = screenBounds.size.width
        
        let total = items.count
        let extItem = ZGImagePreviewExtensionItem()
        
        let bHeight:CGFloat = 40
        let bItem = ZGImagePreviewCountItem(frame:CGRect.init(x: 0, y: height-bHeight, width:width, height: bHeight), total: total)
        bItem.enableSavePhoto = true
        extItem.bottomItem = bItem
        
        if let itemView = itemView {
            
            var image = itemView.defaultImage
            if let image1 = itemView.image {
                image = image1
            }
            if image == nil {
                if let gifImage = itemView.gifImage() {
                    image = gifImage
                }
            }
            if let pathImage = image {
                extItem.pathItem = ZGImagePreviewPathItem(pathView: itemView, pathImage: pathImage, pathIndex: imageIndex)
            }
            
        }
        
        let pFrame = CGRect.init(x: 0, y: 0, width: width, height: height)
        ZGImagePreviewManager.show(inView: mainWindow,
                                   items:items,
                                   extensionItem: extItem,
                                   frame:pFrame,
                                   blur:true,
                                   tapHandler: {(itemView) in
                                    for(index,value) in mainWindow.subviews.enumerated() {
                                        if value is ZGImagePreviewBox {
                                            value.removeFromSuperview()
                                        }
                                    }
        })
    }
    //根据数组角标展示图片（目前和h5交互用到）
    public class func showWebPreview(itemView:ZGImageView?, pItems:[ZGImagePreviewItem], imageIndex:Int, inView:UIView? = nil) {
        
        var mainWindow1:UIView? = ZGUIUtil.getMainWindow()
        if let view1 = inView {
            mainWindow1 = view1
        }
        guard let mainWindow = mainWindow1 else {
            return
        }
        
        var items = [ZGImagePreviewItem]()
        
        for item1 in pItems {
            let item = ZGImagePreviewItem(imageUrl: item1.bigImageUrl,
                                          defaultImageUrl: item1.defaultImageUrl,
                                          failedImageUrl: item1.failedImageUrl)
            item.enableSavePhoto = true
            item.enableScale = true
            item.isFlatPattern = false
            item.asset = item1.asset
            items.append(item)
        }
        let screenBounds = UIScreen.main.bounds
        
        let height:CGFloat = screenBounds.size.height
        let width:CGFloat = screenBounds.size.width
        
        let total = items.count
        let extItem = ZGImagePreviewExtensionItem()
        
        let bHeight:CGFloat = 40
        let bItem = ZGImagePreviewCountItem(frame:CGRect.init(x: 0, y: height-bHeight, width:width, height: bHeight), total: total)
        bItem.enableSavePhoto = true
        extItem.bottomItem = bItem
        itemView?.urlPath = pItems[imageIndex].bigImageUrl
        if let itemView = itemView {
            var image = ZGImage(pItems[imageIndex].bigImageUrl)
            if let image1 = itemView.image {
                image = image1
            }
            if image == nil {
                if let gifImage = itemView.gifImage() {
                    image = gifImage
                }
            }
            if let pathImage = image {
                extItem.pathItem = ZGImagePreviewPathItem(pathView: itemView, pathImage: pathImage, pathIndex: imageIndex)
            }
        }
        let pFrame = CGRect.init(x: 0, y: 0, width: width, height: height)
        ZGImagePreviewManager.show(inView: mainWindow,
                                   items:items,
                                   extensionItem: extItem,
                                   frame:pFrame,
                                   blur:true,
                                   tapHandler: {(itemView) in
                                    
                                    for(index,value) in mainWindow.subviews.enumerated() {
                                        if value is ZGImagePreviewBox {
                                            value.removeFromSuperview()
                                        }
                                    }
        })
    }
    
    /// 全屏显示图片预览, 当点击某个图片时弹出该预览窗口
    ///
    /// - parameter itemView:  原
    /// - parameter previewBox:
    /// - parameter blur: 是否采用毛玻璃效果
    ///
    public class func showPreview(itemView:ZGImagePreviewItemView, previewBox:ZGImagePreviewBox, blur:Bool = false) {
        
        guard let mainWindow = ZGUIUtil.getMainWindow() else {
            return
        }
        
        var items = [ZGImagePreviewItem]()
        
        for item1 in previewBox.items {
            let item = ZGImagePreviewItem(imageUrl: item1.bigImageUrl, defaultImageUrl: item1.defaultImageUrl, failedImageUrl: item1.failedImageUrl)
            item.enableSavePhoto = true
            item.enableScale = true
            item.isFlatPattern = false
            items.append(item)
        }
        let screenBounds = UIScreen.main.bounds
        
        let height:CGFloat = screenBounds.size.height
        let width:CGFloat = screenBounds.size.width
        
        let total = items.count
        let extItem = ZGImagePreviewExtensionItem()
        
        let pathIndex = itemView.index
        
        var image = itemView.contentImgView.defaultImage
        if let image1 = itemView.contentImgView.image {
            image = image1
        }
        
        guard let pathImage = image else {
            return
        }
        let bHeight:CGFloat = 40
        let bItem = ZGImagePreviewCountItem(frame:CGRect.init(x: 0, y: height-bHeight, width:width, height: bHeight), total: total)
        bItem.enableSavePhoto = true
        extItem.bottomItem = bItem
        extItem.pathItem = ZGImagePreviewPathItem(pathView: itemView, pathImage: pathImage, pathIndex: pathIndex)
        
        let pFrame = CGRect.init(x: 0, y: 0, width: width, height: height)
        ZGImagePreviewManager.show(inView: mainWindow,
                                   items:items,
                                   extensionItem: extItem,
                                   frame:pFrame,
                                   backgroundColor:UIColor.color(withHex: 0x000000, alpha: 0.8),
                                   blur:blur,
                                   tapHandler: {(itemView) in
                                    if itemView.index == previewBox.selectIndex() {
                                        return
                                    }
                                    //同步位置
                                    previewBox.setCurrentIndex(itemView.index)
        })
    }
    
    /// 显示图片预览
    ///
    /// - parameter inView:    在inView视图上显示
    /// - parameter frame:     显示的区域，默认为空，代表显示在整个视图上
    /// - parameter blur: 是否采用毛玻璃效果
    ///
    @discardableResult
    public class func show(inView:UIView,
                           items:[ZGImagePreviewItem],
                           extensionItem:ZGImagePreviewExtensionItem? = nil,
                           frame:CGRect? = nil,
                           backgroundColor:UIColor? = nil,
                           blur:Bool = false,
                           tapHandler:ZGPreviewTapHandler? = nil) -> ZGImagePreviewBox {
        var pRect:CGRect = inView.bounds
        if let rect = frame {
            pRect = rect
        }
        let preview = ZGImagePreviewBox(items:items, extensionItem:extensionItem, frame:pRect)
        inView.addSubview(preview)
        preview.tapHandler = tapHandler
        if let  color = backgroundColor {
            preview.backgroundColor = color
        }
        
        if blur {
            let effect = UIBlurEffect(style: .dark)
            
            let effectVeiw = UIVisualEffectView(effect: effect)
            preview.backgroundColor = UIColor.clear
            effectVeiw.frame = preview.bounds
            preview.addSubview(effectVeiw)
            preview.sendSubviewToBack(effectVeiw)
        }
        return preview
    }
}

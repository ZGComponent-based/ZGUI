//
//  ZGImagePreviewItemView.swift
//  Pods
//
//  Created by zhaogang on 2017/7/12.
//
//

import UIKit
import ZGNetwork
import AssetsLibrary
import Photos
import ZGCore

public typealias ZGPreviewTapHandler = (ZGImagePreviewItemView) -> Void

public class ZGImagePreviewItemView: UIView, UIScrollViewDelegate, ZGImageViewDelegate, UIActionSheetDelegate, ZGHPaginationSubViewDelegate {
    
    static let imageMaxScale:CGFloat = 2
    static let imageMinScale:CGFloat = 1
    
    var item:ZGImagePreviewItem?
    public var tapHandler:ZGPreviewTapHandler?
    
    public weak var contentImgView:ZGImageView!
    weak var indicatorView:UIActivityIndicatorView!
    weak var scaleScrollView:UIScrollView!
    
    var originImageViewSize:CGSize = .zero
    var zoomScale:CGFloat = ZGImagePreviewItemView.imageMinScale
    var dontNeedZoomToRect:Bool = true
    
    func addScaleView() {
        let scrollView = UIScrollView(frame:self.bounds)
        self.addSubview(scrollView)
        self.scaleScrollView = scrollView
        
        self.scaleScrollView.backgroundColor = UIColor.clear
        self.scaleScrollView.minimumZoomScale = ZGImagePreviewItemView.imageMinScale
        self.scaleScrollView.maximumZoomScale = ZGImagePreviewItemView.imageMaxScale
        self.scaleScrollView.delegate = self
        self.scaleScrollView.contentSize = .zero
        self.scaleScrollView.layer.anchorPoint = CGPoint.init(x:0.5, y:0.5)
        self.scaleScrollView.showsHorizontalScrollIndicator = false
        self.scaleScrollView.showsVerticalScrollIndicator = false
        self.scaleScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addContentImgView()
    }
    
    func addContentImgView() {
        let imageView = ZGImageView(frame:self.bounds)
        self.scaleScrollView.addSubview(imageView)
        self.contentImgView = imageView
        imageView.backgroundColor = UIColor.color(withHex: 0xEEEEE0)
        
        self.contentImgView.backgroundColor = UIColor.clear
        self.contentImgView.isUserInteractionEnabled = false
        self.contentImgView.delegate = self
    }
    
    func addIndicatorView() {
        let view = UIActivityIndicatorView(style: .white)
        self.addSubview(view)
        self.indicatorView = view
        self.indicatorView.center = CGPoint.init(x:-self.frame.size.width/2.0-200, y:self.frame.size.height/2.0)
        
        self.indicatorView.hidesWhenStopped = true
    }
    
    func addGesture() {
        // 单击手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(singleTapHandler(sender:)))
        tap.numberOfTapsRequired = 1
        self.scaleScrollView.addGestureRecognizer(tap)
        
        //双击手势
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler(sender:)))
        doubleTap.numberOfTapsRequired = 2
        self.scaleScrollView.addGestureRecognizer(doubleTap)
        
        tap.require(toFail: doubleTap)
        
        //长按手势
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler(sender:)))
        self.scaleScrollView.addGestureRecognizer(longPress)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addScaleView()
        self.addIndicatorView()
        self.addGesture()
        self.clipsToBounds = true
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard self.item != nil else {
            return
        }
        
        if self.scaleScrollView.frame.size.width < 1 {
            var rect = self.scaleScrollView.frame
            rect.size = self.bounds.size
            self.scaleScrollView.frame = rect
        }

        if self.indicatorView.isAnimating {
            self.indicatorView.center = CGPoint.init(x:self.frame.size.width/2.0, y:self.frame.size.height/2.0)
        }
        self.layoutImage()
    }
    
    func scaleSizeOfImage(_ image:UIImage) -> CGSize {
        let size:CGSize = ZGUIImageUtil.scaleSizeOfImage(image, bounds: self.bounds)
        self.scaleScrollView.maximumZoomScale = ZGImagePreviewItemView.imageMaxScale
        self.originImageViewSize = size
        
        return size
    }
    
    // MARK: - UIScrollViewDelegate Methods
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.contentImgView
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.dontNeedZoomToRect = false
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.isScrollEnabled = true
        guard let pinchGestureRecognizer = scrollView.pinchGestureRecognizer else {
            return
        }
        if self.dontNeedZoomToRect || scrollView.isZooming {
            return
        }
        let curP:CGPoint = pinchGestureRecognizer.location(in: scrollView)
        let gX:CGFloat = curP.x - self.frame.size.width/2.0
        let gY:CGFloat = curP.y - self.frame.size.height/2.0
        var zoomRect = CGRect.init(x:gX, y:gY, width:self.frame.size.width, height:self.frame.size.height)
        
        if zoomRect.minX < 0 {
            zoomRect.origin.x = 0
        }
        if zoomRect.minY < 0 {
            zoomRect.origin.y = 0
        }
        if zoomRect.maxX > scrollView.contentSize.width {
            zoomRect.origin.x-=(fabs(scrollView.contentSize.width-zoomRect.maxX))
        }
        if zoomRect.maxY > scrollView.contentSize.height {
            zoomRect.origin.y -= (fabs(scrollView.contentSize.height-zoomRect.maxY))
        }
        scrollView.zoom(to: zoomRect, animated: true)
        self.refreshContentOfScrollView(scrollView)
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.dontNeedZoomToRect = false
        self.zoomScale = scrollView.zoomScale
        scrollView.frame = CGRect.init(x:0, y:0, width:self.frame.size.width, height:self.frame.size.height)
        self.refreshContentOfScrollView(scrollView)
    }
    
    func refreshContentOfScrollView(_ scrollView:UIScrollView) {
        if self.originImageViewSize == .zero {
            let gWidth:CGFloat = self.zoomScale*scrollView.frame.size.width
            let gHeight:CGFloat = self.zoomScale*scrollView.frame.size.height
            scrollView.contentSize = CGSize.init(width:gWidth, height:gHeight)
        }else{
            var gWidth:CGFloat = self.zoomScale*originImageViewSize.width
            gWidth = (gWidth<self.frame.size.width) ? self.frame.size.width : gWidth
            var gHeight:CGFloat = zoomScale*originImageViewSize.height+100;
            gHeight = (gHeight<self.frame.size.height) ? self.frame.size.height : gHeight
            scrollView.contentSize = CGSize.init(width:gWidth, height:gHeight)
        }
        let gX:CGFloat = scrollView.contentSize.width/2.0
        let gY:CGFloat = scrollView.contentSize.height/2.0
        self.contentImgView.center = CGPoint.init(x:gX, y:gY)
        
        let offsetX:CGFloat = (scrollView.contentSize.width-scrollView.bounds.size.width)/2.0
        let offsetY:CGFloat = (scrollView.contentSize.height-scrollView.bounds.size.height)/2.0
        scrollView.contentOffset = CGPoint.init(x:offsetX, y:offsetY)
    }
    
    // MARK: - 刷新图片布局
    func layoutImage() {
        guard let item = self.item else {
            return
        }
        if item.isFlatPattern {
            self.contentImgView.frame = self.scaleScrollView.bounds
            return
        }
        
        var image1:UIImage? = nil
        if let image = self.contentImgView.image {
            image1 = image
        } else if let image = self.contentImgView.gifImage() {
            image1 = image
        }  else if let defaultImage = self.contentImgView.defaultImage {
            image1 = defaultImage
        }
        
        if let image = image1 {
            let size = self.scaleSizeOfImage(image)
            self.contentImgView.frame = CGRect.init(x:0, y:0, width:size.width, height:size.height)
        } else {
            self.contentImgView.frame = .zero
        }
        
        let boundsSize = self.bounds.size
        var frameToCenter = self.contentImgView.frame
        let deta:CGFloat = 2
        // Horizontally
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = floor((boundsSize.width - frameToCenter.size.width) / deta)
        } else {
            frameToCenter.origin.x = 0
        }
        
        // Vertically
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = floor((boundsSize.height - frameToCenter.size.height) / deta)
        } else {
            frameToCenter.origin.y = 0
        }
        
        // Center
        if self.contentImgView.frame != frameToCenter {
            self.contentImgView.frame = frameToCenter
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate Methods
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_: UIGestureRecognizer, shouldReceive: UITouch) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - ZGImageViewDelegate Methods
    public func didLoadImage(_ imageView: ZGImageView, imageUrl: String) {
        if imageView.urlPath == nil {
            return
        }
        if imageView.image != nil {
            self.zoomScale = 1.0
            self.layoutImage()
        }
        self.indicatorView.stopAnimating()
    }
    
    public func didFailLoad(_ imageView: ZGImageView, imageUrl: String, error: ZGNetworkError) {
        self.indicatorView.stopAnimating()
        self.contentImgView.urlPath = self.item?.failedImageUrl
    }
    
    public func willLoadImage(_ imageView: ZGImageView, imageUrl: String) {
        if self.indicatorView.isAnimating {
            return
        }
        self.indicatorView.startAnimating()
        self.indicatorView.center = CGPoint.init(x:self.frame.size.width/2.0, y:self.frame.size.height/2.0)
    }
    
    // MARK: - Geture Methods
    
    @objc func singleTapHandler(sender:UITapGestureRecognizer) {
        guard self.item != nil else {
            return
        }
        if self.scaleScrollView.zoomScale > ZGImagePreviewItemView.imageMinScale {
            self.dontNeedZoomToRect = true
            self.scaleScrollView.setZoomScale(ZGImagePreviewItemView.imageMinScale, animated: true)
        } else {
            if let tapHandler = self.tapHandler, let _  = self.item {
                tapHandler(self)
            }
        }
    }
    
    @objc func doubleTapHandler(sender:UITapGestureRecognizer?) {
        guard let item = self.item else {
            return
        }
        if !item.enableScale {
            return
        }
        self.dontNeedZoomToRect = true
        if self.zoomScale == ZGImagePreviewItemView.imageMinScale {
            self.scaleScrollView.setZoomScale(ZGImagePreviewItemView.imageMaxScale, animated: true)
        } else {
            self.scaleScrollView.setZoomScale(ZGImagePreviewItemView.imageMinScale, animated: true)
        }
    }
    
    func showActionSheet() {
        guard let window = UIApplication.shared.delegate?.window else {
            return
        }
        guard let mainWindow = window else {
            return
        }
        let sheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "保存图片到相册", "查看原图")
        sheet.show(in: mainWindow)
    }
    
    @objc func longPressHandler(sender:UILongPressGestureRecognizer) {
        guard let item = self.item else {
            return
        }
        if !item.enableSavePhoto {
            return
        }
        if sender.state == .began {
            if self.indicatorView.isAnimating {
                return
            } else {
                self.showActionSheet()
            }
        }
    }
    
    // MARK: - UIActionSheetDelegate Methods
    public func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            self.openPhotoAlbum()
        } else if buttonIndex == 2 {
            //查看原图
            self.doubleTapHandler(sender: nil)
        }
    }
    
    func savePhoto() {
        guard let image = self.contentImgView.image else {
            return
        }
        let contentImageView = self.contentImgView 
        PHPhotoLibrary.shared().performChanges({ 
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { (success, err) in
            if err != nil {
                //添加失败
                DispatchQueue.main.async {
                    contentImageView?.showTextTip("保存失败")
                }
            }
            
            //成功添加图片到相册中
            if success {
                DispatchQueue.main.async {
                    contentImageView?.showTextTip("保存成功")
                }
            }
        }
    }
    
    func requestPhotoLibrary() {
        PHPhotoLibrary.requestAuthorization({ (status) in
            if status == .authorized {
                self.savePhoto()
            }
        })
    }
    
    func openPhotoAlbum() {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        switch authStatus {
        case .authorized:
            self.savePhoto()
            break
        case .denied:
            //用户拒绝当前应用访问相册,我们需要提醒用户打开访问开关
            
            break
        case .restricted:
            //家长控制,不允许访问
            break
        case .notDetermined:
            self.requestPhotoLibrary()
            break
 
        }
    }
    
    //MARK: - ZGHPaginationSubViewDelegate Methods
    public var index:Int = 0
    
    public func getView() -> UIView {
        return self
    }
    
    public func setObject(_ object: Any) {
        self.item = object as? ZGImagePreviewItem
        guard let item = self.item else {
            return
        }
        if let asset = self.item?.asset {
            item.loadImage(completion: {[weak self] (image, pAsset) in
                if asset === pAsset {
                    self?.contentImgView.setImage(image)
                    self?.layoutImage()
                }
            })
        } else {
            self.contentImgView.urlPath = self.item?.imageUrl
        }
        self.layoutSubviews()
    }
    
    public func reuseIdentifier() -> String {
        if let item = self.item {
            return item.identifier
        }
        return "ZGImagePreviewItemView"
    }
    
    public func prepareForReuse() {
        if self.indicatorView.isAnimating {
            self.indicatorView.stopAnimating()
        }
        self.contentImgView.unsetImage()
        if let defaultImgUrl = self.item?.defaultImageUrl {
            self.contentImgView.defaultImage = ZGImage(defaultImgUrl)
        } else {
            self.contentImgView.defaultImage = nil
        }
        self.scaleScrollView.setZoomScale(ZGImagePreviewItemView.imageMinScale, animated: false)
        self.scaleScrollView.contentSize = .zero
    }
}

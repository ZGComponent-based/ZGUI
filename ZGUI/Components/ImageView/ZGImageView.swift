//
//  ZGImageView.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/3/16.
//
//

import UIKit
import ZGNetwork
import ZGCore
import FLAnimatedImage

public protocol ZGImageViewDelegate {
    func didLoadImage(_ imageView:ZGImageView, imageUrl : String)
    func didFailLoad(_ imageView:ZGImageView, imageUrl : String, error:ZGNetworkError)
    func willLoadImage(_ imageView:ZGImageView, imageUrl : String)
}

extension ZGImageView: ZGImageViewDelegate {
    public func didLoadImage(_ imageView:ZGImageView, imageUrl : String) {}
    public func didFailLoad(_ imageView:ZGImageView, imageUrl : String, error:ZGNetworkError){}
    public func willLoadImage(_ imageView:ZGImageView, imageUrl : String) {}
}

open class ZGImageView: UIView {
    fileprivate var imagePath:String?
    fileprivate var layer2:CALayer
    fileprivate var image1:UIImage?
    fileprivate var netRequest:ZGNetworkRequest?
    fileprivate var gifView:FLAnimatedImageView?
    open var userData:Any?
    public var autoresizesImage: Bool = true
    
    open var image:UIImage?
    open var delegate:ZGImageViewDelegate?
    
    public func imageLayer() -> CALayer {
        return self.layer2
    }
    
    func initContent()  {
        self.layer.addSublayer(self.layer2)
    }
    
    public func gifImage() -> UIImage? {
        return self.gifView?.image
    }
    
    open func unsetImage() {
        self.stopLoading()
        self.setImage(nil, enableAnimation: false)
        self.urlPath = nil
    }
    
    open var defaultImage:UIImage? {
        get {
            return image1
        }
        set(newImage) {
            self.image1 = newImage
            self.reDrawDefaultImage()
        }
    }
    
    func showGif(_ gifData:Data, url:String) -> Void {
        
        DispatchQueue.main.async {
            if self.gifView == nil {
                let fView = FLAnimatedImageView()
                self.addSubview(fView)
                fView.frame = self.bounds
                self.gifView = fView
            }
            let image = FLAnimatedImage(animatedGIFData: gifData)
            self.gifView?.animatedImage = image
        }
    }
    
    func reDrawDefaultImage() -> Void {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        self.layer.contents = self.defaultImage?.cgImage
        CATransaction.commit()
    }
    
    override public init(frame: CGRect) {
        self.layer2 = CALayer()
        super.init(frame: frame)
        self.initContent()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.layer2 = CALayer()
        super.init(coder: aDecoder)
        self.initContent()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.insertSublayer(self.layer2, at: 0)
    } 
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.reDrawDefaultImage()
        if let gifView = self.gifView {
            gifView.frame = self.bounds
            gifView.isHidden = self.image != nil
        }
        self.resetImageFrame()
    }
    
    func stopLoading() -> Void {
        if let pRequest = netRequest {
            pRequest.cancel()
        }
    }
    
    // 以高度为基准，水平居中
    func layer2RectWith(targetHeight:CGFloat, imageRatio:CGFloat) -> CGRect {
        var layerRect = self.layer2.frame
        let targetWidth:CGFloat = targetHeight * imageRatio
        layerRect.size = CGSize(width: targetWidth, height: targetHeight)
        layerRect.origin.x = (self.width - targetWidth)/2
        return layerRect
    }
    
    // 按宽度为基准, 上下居中
    func layer2RectWith(targetWidth:CGFloat, imageRatio:CGFloat) -> CGRect {
        var layerRect = self.layer2.frame
        let targetHeight:CGFloat = targetWidth / imageRatio
        
        layerRect.size = CGSize(width: targetWidth, height: targetHeight)
        layerRect.origin.y = (self.height - targetHeight)/2
        return layerRect
    }
    
    // autoresizesImage = false 时， 将图片视图设置为原有位置内等比缩放
    func resetImageFrame(enableAnimation:Bool=false) {
        guard let image = self.image else {
            return
        }
        
        let size1 = self.frame.size
        let imageViewRatio = size1.width / size1.height
        let ratio2 = image.size.width / image.size.height
        
        if autoresizesImage || imageViewRatio == ratio2 {
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            self.layer2.frame = self.bounds
            self.layer2.contents = self.image?.cgImage
            self.layer2.removeAllAnimations()
            
            CATransaction.commit()
            return
        }
        
        var layerRect = self.layer2.frame
        if imageViewRatio > ratio2 {
            layerRect = self.layer2RectWith(targetHeight: self.height, imageRatio: ratio2)
        } else {
            layerRect = self.layer2RectWith(targetWidth: self.width, imageRatio: ratio2)
        }
        
        self.layer2.backgroundColor = UIColor.orange.cgColor
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        self.layer2.frame = layerRect
        self.layer2.contents = self.image?.cgImage
        self.layer2.removeAllAnimations()
        if enableAnimation {
            self.animatingImage()
        }
        CATransaction.commit()
    }
 
    open func setImage(_ image:UIImage?, enableAnimation:Bool=true) -> Void {
        if image != nil && self.layer2.contents != nil {
            return
        }
        if image != self.image {
            self.image = image

            if !self.autoresizesImage {
                self.resetImageFrame(enableAnimation: enableAnimation)
            } else {
                CATransaction.begin()
                CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                self.layer2.frame = self.bounds
                self.layer2.contents = self.image?.cgImage
                self.layer2.removeAllAnimations()
                if enableAnimation {
                    self.animatingImage()
                }
                
                CATransaction.commit()
            }
 
        }
    }
    
    func animatingImage() {
        let animation:CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        animation.duration = 0.3
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        self.layer2.add(animation, forKey: "opacity_chanage")
    }
    
    open var urlPath:String? {
        get {
            return self.imagePath
        }
        set (newUrlPath) {
            if self.imagePath != nil && self.imagePath == newUrlPath  {
                return
            } else {
                //todo
                self.stopLoading()
                self.setImage(nil, enableAnimation: false)
            }
            
            self.stopLoading()
            self.imagePath = newUrlPath
            
            if let lPath = self.imagePath  {
                self.reload(lPath)
            }
        }
    }
    
    func requestSuccess(_ pImage:UIImage?, pUrlPath:String) -> Void {
        DispatchQueue.main.async {
            if let image = pImage {
                ZGURLCache.sharedInstance.storeImage(image: image, forUrl: pUrlPath)
                if pUrlPath == self.imagePath {
                    self.setImage(pImage)
                }
            }
            self.delegate?.didLoadImage(self, imageUrl: pUrlPath)
        }
    }
    
    func requestFailure(_ pUrlPath:String, error:ZGNetworkError) -> Void {
        DispatchQueue.main.async {
            self.delegate?.didFailLoad(self, imageUrl: pUrlPath, error: error)
        }
    }
    
    func reload(_ pUrlPath:String) {
        if pUrlPath.length() < 1 {
            return
        }
        let img:UIImage? = ZGURLCache.sharedInstance.imageForUrl(pUrlPath, fromDisk: false)
        if img != nil { 
            self.setImage(img, enableAnimation: false)
            self.delegate?.didLoadImage(self, imageUrl: pUrlPath)
            return
        }
        let aSUrl = pUrlPath
        DispatchQueue.global(qos:.userInitiated).async {
            var img:UIImage? = nil
            if ZGFileUtil.isBundleURL(aSUrl) && !aSUrl.lowercased().hasSuffix(".gif") {
                img = ZGURLCache.sharedInstance.imageForUrl(pUrlPath, fromDisk: true)
            } else {
                let data1 = ZGURLCache.sharedInstance.dataForURL(forUrl: aSUrl)
                if let data = data1 {
                    if ZGFileUtil.isGif(data) {
                        self.showGif(data, url: aSUrl)
                        DispatchQueue.main.async {
                            self.delegate?.didLoadImage(self, imageUrl: pUrlPath)
                        }
                        return
                    } else {
                        img = ZGImageForData(data)
                    }
                }
            }
            
            DispatchQueue.main.async {
                if img != nil {
                    if aSUrl == self.urlPath {
                        //图片缓存，放在主线程中执行
                        ZGURLCache.sharedInstance.storeImage(image: img, forUrl: aSUrl)
                        self.setImage(img, enableAnimation: true)
                        self.delegate?.didLoadImage(self, imageUrl: pUrlPath)
                    }
                } else {
                    self.downloadImage(aSUrl)
                }
            }
            
        }
    }
    
    func downloadImage(_ pUrlPath:String) {
        if self.netRequest != nil {
            self.stopLoading()
        }
        let s1 = pUrlPath as URLConvertible
        guard let url = s1.asURL() else {
            let error:ZGNetworkError = ZGNetworkError()
            self.requestFailure(pUrlPath, error: error)
            return
        }
        self.netRequest = ZGNetwork.request(url, method: .get, parameters: nil, headers: nil)
        
        self.delegate?.willLoadImage(self, imageUrl: pUrlPath)
        let aUrl = pUrlPath
        netRequest?.responseData { [weak self] (resp) in
            let error:ZGNetworkError = ZGNetworkError()
            error.response = resp
            
            if resp.isSuccess && resp.responseHeaders != nil && resp.responseData != nil {
                
                let headers = resp.responseHeaders!
                let data = resp.responseData!
//                let contentLengthString:String? = headers["Content-Length"] as! String?
//                var contentLength = 0
//                if let cLengthString = contentLengthString {
//                    contentLength = Int(cLengthString)!
//                }
                
//                if data.count != contentLength {
//                    self?.requestFailure(aUrl, error: error)
//                }
                
                DispatchQueue.global().async {
                    if ZGFileUtil.isGif(data) {
                        if aUrl == self?.imagePath {
                            ZGURLCache.sharedInstance.storeData(data, forUrl: aUrl)
                            self?.showGif(data, url: aUrl)
                        }
                        self?.requestSuccess(self?.gifImage(), pUrlPath: aUrl)
                        return
                    }
                    
                    if let image1:UIImage = ZGImageForData(data) {
                        ZGURLCache.sharedInstance.storeData(data, forUrl: aUrl)
                        let image2 = predrawnImageFromImage(image1)
                        self?.requestSuccess(image2, pUrlPath: aUrl)
                    } else {
                        self?.requestFailure(aUrl, error: error)
                    }
                }
            } else {
                self?.requestFailure(aUrl, error: error)
            }
            
        }
    }
    
}

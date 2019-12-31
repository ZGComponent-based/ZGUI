//
//  ZGUIButtonExtentsion.swift
//  Pods
//
//  Created by zhaogang on 2017/5/18.
//
//

import Foundation
import UIKit
import ZGNetwork
import ZGCore

private var userDataKey: String = "userDataKey"
private var requestCacheKey: String = "requestCacheKey"
private var urlStrCacheKey: String = "urlStrCacheKey"
private var backgroundRequestCacheKey: String = "backgroundRequestCacheKey"
private var backgroundUrlCacheKey: String = "backgroundUrlStrCacheKey"

public extension UIButton{
    
    public func setImage(_ imageUrl: String?, placeholderImage: UIImage?, for state: UIControl.State){
        
        guard let urlString = imageUrl else {
            self.setImage(nil, for: state)
            return
        }
        
        if urlString.isEmpty, let placeholderImage = placeholderImage{
            //urlString 为空，如果有占位图，直接设置
            self.setImage(placeholderImage, for: state)
            return
        }
        
        if self.urlStrCache == nil{
            self.urlStrCache = [:]
        }
        
        if let imageUrlStr = self.urlStrCache?[state.rawValue]{
            if imageUrlStr == urlString {
                return
            }
        }
        
        self.urlStrCache?[state.rawValue] = urlString
        self.reloadImage(urlString, placeholderImage: placeholderImage, for: state,isBackgroundImage: false)
    }

    public func setBackgroundImage(_ imageUrl: String?, placeholderImage: UIImage?, for state: UIControl.State){
        guard let urlString = imageUrl else {
            self.setBackgroundImage(nil, for: state)
            return
        }
        
        if urlString.isEmpty, let placeholderImage = placeholderImage{
            //urlString 为空，如果有占位图，直接设置
            self.setBackgroundImage(placeholderImage, for: state)
            return
        }
        
        if self.backgroundUrlCache == nil{
            self.backgroundUrlCache = [:]
        }
        
        if let imageUrlStr = self.backgroundUrlCache?[state.rawValue]{
            if imageUrlStr == urlString {
                return
            }
        }
        
        self.backgroundUrlCache?[state.rawValue] = urlString
        self.reloadImage(urlString, placeholderImage: placeholderImage, for: state, isBackgroundImage: true)
    }
    
    func reloadImage(_ urlString: String, placeholderImage: UIImage? = nil, for state: UIControl.State, isBackgroundImage: Bool) {
        
        if let img = ZGURLCache.sharedInstance.imageForUrl(urlString, fromDisk: false){
            //内存中已经存在
            self.setConcreteImage(img, for: state, isBackgroundImage: isBackgroundImage)
            return
        }
        
        DispatchQueue.global().async {
            //从磁盘查找
            let img: UIImage? = ZGURLCache.sharedInstance.imageForUrl(urlString, fromDisk: true)
            DispatchQueue.main.async {
                if let image = img {
                    self.setConcreteImage(image, for: state, isBackgroundImage: isBackgroundImage)
                } else {
                    self.downloadImageView(urlString, placeholderImage: placeholderImage, for: state, isBackgroundImage: isBackgroundImage)
                }
            }
        }
    }
    func downloadImageView(_ urlString: String, placeholderImage: UIImage? = nil, for state: UIControl.State, isBackgroundImage: Bool) {
        
        if let placeholderImage = placeholderImage{//先设置占位图
            self.setConcreteImage(placeholderImage, for: state, isBackgroundImage: isBackgroundImage)
        }
        
        if self.requestCache == nil{
            self.requestCache = [:]
        }
        
        if let oldRequest = self.requestCache?[state.rawValue]{
            if let url = oldRequest.request()?.url?.absoluteString{
                if url == urlString{
                    return// 已经正在下载
                }else{
                    // 取消之前其他图片的请求
                    oldRequest.cancel()
                    self.requestCache?.removeValue(forKey: state.rawValue)
                }
            }
        }
        
        var netRequest: ZGNetworkRequest?
        if let url = URL.init(string: urlString){
            netRequest = ZGNetwork.request(url, method: .get, parameters: nil, headers: nil)
            self.requestCache?[state.rawValue] = netRequest
        }
        
        guard let request = netRequest else {
            return
        }
        
        request.responseData { [weak self] (resp) in
            let error:ZGNetworkError = ZGNetworkError()
            error.response = resp
            
            if resp.isSuccess && resp.responseHeaders != nil && resp.responseData != nil {
                
                let headers = resp.responseHeaders!
                let data = resp.responseData!
//                let contentLengthString: String? = headers["Content-Length"] as! String?
//                var contentLength = 0
//                if let cLengthString = contentLengthString {
//                    contentLength = Int(cLengthString)!
//                }
                
//                if data.count != contentLength {
//                    self?.downloadImageViewFailure(urlString, error: error, for: state, isBackgroundImage: isBackgroundImage)
//                }
                
                DispatchQueue.main.async {
                    if let image: UIImage = ZGImageForData(data) {
                        ZGURLCache.sharedInstance.storeData(data, forUrl: urlString)
                        self?.downloadImageViewSuccess(image, urlString: urlString, for: state, isBackgroundImage: isBackgroundImage)
                    } else {
                        self?.downloadImageViewFailure(urlString, error: error, for: state, isBackgroundImage: isBackgroundImage)
                    }
                }
            } else {
                self?.downloadImageViewFailure(urlString, error: error, for: state, isBackgroundImage: isBackgroundImage)
            }
            
        }
    }
    
    func downloadImageViewSuccess(_ image: UIImage, urlString: String, for state: UIControl.State, isBackgroundImage: Bool) -> Void {
        DispatchQueue.main.async {
            
            ZGURLCache.sharedInstance.storeImage(image: image, forUrl: urlString)
        
            if isBackgroundImage{
                if let url = self.backgroundUrlCache?[state.rawValue] {
                    if urlString == url{
                        self.setConcreteImage(image, for: state, isBackgroundImage: isBackgroundImage)
                        if (self.backgroundRequestCache?[state.rawValue]) != nil {
                            self.backgroundRequestCache?.removeValue(forKey: state.rawValue)
                        }
                    }
                }
            }else{
                if let url = self.urlStrCache?[state.rawValue] {
                    if urlString == url{
                        self.setConcreteImage(image, for: state, isBackgroundImage: isBackgroundImage)
                        if (self.requestCache?[state.rawValue]) != nil {
                            self.requestCache?.removeValue(forKey: state.rawValue)
                        }
                    }
                }
            }
        }
    }
    
    func downloadImageViewFailure(_ urlString: String, error: ZGNetworkError, for state: UIControl.State, isBackgroundImage: Bool) -> Void {
        DispatchQueue.main.async {
            
            if isBackgroundImage{
                if let urlStr = self.backgroundUrlCache?[state.rawValue]{
                    if urlStr == urlString{
                        self.backgroundUrlCache?.removeValue(forKey: state.rawValue)
                        if (self.backgroundRequestCache?[state.rawValue]) != nil {
                            self.backgroundRequestCache?.removeValue(forKey: state.rawValue)
                        }
                    }
                }
            }else{
                if let urlStr = self.urlStrCache?[state.rawValue]{
                    if urlStr == urlString{
                        self.urlStrCache?.removeValue(forKey: state.rawValue)
                        if (self.requestCache?[state.rawValue]) != nil {
                            self.requestCache?.removeValue(forKey: state.rawValue)
                        }
                    }
                }
            }
        }
    }
    
    func setConcreteImage(_ image: UIImage, for state: UIControl.State, isBackgroundImage: Bool){
        DispatchQueue.main.async{
        if isBackgroundImage{
            self.setBackgroundImage(image, for: state)
        }else{
            self.setImage(image, for: state)
        }
        }
    }
    
    public var userData: Any?{
        get{
            if let userData = objc_getAssociatedObject(self, &userDataKey) {
                return userData
            }
            return nil
        }
        set{
            objc_setAssociatedObject(self, &userDataKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    private var requestCache: [UInt: ZGNetworkRequest]?{
        get{
            if let dic = objc_getAssociatedObject(self, &requestCacheKey) as? [UInt: ZGNetworkRequest] {
                return dic
            }
            return nil
        }
        set{
            objc_setAssociatedObject(self, &requestCacheKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    private var urlStrCache: [UInt: String]?{
        get{
            if let dic = objc_getAssociatedObject(self, &urlStrCacheKey) as? [UInt: String] {
                return dic
            }
            return nil
        }
        set{
            objc_setAssociatedObject(self, &urlStrCacheKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    private var backgroundRequestCache: [UInt: ZGNetworkRequest]?{
        get{
            if let dic = objc_getAssociatedObject(self, &backgroundRequestCacheKey) as? [UInt: ZGNetworkRequest] {
                return dic
            }
            return nil
        }
        set{
            objc_setAssociatedObject(self, &backgroundRequestCacheKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    private var backgroundUrlCache: [UInt: String]?{
        get{
            if let dic = objc_getAssociatedObject(self, &backgroundUrlCacheKey) as? [UInt: String] {
                return dic
            }
            return nil
        }
        set{
            objc_setAssociatedObject(self, &backgroundUrlCacheKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    //按钮渐变
    func gradientLayerWith(firstColor: UIColor, secondColor: UIColor) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        //        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        gradientLayer.shadowColor = UIColor.rgb(0, 152, 255, a: 0.2).cgColor
        gradientLayer.shadowOpacity = 1
        gradientLayer.shadowOffset = CGSize(width: 0, height: 2)
        gradientLayer.shadowRadius = 4
//        gradientLayer.cornerRadius = 20
        return gradientLayer
    }
    
    //MARK: -定义button相对label的位置
    public enum YWButtonEdgeInsetsStyle {
        case Top
        case Left
        case Right
        case Bottom
    }
    
    public func layoutButton(style: YWButtonEdgeInsetsStyle, imageTitleSpace: CGFloat) {
        //得到imageView和titleLabel的宽高
        let imageWidth = self.imageView?.frame.size.width
        let imageHeight = self.imageView?.frame.size.height
        
        var labelWidth: CGFloat! = 0.0
        var labelHeight: CGFloat! = 0.0
        
        labelWidth = self.titleLabel?.intrinsicContentSize.width
        labelHeight = self.titleLabel?.intrinsicContentSize.height
        
        //初始化imageEdgeInsets和labelEdgeInsets
        var imageEdgeInsets = UIEdgeInsets.zero
        var labelEdgeInsets = UIEdgeInsets.zero
        
        //根据style和space得到imageEdgeInsets和labelEdgeInsets的值
        switch style {
        case .Top:
            //上 左 下 右
            imageEdgeInsets = UIEdgeInsets(top: -labelHeight-imageTitleSpace/2, left: 0, bottom: 0, right: -labelWidth)
            labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth!, bottom: -imageHeight!-imageTitleSpace/2, right: 0)
            break;
            
        case .Left:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -imageTitleSpace/2, bottom: 0, right: imageTitleSpace)
            labelEdgeInsets = UIEdgeInsets(top: 0, left: imageTitleSpace/2, bottom: 0, right: -imageTitleSpace/2)
            break;
            
        case .Bottom:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -labelHeight!-imageTitleSpace/2, right: -labelWidth)
            labelEdgeInsets = UIEdgeInsets(top: -imageHeight!-imageTitleSpace/2, left: -imageWidth!, bottom: 0, right: 0)
            break;
            
        case .Right:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: labelWidth+imageTitleSpace/2, bottom: 0, right: -labelWidth-imageTitleSpace/2)
            labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth!-imageTitleSpace/2, bottom: 0, right: imageWidth!+imageTitleSpace/2)
            break;
            
        }
        
        self.titleEdgeInsets = labelEdgeInsets
        self.imageEdgeInsets = imageEdgeInsets
        
    }

}

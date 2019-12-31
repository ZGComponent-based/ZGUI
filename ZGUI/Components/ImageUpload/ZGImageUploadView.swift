//
//  ZGImageUploadView.swift
//  ZGUI
//
//  Created by zhaogang on 2017/12/15.
//

import UIKit
import ZGNetwork
import ZGCore
import SwiftyJSON

class UploadVo: NSObject {
    var code:Int?
    var message:String?
    var picUrl:String?
    
    class func convertJSON(_ json:JSON) -> UploadVo {
        let bvo = UploadVo()
        
        let meta1 = json["meta"].dictionaryObject
        if let dictItem = meta1 {
            let resultsJson = JSON(dictItem)
            bvo.code = resultsJson["code"].int
            bvo.message = resultsJson["msg"].string
        }
        
        let results = json["results"].dictionaryObject
        if let dictItem = results {
            let resultsJson = JSON(dictItem)
            bvo.picUrl = resultsJson["retval"].string
        }
        return bvo
    }
}


class ZGImageUploadView: UIView {
    let imageMaxHeight:CGFloat = 160
    let titleContentHeight:CGFloat = 45
    let buttonHeight:CGFloat = 44
    let imageButtonMinGap:CGFloat = 20
    var callback:((String?)->Void)?
    var uploadToUrl:String = ""
    var uploadParams:[String:String]?
    
    var uploadModel:ZGImageUploadModel?
    
    @objc func cancelHandler() {
        callback?(nil)
    }
    
    @objc func okHandler() {
        guard let uploadModel = self.uploadModel else {
            return
        }
        uploadModel.resetTitle("上传图片...")
        self.reloadModel()
        
        var rect = self.bounds
        rect.size.height = self.cancelButton.height
        rect.size.width = self.width
        rect.origin.y = self.height - rect.height
        let view1 = ZGLoadingBox.showLoading(frame:rect, inView:self)
        view1.backgroundColor = UIColor.white
        
//        self.uploadParams?["ticket"] = "eyJhbGciOiJIUzI1NiJ9.eyJjaGFubmVsIjoyLCJjcmVhdGVUaW1lIjoxNTE5ODI2MjEzOTcwLCJuYW1lIjoiMTg2MTAzMjcxNzAiLCJwYXlGbGFnIjowLCJ1aWQiOjQwfQ.lFOc0QwLvenzVrVPn9wmV9EkcevGrXe_OQ3bhEIUGyg"
        
        ZGNetwork.uploadFile(uploadModel.imageData, headers: nil, parameters: self.uploadParams, to: self.uploadToUrl, completion: {[weak self] (resp) in
            if let weakSelf = self {
                ZGLoadingBox.hideLoading(weakSelf)
            }
            if resp.responseHttpStatus == 200 {
                if let jsonDict = resp.responseJson {
                    let json = JSON(jsonDict)
                    let vo = UploadVo.convertJSON(json)
                    if let code = vo.code {
                        if code == 0 {
                            //上传成功
                            self?.callback?(vo.picUrl)
                        } else {
                            var err = ""
                            if let tip = vo.message {
                                err = tip
                            }
                            uploadModel.resetTitle(err)
                            uploadModel.resetOkTitle("重试")
                            self?.reloadModel()
                        }
                    }
                }
            } else {
                uploadModel.resetTitle("图片上传失败！")
                uploadModel.resetOkTitle("重试")
                self?.reloadModel()
            }
        }) { (errMessage) in
            
        }
        
//        let request = ZGNetwork.upload(uploadModel.imageData,
//                                       method: .post,
//                                       parameters: nil,
//                                       headers: nil,
//                                       to: self.uploadToUrl)
//        request.uploadProgress { (progress) in
//
//        }
//
//        request.responseJSON { [weak self] (resp) in
//
//        }
    }
    
    func size() -> CGSize {
        let width:CGFloat = 275
        let height:CGFloat = titleContentHeight + imageMaxHeight + buttonHeight + imageButtonMinGap
        return CGSize.init(width: width, height: height)
    }
    
    func sizeOfImage(image:UIImage) -> CGSize {
        var size1:CGSize = .zero
        
        let imageSize = image.size
        
        if imageSize.height > imageMaxHeight {
            size1.height = imageMaxHeight
        } else {
            size1.height = imageSize.height
        }
        if (imageSize.height>0) {
            size1.width = (imageSize.width * size1.height) / imageSize.height
        }
        
        return size1
    }
    
    lazy var titleLabel: UILabel = {
        return self.addNormalLabel()
    }()
    
    lazy var cancelButton: UIButton = {
        let ok = self.addCustomButton()
        ok.addTarget(self, action: #selector(cancelHandler), for: .touchUpInside)
        return ok
    }()
    
    lazy var okButton: UIButton = {
        let ok = self.addCustomButton()
        ok.addTarget(self, action: #selector(okHandler), for: .touchUpInside)
        return ok
    }()
    
    lazy var hLineLayer: CALayer = {
        return self.addNormalLayer()
    }()
    
    lazy var vLineLayer: CALayer = {
        return self.addNormalLayer()
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        self.addSubview(imageView)
        imageView.backgroundColor = UIColor.clear
        return imageView
    }()
    
    static func showInView(_ view:UIView) -> ZGImageUploadView {
        let uploadView = ZGImageUploadView(frame: .zero)
        uploadView.layer.cornerRadius = 5
        uploadView.layer.masksToBounds = true
        uploadView.backgroundColor = UIColor.white
        var rect = CGRect.zero
        rect.size = uploadView.size()
        rect.origin.x = (view.width - rect.width) / 2
        rect.origin.y = (view.height - rect.height) / 2
        uploadView.frame = rect
        view.addSubview(uploadView)
        
        return uploadView
    }
    
    func reloadModel() {
        guard let model = self.uploadModel else {
            return
        }
        self.imageView.image = UIImage(data:model.imageData)
        self.titleLabel.attributedText = model.title
        self.cancelButton.setAttributedTitle(model.cancelTitle, for: .normal)
        self.okButton.setAttributedTitle(model.okTitle, for: .normal)
        
        self.vLineLayer.backgroundColor = UIColor.color(withHex: 0xf3f3f3).cgColor
        self.hLineLayer.backgroundColor = self.vLineLayer.backgroundColor
        
        self.layoutSubviews()
    }
    
    func setModel(_ model:ZGImageUploadModel) {
        self.uploadModel = model
        self.reloadModel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let uploadModel = self.uploadModel else {
            return
        }
        
        var titleRect = self.titleLabel.frame
        titleRect.size = uploadModel.titleSize
        titleRect.origin.x = (self.width - titleRect.width) / 2
        titleRect.origin.y = (titleContentHeight - titleRect.height) / 2
        self.titleLabel.frame = titleRect
        
        if let image = self.imageView.image {
            var imageRect = self.imageView.frame
            imageRect.size = self.sizeOfImage(image: image)
            imageRect.origin.x = (self.width - imageRect.width) / 2
            imageRect.origin.y = titleContentHeight
            self.imageView.frame = imageRect
        }
        
        let btnWidth:CGFloat = self.width / 2
        var btnRect = self.cancelButton.frame
        btnRect.size.height = buttonHeight
        btnRect.size.width = btnWidth
        btnRect.origin.y = self.height - buttonHeight
        self.cancelButton.frame = btnRect
        
        btnRect.origin.x = btnWidth
        self.okButton.frame = btnRect
        
        var hLineRect = self.hLineLayer.frame
        hLineRect.size.height = 0.5
        hLineRect.size.width = self.width
        hLineRect.origin.y = btnRect.origin.y
        
        var vLineRect = self.vLineLayer.frame
        vLineRect.size.width = 0.5
        vLineRect.size.height = buttonHeight
        vLineRect.origin.x = btnWidth
        vLineRect.origin.y = hLineRect.origin.y
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        self.hLineLayer.frame = hLineRect
        self.vLineLayer.frame = vLineRect
        CATransaction.commit()
    }
}

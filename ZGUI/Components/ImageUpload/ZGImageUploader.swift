//
//  ZGImageUploader.swift
//  ZGUI
//
//  Created by zhaogang on 2017/12/15.
//

import UIKit

public class ZGImageUploader:NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    weak var controller:ZGBaseViewCTL?
    var callback:(([String:Any]) -> Void)?
    var param:[String:Any]?
    
    var didAppear:Bool = false
    
    public static var shared: ZGImageUploader {
        struct Static {
            static let instance: ZGImageUploader = ZGImageUploader.init()
        }
        
        return Static.instance
    }
    
    fileprivate override init() {
    }
    
    func exit(url:String?) {
        self.didAppear = false
        if var param = self.param {
            if let url1 = url {
                param["url"] = url1
            }
            self.callback?(param)
        }
    }
    
    public func upload(param:[String:Any],
                       targetController:ZGBaseViewCTL,
                       completion: @escaping (([String:Any]) -> Void)) {
        if self.didAppear {
            return
        }
        
        self.didAppear = true
        
        self.callback = completion
        self.controller = targetController
        self.param = param
        
        let actionSheet = UIAlertController(title: "上传图片", message: nil, preferredStyle: .actionSheet)
        let cancelBtn = UIAlertAction(title: "取消", style: .cancel, handler: {
           [weak self] (action: UIAlertAction) -> Void in
            self?.didAppear = false
        })
        
        let takePhotos = UIAlertAction(title: "拍照", style: .destructive, handler: {[weak self]
            (action: UIAlertAction) -> Void in
            //判断是否能进行拍照，可以的话打开相机
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
//                picker.allowsEditing = true
                targetController.present(picker, animated: true, completion: nil)
            } else {
                targetController.showTextTip("设备不支持摄像头")
                self?.didAppear = false
            }
            
        })
        let selectPhotos = UIAlertAction(title: "相册选取", style: .default, handler: {
            (action:UIAlertAction)
            -> Void in
            //调用相册功能，打开相册
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
//            picker.allowsEditing = true
            targetController.present(picker, animated: true, completion: nil)
            
        })
        actionSheet.addAction(cancelBtn)
        actionSheet.addAction(takePhotos)
        actionSheet.addAction(selectPhotos)
        targetController.present(actionSheet, animated: true, completion: nil)
    }
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
            let type = info[UIImagePickerController.InfoKey.mediaType] as? String else {
                self.didAppear = false
                return
        }
        
        var imageData:Data? = nil
        if type == "public.image" {
            //修正图片的位置
            let fImage = pImage.fixOrientation()
            if let image1 = fImage.scaleImage(forWidth: 500) {
                imageData = image1.jpegData(compressionQuality: 0.5)
            } else {
                imageData = fImage.jpegData(compressionQuality: 0.5)
            }
            
        }
        
        picker.dismiss(animated: true) {[weak self] in
            if let data1 = imageData {
                let model = ZGImageUploadModel(imageData: data1)
                model.resetTitle("您确定发送图片吗？")
                model.resetCancelTitle("取消")
                model.resetOkTitle("确定")
                
                if let view = ZGUIUtil.getMainWindow() {
                    let uploadContainer = UIView(frame: view.bounds)
                    view.addSubview(uploadContainer)
                    uploadContainer.backgroundColor = UIColor.color(withHex: 0, alpha: 0.6)
                    let uploadView = ZGImageUploadView.showInView(uploadContainer)
                    if let uploadToUrl = self?.param?["uploadToUrl"] as? String {
                        uploadView.uploadToUrl = uploadToUrl
                        uploadView.uploadParams = self?.param?["uploadParams"] as? [String:String]
                    }
                    uploadView.setModel(model)
                    
                    uploadView.callback = {[weak self] (url) in
                        uploadContainer.removeFromSuperview()
                        self?.exit(url:url)
                    }
                }
            }
        }
    }
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.didAppear = false
        picker.dismiss(animated: true, completion: nil)
    }
}

//
//  ZGImageExtension.swift
//  ZGUI
//
//  Created by zhaogang on 2017/12/15.
//

import UIKit

public extension UIImage {
    // 修复图片旋转
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
        var transform = CGAffineTransform.identity
        switch self.imageOrientation {
        case .down,.downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
        case .left,.leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
            
        case .right,.rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: CGFloat(-M_PI_2))
            
        default:
            break
        }
        
        
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx!.concatenate(transform)
        switch self.imageOrientation {
        case .left,.leftMirrored,.rightMirrored,.right:
            ctx?.draw(self.cgImage!, in: CGRect(x :0,y:0,width:self.size.height,height: self.size.width))
            
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x :0,y:0,width:self.size.width,height: self.size.height))
        }
        let cgimg = ctx!.makeImage()
        let img = UIImage(cgImage: cgimg!)
        return img
    }
    
    /// 重设图片大小
    func resizeImage(size:CGSize)-> UIImage? {
        let scale: CGFloat = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        self.draw(in: CGRect.init(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// 等比率缩放
    func scaleImage(scaleSize:CGFloat)-> UIImage? {
        let size = CGSize.init(width:self.size.width * scaleSize, height:self.size.height * scaleSize)
        return resizeImage(size:size)
    }
    
    /// 按宽度缩放
    func scaleImage(forWidth width:CGFloat)-> UIImage? {
        let w1 = self.size.width
        let h1 = self.size.height
 
        let height:CGFloat = ceil(width*h1/w1)
        let size1 = CGSize.init(width: width, height: height)
        return resizeImage(size:size1)
    }
    
    /// 按高度缩放
    func scaleImage(forHeight height:CGFloat)-> UIImage? {
        let w1 = self.size.width
        let h1 = self.size.height
        
        let width:CGFloat = ceil(height*w1/h1)
        let size1 = CGSize.init(width: width, height: height)
        return resizeImage(size:size1)
    }
    
    func compressQualityWith(maxLength:Int) -> Data? {
        var compression: CGFloat = 1
        //原图片是1.0，此处均压缩至0.7
        guard var data = self.jpegData(compressionQuality: 0.7) else { return nil }
        print("压缩前M: \( Double((data.count)/1024/1024))")
        if data.count < maxLength {
            return data
        }
        print("压缩前M", data.count / 1024 / 1024, "M")
        var max: CGFloat = 1
        var min: CGFloat = 0
        for _ in 0..<6 {
            compression = (max + min) / 2
            if let temp_data = self.jpegData(compressionQuality: compression) {
               data = temp_data
            }
            if CGFloat(data.count) < CGFloat(maxLength) * 0.9 {
                min = compression
            } else if data.count > maxLength {
                max = compression
            } else {
                break
            }
        }
        guard var resultImage: UIImage = UIImage(data: data) else {
            return data
        }
        if data.count < maxLength {
            print("压缩后M", data.count / 1024 / 1024, "M")
            return data
        }
        let lastDataLength = 0
        
        while data.count > maxLength && data.count != lastDataLength {
            let ratio = Float(maxLength / data.count)
            let newSize:CGSize = CGSize.init(width: resultImage.size.width * CGFloat(sqrtf(ratio)) , height: resultImage.size.height * CGFloat(sqrtf(ratio)))
            UIGraphicsBeginImageContext(newSize)
            resultImage.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            if let result_Image = UIGraphicsGetImageFromCurrentImageContext() {
                resultImage = result_Image
            }
            UIGraphicsEndImageContext()
            if let result_data = resultImage.jpegData(compressionQuality: 0.7) {
                data = result_data
            }
        }
        return data
    }
    
    func compressQualityWith(maxLength:Int,maxWith:CGFloat,maxHeight:CGFloat) -> Data? {
        var imageSize = self.size  //取出要压缩的image尺寸
        var imageWidth = imageSize.width //图片宽度
        var imageHeight = imageSize.height //图片高度
        var data = self.jpegData(compressionQuality: 1)
        // 宽高都大于最大分辨率
        if imageWidth > maxWith && imageHeight > maxHeight {
            if imageWidth > imageHeight {
                let scale = imageHeight / imageWidth
                imageWidth = maxWith
                imageHeight = imageWidth * scale
            } else {
                let scale = imageWidth / imageHeight
                imageHeight = maxHeight
                imageWidth = imageHeight * scale
            }
            let newSize:CGSize = CGSize.init(width: imageWidth, height: imageHeight)
            let newImage = self.resizeImg(size: newSize)
            data =  newImage?.compressQualityWith(maxLength: maxLength)
        } else if imageWidth > maxWith && imageHeight < maxHeight {
            // 宽大于最大分辨率宽，高小于最大分辨率高
            let scale = imageHeight / imageWidth
            imageWidth = maxWith
            imageHeight = imageWidth * scale
            let newSize:CGSize = CGSize.init(width: imageWidth, height: imageHeight)
            let newImage = self.resizeImg(size: newSize)
            data =  newImage?.compressQualityWith(maxLength: maxLength)
        } else if imageWidth < maxWith && imageHeight > maxHeight {
            // 宽小于最大分辨率宽，高大于最大分辨率高
            let scale = imageWidth / imageHeight
            imageHeight = maxHeight
            imageWidth = imageHeight * scale
            let newSize:CGSize = CGSize.init(width: imageWidth, height: imageHeight)
            let newImage = self.resizeImg(size: newSize)
            data =  newImage?.compressQualityWith(maxLength: maxLength)
        } else {
            // 宽高 都小于最大分辨率
            data = self.compressQualityWith(maxLength: maxLength)
        }
        return data
    }
    
    func resizeImg(size:CGSize) -> UIImage? {
         UIGraphicsBeginImageContext(size)
         self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
         let newImage = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()
        return newImage
    }
}

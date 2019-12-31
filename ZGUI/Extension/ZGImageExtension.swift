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
}

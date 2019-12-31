//
//  UIImage+extension.swift
//  ZGCamera
//
//  Created by zhaogang on 2018/3/31.
//  Copyright © 2018年 zhaogang. All rights reserved.
//

import UIKit

extension UIImage{
    func hasAlpha() -> Bool {
        let alhaInfo = self.cgImage?.alphaInfo
        
        return (alhaInfo == CGImageAlphaInfo.first || alhaInfo == CGImageAlphaInfo.last || alhaInfo == .premultipliedFirst || alhaInfo == .premultipliedLast)
    }
    
    func croppedImageWithFrame(frame:CGRect,angle:Int) -> UIImage {
        var croppedImage: UIImage? = nil
        UIGraphicsBeginImageContextWithOptions(frame.size, !self.hasAlpha(), self.scale)
        
        if let context: CGContext = UIGraphicsGetCurrentContext(){
            if angle != 0 {
                let imageView: UIImageView = UIImageView(image: self)
                imageView.layer.minificationFilter = CALayerContentsFilter.nearest
                imageView.layer.magnificationFilter = CALayerContentsFilter.nearest
                imageView.transform = CGAffineTransform.init(rotationAngle:CGFloat(angle) * (.pi / 180.0))
                let rotatedRect: CGRect = imageView.bounds.applying(imageView.transform)
                let containerView: UIView = UIView(frame: CGRect(origin: CGPoint.zero, size: rotatedRect.size))
                containerView.addSubview(imageView)
                imageView.center = containerView.center
                
                context.translateBy(x:  -frame.origin.x, y: -frame.origin.y)
                
                containerView.layer.render(in: context)
            } else {
                context.translateBy(x: -frame.origin.x,y: -frame.origin.y)
                self.draw(at: CGPoint.zero)
                
            }
        }
        
        
        croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return  UIImage(cgImage: (croppedImage?.cgImage)!, scale: UIScreen.main.scale, orientation: .up)
        
    }
    
    
    func rotatedImageWithImage(transform:CGAffineTransform) -> UIImage {
        let size = self.size
        
        UIGraphicsBeginImageContext(size)
        
        if let context: CGContext = UIGraphicsGetCurrentContext(){
            
            context.translateBy(x: size.width / 2, y: size.height / 2)
            context.concatenate(transform)
            context.translateBy(x: size.width / -2, y: size.height / -2)
        }
        self.draw(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rotatedImage!
        
    }
    
    func swapWidthAndHeight(rect:CGRect) -> CGRect {
        let swap = rect.size
        var newRect = CGRect.zero
        
        newRect.size.width = swap.height
        newRect.size.height = swap.width
        
        return rect
    }
    
    
    // 修复图片旋转
    func rotate(orient:UIImage.Orientation) -> UIImage {
        
        var bnds = CGRect.zero
        var copy :UIImage?
        let imag = self.cgImage
        
        var ctxt : CGContext?
        var rect  = CGRect.zero
        var tran = CGAffineTransform.identity
        
        if let imageWidth = imag?.width{
            rect.size.width = CGFloat(imageWidth)
            rect.size.height = CGFloat(imageWidth)
            bnds = rect
            switch orient {
            case .up:
                return self
            case .down:
                tran = CGAffineTransform(translationX: rect.width, y: rect.height)
                tran = tran.rotated(by: CGFloat(Double.pi))
                break
                
            case .left:
                bnds = swapWidthAndHeight(rect: bnds)
                tran = CGAffineTransform(translationX: 0.0, y: rect.size.width)
                tran = tran.rotated(by: CGFloat(Double.pi * 3.0 / 2.0))
                break
            case .right:
                bnds = swapWidthAndHeight(rect: bnds)
                tran = CGAffineTransform(translationX: rect.size.height, y: 0.0)
                tran = tran.rotated(by: CGFloat(Double.pi/2.0))
                break
            default:
                return self
            }
        }
        
        
        UIGraphicsBeginImageContext(bnds.size)
        if let  ctxt = UIGraphicsGetCurrentContext(){
            if orient == .left || orient == .right {
                ctxt.scaleBy(x: -1.0, y: 1.0)
                ctxt.translateBy(x:-rect.height, y:0.0)
            }else{
                ctxt.translateBy(x: 0.0, y: rect.width)
                ctxt.scaleBy(x: 1.0, y: -1.0)
                
            }
            ctxt.concatenate(tran)
            if let img = imag{
                ctxt.draw(img, in: rect)
            }
            copy = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
        }
        return copy!
    }
    
    
    
    func imageResize(newSize:CGSize) ->UIImage {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        
        self.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
        
    }
    
    func fixOrientation1() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
            
        default:
            break
        }
        
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
            
        default:
            break
        }
        var ctx:CGContext?
        var cgimg:CGImage?
        var img:UIImage?
        if let cgimage = self.cgImage{
            if let space = cgimage.colorSpace{
                ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: cgimage.bitsPerComponent, bytesPerRow: 0, space: space, bitmapInfo: cgimage.bitmapInfo.rawValue)
                ctx?.concatenate(transform)
                
                switch self.imageOrientation {
                case .left, .leftMirrored, .right, .rightMirrored:
                    ctx?.draw(cgimage, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
                    break
                    
                default:
                    ctx?.draw(cgimage, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
                    break
                }
            }
            
        }
        if let cgimg = ctx?.makeImage(){
            img = UIImage(cgImage: cgimg)
        }
        return img!
    }
}

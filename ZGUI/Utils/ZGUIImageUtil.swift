//
//  ZGUIImageUtil.swift
//  Pods
//
//  Created by zhaogang on 2017/7/13.
//
//

import UIKit

public class ZGUIImageUtil: NSObject {
    public class func scaleSizeOfImageSize(_ imageSize:CGSize, bounds:CGRect) -> CGSize {
        var size:CGSize = .zero
        let maxHeight:CGFloat = bounds.size.height
        let maxWidth:CGFloat = bounds.size.width
        let widthScale:CGFloat = imageSize.width/maxWidth
        let heightScale:CGFloat = imageSize.height/maxHeight
        if widthScale >= heightScale {
            size.width = maxWidth
            size.height = imageSize.height/widthScale
        } else {
            size.height = maxHeight
            size.width = imageSize.width/heightScale
        }
        
        size.width = ceil(size.width)
        size.height = ceil(size.height)
        
        return size
    }

    public class func scaleSizeOfImage(_ image:UIImage, bounds:CGRect) -> CGSize {
        return self.scaleSizeOfImageSize(image.size, bounds: bounds)
    }
    
    public class func imageWithColor(color: UIColor, bounds: CGRect) -> UIImage?{
        UIGraphicsBeginImageContext(bounds.size)
        let context = UIGraphicsGetCurrentContext()
        var image:UIImage?
        if let contextValue = context {
            contextValue.setFillColor(color.cgColor)
            contextValue.fill(bounds)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return image
    }
}

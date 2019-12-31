//
//  ZGUIStringExtension.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/4/1.
//
//

import Foundation
import UIKit

public extension String {
    
    public func textSize(attributes attrs: [NSAttributedString.Key : Any], constrainedToSize size:CGSize = .zero, options:NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading], context: NSStringDrawingContext? = nil) -> CGSize {
        let rect = self.boundingRect(with: size, options: options, attributes: attrs, context: context);
        return CGSize.init(width: ceil(rect.width), height: ceil(rect.height));
    }
    
    public func qrImage(targetSize:CGFloat) -> UIImage? {
        
        let filter = CIFilter.init(name: "CIQRCodeGenerator")
        filter?.setValue("H", forKey: "inputCorrectionLevel")
        
        if let data = self.data(using: .utf8) {
            filter?.setValue(data, forKey: "inputMessage")
            if let ciImage = filter?.outputImage {
                //颜色滤镜
                let colorFilter = CIFilter(name: "CIFalseColor")
                colorFilter?.setValue(ciImage, forKey: "inputImage")
                colorFilter?.setValue(CIColor(cgColor: UIColor.black.cgColor), forKey: "inputColor0")// 二维码颜色
                colorFilter?.setValue(CIColor(cgColor: UIColor.white.cgColor), forKey: "inputColor1")// 背景色
                if let outputImage = colorFilter?.outputImage {
                    let scale = targetSize / outputImage.extent.size.width
                    let transform = CGAffineTransform(scaleX: scale, y: scale)
                    let transformImage = outputImage.transformed(by: transform)
 
                    let context:CIContext = CIContext.init()
                    if let cgiImage = context.createCGImage(transformImage, from: transformImage.extent) {
                        return  UIImage.init(cgImage: cgiImage)
                        
                    }
                    //放在uiimage里面
                    //                    let image = UIImage.init(ciImage: transformImage)
                }
            }
        }
        return nil
    }
    
    var containsEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
            0x1F300...0x1F5FF, // Misc Symbols and Pictographs
            0x1F680...0x1F6FF, // Transport and Map
            0x2600...0x26FF,   // Misc symbols
            0x2700...0x27BF,   // Dingbats
            0xFE00...0xFE0F,   // Variation Selectors
            0x1F900...0x1F9FF:  // Supplemental Symbols and Pictographs
                return true
            default:
                continue
            }
        }
        return false
    }
    
    /// 移除emoji
    public func text_removeEmoji() -> String {
        let pattern = "[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]"
        return self.text_pregReplace(pattern: pattern, with: "")
    }
    
    /// 返回字数
    public var text_count: Int {
        let string_NS = self as NSString
        return string_NS.length
    }
    
    /// 使用正则表达式替换
    public func text_pregReplace(pattern: String, with: String,
                                 options: NSRegularExpression.Options = []) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: [],
                                              range: NSMakeRange(0, self.text_count),
                                              withTemplate: with)
    }
    
    var pathExtension: String {
        guard let set = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, self as? CFString, "!$&'()*+,-./:;=?@_~%#[]" as? CFString, nil,CFStringBuiltInEncodings.UTF8.rawValue) else {
            return ""
        }
        guard let url = URL(string: set as String) else { return "" }
        return url.pathExtension.isEmpty ? "" : "\(url.pathExtension)"
    }


}


public extension NSAttributedString {
    
    public func textSize(constrainedToSize size:CGSize = .zero,
                         options:NSStringDrawingOptions = [.truncatesLastVisibleLine, .usesLineFragmentOrigin, .usesFontLeading],
                         context: NSStringDrawingContext? = nil) -> CGSize {
        let rect = self.boundingRect(with: size, options: options, context: context);
        return CGSize.init(width: ceil(rect.width), height: ceil(rect.height));
    }
}

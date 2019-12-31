//
//  ZGStyle.swift
//  Pods
//
//  Created by zhaogang on 2017/5/15.
//
//

import UIKit
import ZGCore

public struct ZGUILabelStyle {
    
    /// 解析 <font 里面的属性
    static func htmlFontAttribute(_ attributed:[String:String]) -> [NSAttributedString.Key:Any] {
        var attributeDict = [NSAttributedString.Key:Any]()
        
        var fontSize:Double? = nil
        var fontFamily:String? = nil
        
        if var color = attributed["color"] {
            let s1 = color.replacingOccurrences(of: "#", with: "") as NSString
            let colorHex = s1.replacingOccurrences(of: "'", with: "").hexValue()
            let textColor = UIColor.color(withHex: colorHex)
            attributeDict[.foregroundColor] = textColor
        }
        if let face = attributed["face"] {
            fontFamily = face.replacingOccurrences(of: "'", with: "")
        }
        if let line = attributed["line"] {
            let s1 = line as NSString
            let lineStyle = s1.replacingOccurrences(of: "'", with: "")
            if lineStyle == "u" {
                attributeDict[.underlineStyle] = NSUnderlineStyle.single.rawValue
            } else if lineStyle == "d" {
                attributeDict[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            }
        }
        if let size = attributed["size"] {
            let s2 = size.replacingOccurrences(of: "'", with: "")
            fontSize = Double(s2)
        }
        
        var isBold = false
        if let bold = attributed["bold"] {
            let s2 = bold.replacingOccurrences(of: "'", with: "")
            isBold = s2 == "1"
        }
        
        var kern:Float? = nil
        if var kernText = attributed["kern"] {
            kernText = kernText.replacingOccurrences(of: "'", with: "")
            kern = Float(kernText)
            attributeDict[.kern] = kern
        }
        
        if let ff = fontFamily, let fs = fontSize {
            let fontSize1 = CGFloat(fs)
            var font:UIFont = UIFont.systemFont(ofSize: fontSize1)
            if isBold {
                font = UIFont.boldSystemFont(ofSize: fontSize1)
            }
            if ff.count > 1 {
                if let font1 = UIFont.init(name: ff, size: CGFloat(fs)) {
                    font = font1
                }
            }
            attributeDict[.font] = font
        } else if let fs = fontSize {
            let fontSize1 = CGFloat(fs)
            var font:UIFont = UIFont.systemFont(ofSize: fontSize1)
            if isBold {
                font = UIFont.boldSystemFont(ofSize: fontSize1)
            }
            attributeDict[.font] = font
        }
        
        return attributeDict
    }
    
    /// 将html标签样式转为 NSMutableAttributedString
    ///
    /// - parameter styleText: 取值如：`<font face='Helvetica' size='13' color='#E50F3C' line='u' bold='1' kern='2.5' >Hello world</font>`
    /// face 不传则用系统字体
    /// line 可不传, u:下划线 d:删除线
    /// bold 可不传 1:粗体
    /// kern 可不传 代表字间距，
    /// 删除线不支持中文
    ///
    public static func attributedStringOfHtmlText(_ styleText:String?, paragraphStyle:NSMutableParagraphStyle? = nil) -> NSAttributedString? {
        guard var htmlText = styleText else {
            return nil
        }
        //需要做替换，否则正则表达式不能正常匹配
        htmlText = htmlText.replacingOccurrences(of: "\r\n", with: "\n")
        
        let scanner = Scanner(string: htmlText)
        scanner.charactersToBeSkipped = nil
        var tagText:NSString?
        
        let text:NSString = htmlText as NSString
        var lPositoin = 0
        
        var componentArray = [(attribute:[NSAttributedString.Key:Any], range:NSRange)]()
        var contentArray = [String]()
        
        while !scanner.isAtEnd {
            // 忽略了空格换行等作为停止，改为再次扫描到头部作为结束
            scanner.scanUpTo("<font", into: nil)
            scanner.scanUpTo("font>", into: &tagText)

            if scanner.isAtEnd {
                break
            }
            if let t1 = tagText {
                var t2 = t1 as String
                t2 = t2.replacingOccurrences(of: "</", with: "")
                if let range = t2.range(of: ">") {
                    let content = String(t2[range.upperBound...])
                    let style = t2[...range.lowerBound]
                    var styleText = style.replacingOccurrences(of: "<font", with: "")
                    styleText = styleText.replacingOccurrences(of: ">", with: "")
                    styleText = styleText.trimmingCharacters(in: .whitespaces)
                    let styleArr = styleText.components(separatedBy: " ")
                    
                    var attributed = [String:String]()
                    for styleItem in styleArr {
                        let pStyle = styleItem.trimmingCharacters(in: .whitespaces)
                        if pStyle.isEmpty {
                            continue
                        }
                        let cArr = pStyle.components(separatedBy: "=")
                        if cArr.count == 2 {
                            attributed[cArr[0]] = cArr[1]
                        }
                    }
                    
                    var attributeDict = self.htmlFontAttribute(attributed)
                    let contentLength = (content as NSString).length
                    let range = NSRange.init(location: lPositoin, length: contentLength)
                    
                    lPositoin += contentLength
                    let touple = (attributeDict, range)
                    
                    componentArray.append(touple)
                    contentArray.append(content)
                }
            }
        }
        
        let content = contentArray.joined(separator: "")
        let aText:NSMutableAttributedString = NSMutableAttributedString.init(string: content)
        
        for item in componentArray {
            aText.addAttributes(item.attribute, range: item.range)
        }
        if let paragraphStyle = paragraphStyle {
            let length = (content as NSString).length
            let range1 = NSRange.init(location: 0, length: length)
            aText.addAttributes([.paragraphStyle:paragraphStyle], range: range1)
        }
        
        return aText
    }
    
}

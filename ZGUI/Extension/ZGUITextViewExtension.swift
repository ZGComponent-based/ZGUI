//
//  ZGUITextViewExtension.swift
//  ZGUI
//
//  Created by zhaogang on 2018/2/8.
//

import UIKit

import UIKit

public let PlaceholderTag:Int = 103301

extension UITextView: UITextViewDelegate {
    
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    public var attributedPlaceholder: NSAttributedString? {
        get {
            var placeholderText: NSAttributedString?
            
            if let placeholderLabel = self.viewWithTag(PlaceholderTag) as? UILabel {
                placeholderText = placeholderLabel.attributedText
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(PlaceholderTag) as? UILabel {
                placeholderLabel.attributedText = newValue
                placeholderLabel.numberOfLines = 0
            } else {
                self.addPlaceholder(newValue)
            }
        }
    }
 
    //调用的地方重写
//    public func textViewDidChange(_ textView: UITextView) {
//        if let placeholderLabel = self.viewWithTag(PlaceholderTag) as? UILabel {
//            placeholderLabel.isHidden = self.text.characters.count > 0
//        }
//    }
    
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(PlaceholderTag) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            var labelHeight = self.height
            if let att = placeholderLabel.attributedText {
                labelHeight = att.textSize(constrainedToSize: CGSize.init(width: labelWidth, height: 1000)).height
            }
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
 
    private func addPlaceholder(_ placeholderText: NSAttributedString?) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.attributedText = placeholderText
        placeholderLabel.sizeToFit()
        placeholderLabel.tag = PlaceholderTag
        placeholderLabel.numberOfLines = 0
        placeholderLabel.isHidden = String(self.text).count > 0
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
    }
 
}

//
//  ZGImagePreviewCountView.swift
//  Pods
//
//  Created by zhaogang on 2017/7/13.
//
//

import UIKit

public class ZGImagePreviewCountView: ZGImagePreviewBottomView {
    var currentItem:ZGImagePreviewItem?
    
    @objc func handleSave() {
        if let currentItem = currentItem, let countItem = self.item as? ZGImagePreviewCountItem {
            if let handler = countItem.saveHandler {
                handler(currentItem)
            }
        }
    }
    
    lazy var saveButton: UIButton = {
        return self.addCustomButton()
    }()
    
    lazy var saveLabel: UILabel = {
        let label = self.addNormalLabel()
        label.textAlignment = .center
        label.clipsToBounds = true
        label.backgroundColor = UIColor.color(withHex: 0x1f2123, alpha: 0.6)
        return label
    }()
    
    lazy var countLabel: UILabel = {
        let label = self.addNormalLabel()
        label.textAlignment = .center
        label.clipsToBounds = true
        label.backgroundColor = UIColor.color(withHex: 0x1f2123, alpha: 0.6)
        return label
    }()
    
    func resetSaveLabel() {
        guard let item = self.item as? ZGImagePreviewCountItem else {
            return
        }
        if !item.enableSavePhoto {
            return
        }
        let text = "<font color='#ffffff' size='12'>保存</font>"
        
        if let attributedText = ZGUILabelStyle.attributedStringOfHtmlText(text) {
            var size = attributedText.textSize(constrainedToSize: CGSize.init(width: Int.max, height: 100))
            size.width += 12
            self.saveLabel.attributedText = attributedText
            var rect = self.saveLabel.frame
            rect.size = size
            rect.size.height += 4
            rect.origin.x = self.width - rect.width - 20
            self.saveLabel.frame = rect
            var rect2 = rect
            rect2.size.width += 20
            rect2.size.height += 20
            rect2.origin.y -= 10
            rect2.origin.x -= 10
            self.saveButton.frame = rect2
            self.saveButton.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
            
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            self.saveLabel.layer.cornerRadius = 2
            CATransaction.commit()
        }
    }
    
    public override func setItem(_ item:ZGImagePreviewBottomItemProtocol) {
        super.setItem(item)
 
        self.resetSaveLabel()
    }
    
    public override func setCurrentIndex(_ index:Int, item:ZGImagePreviewItem) -> Void {
        self.currentItem = item
        guard let total = self.item?.total else {
            return
        }
        let text = "<font color='#ffffff' size='12'>\(index+1)/\(total)</font>"
        self.countLabel.attributedText = ZGUILabelStyle.attributedStringOfHtmlText(text)
        if let attributedText = self.countLabel.attributedText {
            var size = attributedText.textSize(constrainedToSize: CGSize.init(width: Int.max, height: 100))
            size.width += 12
            size.height += 4
            var rect = self.countLabel.frame
            rect.size = size
            rect.origin.x = 20
            rect.origin.y = 0
            self.countLabel.frame = rect
            
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            self.countLabel.layer.cornerRadius = 2
            CATransaction.commit()
        }
    }
    
}

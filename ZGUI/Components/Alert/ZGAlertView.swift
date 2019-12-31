//
//  ZGAlertView.swift
//  Pods
//
//  Created by zhaogang on 2017/8/25.
//
//

import UIKit

class ZGAlertView: UIView {
    var tapHandler:ZGAlertTapHandler?
    var buttons = [UIButton]()
    var buttonBox:UIView!
    
    var realHeight:CGFloat = 100
    let buttonHeight:CGFloat = 54
    
    var lineLayer:CALayer!
    
    var alertItem:ZGAlertItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        var rect = frame
        rect.origin = .zero
        rect.size.height = self.buttonHeight
        let box:UIView = UIView(frame: rect)
        self.addSubview(box)
        self.buttonBox = box
        
        let path = UIBezierPath.init(roundedRect: rect, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize.init(width: 12, height: 12))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = rect
        maskLayer.path = path.cgPath
        box.layer.mask = maskLayer
        box.layer.masksToBounds = true
         
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setItem(_ item:ZGAlertItem) {
        self.alertItem = item
    }
    
    func addButtons(item:ZGAlertItem) {
        guard let buttonItems = item.buttonItems else {
            return
        }
        if self.buttons.count < 1 {
            let count = buttonItems.count
            let btnWidth:CGFloat = self.width / CGFloat(count)
            let rect = CGRect.init(origin: .zero, size: CGSize.init(width: btnWidth, height: buttonHeight))
            for item in buttonItems {
                let button = self.addButton()
                self.buttons.append(button)
                button.frame = rect
                button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
                button.setTitle(item.buttonTitle, for: .normal)
                button.setTitleColor(item.titleColor, for: .normal)
                
                if let bgColor = item.backgroundColor, let bgHighlight = item.backgroundHighlightColor {
                    if let image = ZGUIImageUtil.imageWithColor(color: bgColor, bounds: rect) {
                        button.setBackgroundImage(image, for: .normal)
                    }
                    if let image = ZGUIImageUtil.imageWithColor(color: bgHighlight, bounds: rect) {
                        button.setBackgroundImage(image, for: .highlighted)
                    }
                }
            }
        }
    }
    
    func addLineLayer() -> CALayer {
        let layer1 = CALayer()
        self.layer.addSublayer(layer1)
        layer1.backgroundColor = UIColor.color(withHex: 0xdbdbdb).cgColor
        return layer1
    }
    
    func addLabel() -> UILabel {
        let label = UILabel()
        self.addSubview(label)
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .left
        label.textColor = UIColor.color(withHex: 0x333333)
        return label
    }
    
    func addButton() -> UIButton {
        let button = UIButton(type: .custom)
        self.buttonBox.addSubview(button)
        button.addTarget(self, action: #selector(btnHandle(_:)), for: .touchUpInside)
        return button
    }
    
    @objc func btnHandle(_ sender:UIButton) {
        var index:Int = -1
        for btn in self.buttons {
            index += 1
            
            if btn === sender {
                break
            }
        }
        
        if let tapHandler = self.tapHandler {
            tapHandler(index)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var boxRect = self.buttonBox.frame
        boxRect.size.width = self.width
        boxRect.origin.x = 0
        boxRect.origin.y = self.height - boxRect.height
        self.buttonBox.frame = boxRect
        
        var gX:CGFloat = 0
        for button in self.buttons {
            var rect = button.frame
            rect.origin.x = gX
            button.frame = rect
            
            gX += rect.width
        }
    }

}

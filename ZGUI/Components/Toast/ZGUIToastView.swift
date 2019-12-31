//
//  ZGUIToastView.swift
//  Pods
//
//  Created by zhaogang on 2017/8/8.
//
//

import UIKit

open class ZGUIToastView: UIView {
    weak var textLabel:UILabel!
    var textFrame:CGRect = .zero
    
    static let ToastTag:Int = 2321101
    
    func addLabel() -> UILabel {
        let label = UILabel()
        self.addSubview(label)
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 0

        return label
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard self.textLabel.text != nil else {
            return
        }
        self.textFrame.origin.x = (self.width - self.textFrame.width) / 2
        self.textFrame.origin.y = (self.height - self.textFrame.height) / 2
        self.textLabel.frame = self.textFrame
    }

    init(frame: CGRect, text:String) {
        super.init(frame: frame)
        self.textLabel = self.addLabel()
        self.backgroundColor = UIColor.color(withHex: 0x000000, alpha: 0.8)
        let size = CGSize.init(width: frame.width-20, height: frame.height-10)
        self.textFrame.size = text.textSize(attributes: [.font:self.textLabel.font], constrainedToSize:size)
        self.textFrame.origin.x = (self.width - self.textFrame.width) / 2
        self.textFrame.origin.y = (self.height - self.textFrame.height) / 2
        
        var width = self.textFrame.width + 30
        var height = self.textFrame.height + 40
        
        if width > frame.width {
            width = frame.width
        }
        
        if height > frame.height {
            height = frame.height
        }
        
        var rect2 = frame
        rect2.size = CGSize.init(width: width, height: height)
        self.frame = rect2
        
        self.textLabel.text = text
        
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //todo 需要处理屏幕旋转
    class func showInView(_ view:UIWindow, text:String) {
        if view.viewWithTag(ToastTag) != nil {
            return
        }
        
        var rect = view.frame
        rect.size.width = rect.width - 40
        rect.size.height = 200
        let tipView = ZGUIToastView(frame: rect, text:text)
        tipView.alpha = 0
        view.addSubview(tipView)
        tipView.tag = ToastTag
        
        rect = tipView.frame
        rect.origin.x = (view.width - rect.width) / 2
        rect.origin.y = (view.height - rect.height) / 2
        tipView.frame = rect
        
        tipView.transform = CGAffineTransform.init(scaleX: 0.2, y: 0.2)
        UIView.animate(withDuration: 0.2, animations: {
            tipView.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            tipView.alpha = 1
        })
 
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            UIView.animate(withDuration: 0.2, animations: {
                tipView.transform = CGAffineTransform.init(scaleX: 0.2, y: 0.2)
                tipView.alpha = 0
            }) { (finished) in
                tipView.removeFromSuperview()
            }
        }
    }
}

//
//  ZGRemindCircleViewq.swift
//  Pods
//
//  Created by zhaogang on 2017/8/25.
//
//

import UIKit

class ZGRemindCircleView: UIView {
    weak var imageView:ZGImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let view1 = ZGImageView(frame: CGRect.init(x: 0, y: 0, width: 60, height: 60))
        self.addSubview(view1)
        self.imageView = view1
        
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var rect = self.imageView.frame
        rect.origin.x = (self.width - rect.width) / 2
        rect.origin.y = 15
        self.imageView.frame = rect
        
    }
}

//
//  ZGRemindNoTitleAlert.swift
//  Pods
//
//  Created by zhaogang on 2017/8/25.
//
//

import UIKit

class ZGRemindNoTitleAlert: ZGNormalNoTitleAlert {

    weak var circleView:ZGRemindCircleView!
    
    
    func addCircleView() -> ZGRemindCircleView {
        let cWidth:CGFloat = 120
        let cView = ZGRemindCircleView(frame:CGRect.init(x: 0, y: 0, width: cWidth, height: cWidth))
        self.insertSubview(cView, belowSubview: self.contentLabel)
        cView.layer.cornerRadius = cWidth / 2
        return cView
    }
    
    override func setItem(_ item: ZGAlertItem) {
        super.setItem(item)
        
        if self.circleView == nil{
            self.circleView = self.addCircleView()
        }
        self.contentVerticalMargin = 35
        
        self.circleView.imageView.urlPath = item.remindIcon
        self.layoutSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard (self.circleView) != nil else {
            return
        }
        var rect = self.circleView.frame
        rect.origin.x = (self.width - rect.width) / 2
        rect.origin.y = -(rect.height/2) + 10
        self.circleView.frame = rect
    }

}

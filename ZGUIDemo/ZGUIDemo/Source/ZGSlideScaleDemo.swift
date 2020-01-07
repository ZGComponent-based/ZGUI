//
//  ZGSlideScaleDemo.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/12/20.
//  Copyright © 2017年 zhaogang. All rights reserved.
//

import UIKit
import ZGUI

class ZGSlideScaleDemo: ZGBaseViewCTL {
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addNavigatorBar(leftImage: ZGDemoUtil.gobackBtnImagePath(), title: "图片横滑缩放")
        self.view.backgroundColor = UIColor.white
        
        var rect = self.view.bounds
        rect.origin.y = 100
        
        let imageSize = CGSize.init(width: 960, height: 600)
        let width:CGFloat = UIScreen.main.bounds.width / 2
        var height:CGFloat = width*imageSize.height/imageSize.width
        height = round(height)
        let size = CGSize.init(width: width, height: height)
        
        let imageArr = ["http://i1.umei.cc/uploads/tu/201608/971/hslnx0yhqph.jpg",
                        "http://i1.umei.cc/uploads/tu/201608/971/31luf0i5uv4.jpg",
                        "http://i1.umei.cc/uploads/tu/201608/971/dchyzzmkdff.jpg",
                        "http://i1.umei.cc/uploads/tu/201608/971/ykbybkzdb3j.jpg",
                        "http://i1.umei.cc/uploads/tu/201608/971/iqa3xnjidnm.jpg",
                        "http://i1.umei.cc/uploads/tu/201608/971/mwxviyyud5j.jpg",
                        "http://i1.umei.cc/uploads/tu/201608/971/c1jpp5ygxl4.jpg"
                        ]
        var items = [ZGSlideScaleItem]()
        for imageUrl in imageArr {
            let item1 = ZGSlideScaleItem(imageUrl: imageUrl, size: size)
            items.append(item1)
        }
        
        rect.size.height = size.height + 40
        
        let centereDistanceTrigger:CGFloat = 160
        let scaleFactor:CGFloat = 0.15
        let attibuteAlpha:CGFloat = 0.5
        let itemSpacing:CGFloat = ceil(size.width * scaleFactor) / 2 + 15
        
        let slideView = ZGSlideScaleView.show(
            inView: self.view,
            frame: rect,
            centerDistanceTrigger: centereDistanceTrigger,
            scaleFactor: scaleFactor,
            attributeAlpha: attibuteAlpha,
            itemSpacing: itemSpacing)
        slideView.setViewItems(items)
    }
}

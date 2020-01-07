//
//  ZGUICycleDemoVCL.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/6/7.
//
import ZGUI
import UIKit

class ZGUICycleDemoVCL: ZGBaseViewCTL {
    
    func addCardsView() {
        let text2 = "<font size='9' color='ffffff'>户外运动</font>"
        let text3 = ZGUILabelStyle.attributedStringOfHtmlText(text2)
        
        let item1 = ZGCardItem()
        item1.nextBgImageUrl = "bundle://banner_next_tip_back@2x.png"
        item1.title = text3
        item1.imageUrl = "http://z3.tuanimg.com/imagev2/wxyy/750x286.7f638da9e1b41eddfa128e260225aab8.jpg"
        
        let item2 = ZGCardItem()
        item2.nextBgImageUrl = "bundle://banner_next_tip_back@2x.png"
        item2.title = text3
        item2.imageUrl = "http://z3.tuanimg.com/imagev2/wxyy/750x286.6d68ca1cc7c844b3f15194b88b5f8f94.jpg"
        
        let item3 = ZGCardItem()
        item3.nextBgImageUrl = "bundle://banner_next_tip_back@2x.png"
        item3.title = text3
        item3.imageUrl = "http://z2.tuanimg.com/imagev2/wxyy/750x286.b40f66c83e1efad320c7bbffdfa69547.jpg"
        
        let items = [item1, item2, item3]
        
        var frame = self.view.bounds
        frame.size.height = 143
        frame.origin.y = 64
        let cardView1 = ZGCardsView(frame: frame, pageControlStyle:.right)
        self.view.addSubview(cardView1)
        cardView1.backgroundColor = UIColor.lightGray
        cardView1.setCards(items)
        
        var frame2 = frame
        frame2.origin.y = frame.origin.y + frame.size.height + 20
        let cardView2 = ZGCardsView(frame: frame2, pageControlStyle:.center)
        self.view.addSubview(cardView2)
        cardView2.backgroundColor = UIColor.lightGray
        cardView2.setCards(items)
        
        cardView2.tapHandler = {(item) in
            print("\(item.imageUrl)")
        }
        cardView1.tapHandler = {(item) in
            print("\(item.imageUrl)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        let navigatorView = self.createNavigator()
        navigatorView.navigatorItem.title = "循环滚动"
        
        self.view.addSubview(navigatorView)
        
        self.addCardsView()
        
    }
 
    
}

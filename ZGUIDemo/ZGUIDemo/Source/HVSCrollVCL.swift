//
//  HVSCrollVCL.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2018/7/26.
//  Copyright © 2018年 zhaogang. All rights reserved.
//

import UIKit
import ZGUI

class HVSCrollVCL: ZGUIScrollPageV2VCL<ZGUIDemoHomeVCL2> {
    
    func wrapperItems() {
        let arr = ["男装","数码家电","文娱运动","鞋品",
                   "美食","居家","女装","配饰",
                   "内衣","美妆","儿童","箱包",
                   "家纺","母婴","中老年"]
        let normalColor = UIColor.color(withHex: 0x2b2929)
        let selectColor = UIColor.color(withHex: 0xef4545)
        
        
        var mArr:[ZGTopScrollBarBaseItem] = []
        for str in arr {
            let item = ZGTopScrollBarItem()
            item.text = str
            item.selectedTextColor = selectColor
            item.normalTextColor = normalColor
            item.pageReuseIdentifier = "CAT";
            item.lineWidth = 30
            item.selectedLineColor = UIColor.red;
            let width = str.textSize(attributes: [.font:UIFont.systemFont(ofSize: 15)]).width
            item.size = CGSize.init(width: width+18, height: self.getTopScrollBarHeight())
            mArr.append(item)
        }
        
        let ds = ZGTopScrollBarDataSource.init(items: mArr, stickItem: nil, dropDownFootView: nil)
        let dropDownText = NSAttributedString.init(string: "   选择分类", attributes: [NSAttributedString.Key.foregroundColor:UIColor.color(withHex: 0x595858),NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15)])
        ds.isNeedDropDown = true
        ds.dropDownText = dropDownText
        self.dataSource = ds
    }
    
    override func getPageTopMargin() -> CGFloat {
//        return ZGUIUtil.statusBarHeight() + 44
        return 0
    }
    
    //override
    override func getPageView(atIndex index: Int) -> ZGUIDemoHomeVCL2? {
        let obj = self.getObject(at: index)
        guard let item = obj else {
            return nil
        }
        
        var pageView = self.paginationView.paginationScrollView.dequeueReusablePageView(withIdentifier: item.pageReuseIdentifier)
        if pageView == nil {
            pageView = ZGUIDemoHomeVCL2()
            self.addChild(pageView!)
        }
        pageView!.setParameters(nil)
        return pageView
    } 

    override func getHeaderHeight() -> CGFloat {
        return 120
    }

    override func getTopScrollBarHeight() -> CGFloat {
        return 40
    }
    
    override func getCurrentScrollView() -> UIScrollView? {
        return self.currentPage?.collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.wrapperItems()
    }
}

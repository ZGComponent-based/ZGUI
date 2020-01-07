//
//  ZGUIDemoPageScrollVCL.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/4/6.
//
//

import UIKit
import ZGUI

class ZGUIDemoPageScrollVCL: ZGUIScrollPageVCL<ZGUIDemoPageSubVCL> {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        self.wrapperItems()
    }
    
    override func layoutTopScrollBar() {
        self.topScrollBar.top = 20
    }
    
    override func getPageView(atIndex index:Int) -> ZGUIDemoPageSubVCL? {
        let obj = self.getObject(at: index)
        guard let item = obj else {
            return nil
        }
        
        var pageView = self.pagingScrollView.dequeueReusablePageView(withIdentifier: item.pageReuseIdentifier)
        if pageView == nil {
            pageView = ZGUIDemoPageSubVCL()
            self.addChild(pageView!)
        }
        pageView!.setParameters(nil)
        return pageView
    }
    
    override func didShow(pageView: ZGUIDemoPageSubVCL) {
        super.didShow(pageView: pageView)
        //do something
    }
    
    
    func wrapperItems() {
        let arr = ["男装","数码家电","文娱运动","鞋品",
                   "美食","居家","女装","配饰",
                   "内衣","美妆","儿童","箱包",
                   "家纺","母婴","中老年"]
        let normalColor = UIColor.color(withHex: 0x2b2929)
        let selectColor = UIColor.color(withHex: 0xef4545)
        
        
        var mArr:[ZGTopScrollBarBaseItem] = []
        for str in arr {
            let item = ZGUIDemoPageSubTextItem()
            item.text = str
            item.selectedTextColor = selectColor
            item.normalTextColor = normalColor
            item.pageReuseIdentifier = "CAT";
            
            let width = str.textSize(attributes: [.font:UIFont.systemFont(ofSize: 15)]).width
            item.size = CGSize.init(width: width+18, height: self.kTopScrollBarHeight)
            mArr.append(item)
        }
        
        let ds = ZGTopScrollBarDataSource.init(items: mArr, stickItem: nil, dropDownFootView: nil)
        let dropDownText = NSAttributedString.init(string: "   选择分类", attributes: [NSAttributedString.Key.foregroundColor:UIColor.color(withHex: 0x595858),NSAttributedString.Key.font:UIFont.systemFont(ofSize: 15)])
        ds.isNeedDropDown = true
        ds.dropDownText = dropDownText
        self.dataSource = ds
    }
    
    
}
//
//    {//gif图片cell
//        NSURL *imageUrl = [[NSBundle mainBundle] URLForResource:@"2" withExtension:@"gif"]
//        NSData *data = [NSData dataWithContentsOfURL:imageUrl]
//        NSURL *imageUrl2 = [[NSBundle mainBundle] URLForResource:@"1" withExtension:@"gif"]
//        NSData *data2 = [NSData dataWithContentsOfURL:imageUrl2]
//        
//        Tao800ScrollTagImageItem *item = [[Tao800ScrollTagImageItem alloc] init]
//        item.imageData = data
//        item.imageSelectData = data2
//        item.horizontalPadding = 9
//        item.itemSize = CGSizeMake(55+item.horizontalPadding*2, kTao800ScrollPageBarHeight)
//        [marr insertObject:item atIndex:3]
//    }
//    self.dataItems = [NSArray arrayWithArray:marr]
//    
//    {//悬浮 普通 section
//        Tao800ScrollTagTextItem *item = [[Tao800ScrollTagTextItem alloc] init]
//        item.text = @"推荐"
//        item.selectedTextColor = selectColor
//        item.normalTextColor = normalColor
//        CGFloat width = [item.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
//        options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
//        attributes:@{NSFontAttributeName:TSFont26()}
//        context:nil].size.width
//        width = ceil(width)
//        item.itemSize = CGSizeMake(width+18, kTao800ScrollPageBarHeight)
//        self.stickItem = item
//    }
//}


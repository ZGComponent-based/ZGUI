//
//  PreviewDemoVCL.swift
//
//  Created by zhaogang on 2017/7/12.
//

import UIKit
import ZGUI

class PreviewDemoVCL: ZGBaseViewCTL {
    weak var preview:ZGImagePreviewBox?
    
    func previewItems() -> [ZGImagePreviewItem] {
        let item1 = ZGImagePreviewItem(imageUrl:"bundle://s1.jpg")
        let item2 = ZGImagePreviewItem(imageUrl:"bundle://s2.jpeg")
        let item3 = ZGImagePreviewItem(imageUrl:"bundle://s3.jpeg")
        let item4 = ZGImagePreviewItem(imageUrl:"bundle://s4.jpeg")
        let item5 = ZGImagePreviewItem(imageUrl:"bundle://s5.jpeg")
        
        return [item1, item2, item3, item4, item5]
    }
    
    func showScreenPreview(itemView:ZGImagePreviewItemView) {
        guard let preview = self.preview else {
            return
        }
        ZGImagePreviewManager.showPreview(itemView: itemView, previewBox: preview, blur: false)
    }
    
    func addPreview() {
        let items = self.previewItems()
        for item in items {
//            item.enableSavePhoto = true
//            item.enableScale = true
            item.isFlatPattern = true
        }
        
        let pullingText = "滑动查看图文详情"
        let triggerText = "释放查看图文详情"
        let arrowImageUrl = "bundle://bzmd_header_refresh@2x.png"
        let total = items.count
        let height:CGFloat = 160
        let width:CGFloat = 260
        
        let extItem = ZGImagePreviewExtensionItem()
        
        let pullingItem = ZGImagePreviewPullingItem(arrowImageUrl: arrowImageUrl, pullingText: pullingText, triggerText: triggerText)
        pullingItem.fontSize = 12
        pullingItem.textColor = UIColor.darkGray
        pullingItem.handler = {
            print("pullingItem call back...")
        }
        
        extItem.pullingItem = pullingItem
         
        
        let bItem = ZGImagePreviewPageControlItem(frame:CGRect.init(x: 0, y: height-20, width: width, height: 20), total: total)
        extItem.bottomItem = bItem
        bItem.pageIndicatorTintColor = UIColor.white
        bItem.currentPageIndicatorTintColor = UIColor.red
        
        
        let pFrame = CGRect.init(x: 40, y: self.zbNavigatorView!.height, width: width, height: height)
        self.preview = ZGImagePreviewManager.show(inView: self.view,
                                     items:items,
                                     extensionItem: extItem,
                                     frame:pFrame,
                                     backgroundColor: UIColor.lightGray,
                                     tapHandler: { [weak self](itemView) in
               self?.showScreenPreview(itemView:itemView)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        let navigatorView = self.createNavigator()
        navigatorView.navigatorItem.title = "图片预览"
        self.view.addSubview(navigatorView)
        self.zbNavigatorView = navigatorView
        
        self.addPreview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//
//  ZGAlbumPreviewVCL.swift
//  ZGUI
//  ZGImagePreviewBox
//  Created by zhaogang on 2017/11/4.
//

import UIKit

class ZGAlbumPreviewVCL: ZGBaseViewCTL {
    @objc func handleBtn(_ sender:Any) {
        
    }
    
    func resetNavigatorRightBtn() {
        guard let navigatorView = self.zbNavigatorView else {
            return
        }
        let btnItem = UIBarButtonItem.init(title: "取消", style: .plain, target: self, action: #selector(self.handleBtn(_:)))
        btnItem.width = 40
        navigatorView.rightPadding = 10
        navigatorView.buttonFont = UIFont.systemFont(ofSize: 16)
        navigatorView.titleColor = UIColor.white
        navigatorView.navigatorItem.rightBarButtonItem = btnItem
    }
    
    func resetNavigatorStyle() {
        guard let navigatorView = self.zbNavigatorView else {
            return
        }
        
        navigatorView.backgroundColor = UIColor.clear
        navigatorView.bottomLine?.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backImage = ZGUIUtil.bundleForImage("goback_btn.png")
        self.addNavigatorBar(leftImage:backImage, title: "")
        self.resetNavigatorStyle()
        self.resetNavigatorRightBtn()
        
        self.view.backgroundColor = UIColor.black
        self.model = ZGAlbumPreviewModel()
        self.loadItems()
    }
    
    func loadItems() {
        self.model?.loadItems(self.paramDict, completion: {[weak self] (params) in
            
            self?.reloadData()
            }, failure: { [weak self](err) in
                
        })
    }
    
    override func reloadData(){
        guard let items = self.model.items as? [ZGImagePreviewItem] else {
            return
        }
        if items.count < 1 {
            return
        }
        var index = 0
//        if let selectedItem = 
        ZGImagePreviewManager.showPreview(itemView: nil, pItems: items, imageIndex: 0, inView:self.view)
        if let navigatorView = self.zbNavigatorView {
            self.view.bringSubviewToFront(navigatorView)
        }
    }
}

//
//  PageTipDemoVCL.swift
//
//  Created by zhaogang on 2017/8/8.
//

import UIKit
import ZGUI

class PageTipDemoVCL: ZGBaseViewCTL {
    override func getLoadingFrame() -> CGRect {
        var rect = self.view.bounds
        rect.origin.y = self.zbNavigatorView!.height
        rect.size.height -= rect.origin.y
        return rect
    }
    
    @objc func btnAction(_ sender:UIButton)  {
        self.showPageTip(title:"网络连接错误", imageBundle:"bundle://network_error.png")
    }
    
    @objc func btn2Action(_ sender:UIButton)  {
        self.hidePageTip()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        let navigatorView = self.createNavigator()
        navigatorView.navigatorItem.title = "页面提示"
        self.view.addSubview(navigatorView)
        self.zbNavigatorView = navigatorView
        
        
        let button = UIButton(type: .custom)
        button.frame = CGRect.init(x: 30, y: ZGUIUtil.statusBarHeight() + 10, width: 60, height: 25)
        button.setTitle("图片", for: .normal)
        self.view.addSubview(button)
        button.backgroundColor = UIColor.orange
        button.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
        
        let button2 = UIButton(type: .custom)
        button2.frame = CGRect.init(x: self.view.width-80-10, y: ZGUIUtil.statusBarHeight() + 10, width: 80, height: 30)
        button2.setTitle("隐藏加载", for: .normal)
        self.view.addSubview(button2)
        button2.backgroundColor = UIColor.orange
        button2.addTarget(self, action: #selector(btn2Action(_:)), for: .touchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

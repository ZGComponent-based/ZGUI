//
//  ToastDemoVCL.swift
//
//  Created by zhaogang on 2017/8/8.
//

import UIKit
import ZGUI

class ToastDemoVCL: ZGBaseViewCTL {

    @objc func btnAction(_ sender:UIButton)  {
        self.showTextTip("简单提示")
    }
    
    @objc func btn2Action(_ sender:UIButton)  {
        self.showTextTip("长一点的文字提示，多个文字,再加几个文字")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        let navigatorView = self.createNavigator()
        navigatorView.navigatorItem.title = "Toas提示"
        self.view.addSubview(navigatorView)
        self.zbNavigatorView = navigatorView
        
        
        let button = UIButton(type: .custom)
        button.frame = CGRect.init(x: 30, y: ZGUIUtil.statusBarHeight() + 10, width: 80, height: 25)
        button.setTitle("toast1", for: .normal)
        self.view.addSubview(button)
        button.backgroundColor = UIColor.orange
        button.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
        
        let button2 = UIButton(type: .custom)
        button2.frame = CGRect.init(x: self.view.width-80-10, y: ZGUIUtil.statusBarHeight() + 10, width: 80, height: 30)
        button2.setTitle("toast2", for: .normal)
        self.view.addSubview(button2)
        button2.backgroundColor = UIColor.orange
        button2.addTarget(self, action: #selector(btn2Action(_:)), for: .touchUpInside)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

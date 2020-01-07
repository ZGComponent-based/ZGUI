//
//  QRCodeDemoVCL.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/11/6.
//  Copyright © 2017年 zhaogang. All rights reserved.
//

import UIKit
import ZGUI

class QRCodeDemoVCL: ZGBaseViewCTL , UITextFieldDelegate {
    lazy var textField: UITextField = {
        let field = UITextField()
        self.view.addSubview(field)
        field.layer.borderWidth = 0.5
        field.layer.borderColor = UIColor.color(withHex: 0xDBDBDB).cgColor
        field.layer.cornerRadius = 5
        field.layer.masksToBounds = true
        field.delegate = self
        return field
    }()
    
    lazy var imageView: ZGImageView = {
        let image = ZGImageView()
        self.view.addSubview(image)
        image.backgroundColor = UIColor.color(withHex: 0xeeeeee)
        return image
    }()
    
    @objc func btnAction(_ sender:UIButton)  {
        guard let text = self.textField.text else {return}
        
        self.imageView.defaultImage = text.qrImage(targetSize: self.imageView.width)
 
        
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        let backImage = "bundle://ZGUI/goback_btn.png"
        self.addNavigatorBar(leftImage: backImage, title: "二维码测试");
        
        self.view.backgroundColor = UIColor.white
        
        let btnWidth:CGFloat = 60
        let fildWidth:CGFloat = 220
        let pading:CGFloat = 10
        let centerWidth:CGFloat = btnWidth + fildWidth + pading
        
        var fildRect = self.textField.frame
        fildRect.size.width = fildWidth
        fildRect.origin.x = (self.view.width - centerWidth) / 2
        fildRect.origin.y = ZGUIUtil.statusBarHeight() + 44 + 30
        fildRect.size.height = 35
        self.textField.frame = fildRect
        
        self.textField.text = "http://www.baidu.com"
        
        let button = UIButton(type: .custom)
        button.frame = CGRect.init(x: fildRect.origin.x + fildRect.width + 10, y: fildRect.origin.y, width: btnWidth, height: 35)
        button.setTitle("生成", for: .normal)
        self.view.addSubview(button)
        button.backgroundColor = UIColor.orange
        button.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
        
        var imageFrame = self.imageView.frame
        imageFrame.size.width = 240
        imageFrame.size.height = 240
        imageFrame.origin.x = (self.view.width - imageFrame.width) / 2
        imageFrame.origin.y = fildRect.origin.y + fildRect.height + 30
        self.imageView.frame = imageFrame
        
        let view2 = ZGImageView()
        self.imageView.addSubview(view2)
        let width :CGFloat = floor(imageFrame.width/4)
        view2.frame = CGRect.init(x: (imageFrame.width-width)/2, y: (imageFrame.height-width)/2, width: width, height: width)
        view2.backgroundColor = UIColor.clear
        view2.urlPath = "bundle://timg.jpeg"
//        view2.imageLayer().backgroundColor = UIColor.purple.cgColor
//        view2.imageLayer().cornerRadius = 25
//        view2.imageLayer().masksToBounds = true
        
        view2.layer.borderColor = UIColor.white.cgColor
        view2.layer.borderWidth = 3
        view2.layer.cornerRadius = view2.width/4
        view2.layer.masksToBounds = true
        
//        view2.layer.shadowColor = UIColor.black.cgColor
//        view2.layer.shadowOpacity = 0.8
//        view2.layer.shadowRadius = 5
//        view2.layer.shadowOffset = .zero
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

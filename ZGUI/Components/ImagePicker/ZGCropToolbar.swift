//
//  CropToolbar.swift
//  ZGCamera
//
//  Created by zhaogang on 2018/3/31.
//  Copyright © 2018年 zhaogang. All rights reserved.
//

import UIKit

class ZGCropToolbar: UIView {
    
    fileprivate var cancelBtn:UIButton?
    fileprivate var resetBtn:UIButton?
    fileprivate var completeBtn:UIButton?
    
    var completeButtonTapped : (() -> Void)?
    var resetButtonTapped :  (()-> Void)?
    var cancel :(()->Void)?
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let color = UIColor.white
        color.set()
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: main_screen_w, y: 0))
        
        path.lineWidth = 0.5
        path.lineCapStyle = .butt //线条拐角
        path.lineJoinStyle = .round //终点处理
        path.stroke()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init error")
    }
}


extension ZGCropToolbar{
    
    //设置UI
    private func setupUI()  {
        self.backgroundColor = UIColor.clear
        cancelBtn = UIButton(frame: CGRect(x: 10, y: 5, width: 40, height: 40))
        cancelBtn?.setTitle("取消", for: .normal)
        cancelBtn?.setTitleColor(UIColor.white, for: .normal)
        cancelBtn?.addTarget(self, action: #selector(cancelClick), for: .touchUpInside)
        
        
        resetBtn  = UIButton(frame: CGRect(x: main_screen_w / 2 - 20, y: 5, width: 40, height: 40))
        resetBtn?.setTitleColor(UIColor.white, for: .normal)
        resetBtn?.setTitle("还原", for: .normal)
        resetBtn?.addTarget(self, action: #selector(resetClick), for: .touchUpInside)
        
        completeBtn = UIButton(frame: CGRect(x: main_screen_w - 60, y: 5, width: 40, height: 40))
        completeBtn?.setTitleColor(UIColor.white, for: .normal)
        completeBtn?.setTitle("完成", for: .normal)
        completeBtn?.addTarget(self, action: #selector(completeClick), for: .touchUpInside)
        if let cancelBtn = cancelBtn{
            self.addSubview(cancelBtn)
        }
        if let resetBtn = resetBtn{
            self.addSubview(resetBtn)
        }
        if let completeBtn = completeBtn{
            self.addSubview(completeBtn)
        }
        
    }
    
    
    @objc private  func cancelClick() {
        if let block  = self.cancel {
            block()
        }
        
    }
    
    @objc private func resetClick(){
        if let block  = self.resetButtonTapped {
            block()
        }
    }
    
    @objc private func completeClick(){
        if let block  = self.completeButtonTapped {
            block()
        }
    }
    
}

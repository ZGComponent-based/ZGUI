//
//  ZGCropViewController.swift
//  ZGCamera
//
//  Created by zhaogang on 2018/3/31.
//  Copyright © 2018年 zhaogang. All rights reserved.
//

import UIKit
import ZGUI

protocol RotateViewDelegate {
    func rotateScrollView()
    
}

public class ZGCropViewController: ZGBaseViewCTL, UIViewControllerTransitioningDelegate {
    
    var delegate : YHDCropViewDelegate?
    
    public  var callBack  : ((UIImage)->Void)?
    
    
    
    let toolbar = ZGCropToolbar(frame: CGRect(x:0 , y: main_screen_h - 50, width: main_screen_w, height: 50))
    fileprivate let image:UIImage?
    
    lazy var cropView: ZGCorpsView = {
        let view = ZGCorpsView(frame: CGRect.zero)
        view.image = self.image
        return view
    }()
    
    fileprivate  lazy var rotateBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: 30, y: main_screen_h - 120, width: 40, height: 50))
        
        btn.setImage(ZGUIUtil.bundleForImage("rotate.png"), placeholderImage: nil, for: .normal)
        
        btn.addTarget(self, action: #selector(rotateBtnClick), for: .touchUpInside)
        return  btn
    }()
    
    
    let transitionController = CropViewControllerTransitioning()
    
    public init(_ coder:NSCoder? = nil,image:UIImage ) {
        self.image = image
        
        if let coder = coder {
            super.init(coder: coder)!
        }else{
            super.init(nibName: nil, bundle: nil)
        }
        
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .fullScreen
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        //1.初始化UI
        setupUI()
        
    }
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
}


extension ZGCropViewController{
    
    private func setupUI()  {
        view.backgroundColor = UIColor.black
        view.addSubview(rotateBtn)
        //self.cropView.delegate = self
        //1.设置toolbar
        setToolBar()
        
        self.cropView.frame = CGRect(origin:CGPoint(x: 0, y: 0) , size: UIScreen.main.bounds.size)
        
        view.insertSubview(self.cropView, at: 0)
        
    }
    
    private func setToolBar(){
        
        let toolbar  = ZGCropToolbar(frame : CGRect(x: 0, y: main_screen_h - 50, width: main_screen_w, height: 50))
        toolbar.cancel = { [weak self] in
            self?.modalTransitionStyle = .coverVertical
            self?.dismiss(animated: true, completion: nil)
        }
        
        toolbar.completeButtonTapped = {[weak self] in
            
            
            let image = self?.cropView.croppedImage
            
            if self?.callBack != nil {
                guard let image = image else{
                    return
                }
                self?.callBack?(image)
                
            }
            
        }
        
        toolbar.resetButtonTapped = { [weak self] in
            self?.cropView.resetScrollView()
        }
        
        
        view.insertSubview(toolbar, at: 1)
    }
    
    
    @objc private func rotateBtnClick()  {
        self.cropView.rotateScrollView()
    }
}














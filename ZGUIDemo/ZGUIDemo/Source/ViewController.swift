//
//  ViewController.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/3/16.
//
//

import UIKit
import ZGNetwork
import ZGUI

class ViewController: ZGBaseViewCTL, ZGImageViewDelegate {
 
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: ZGImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        let navigatorView = self.createNavigator()
        navigatorView.navigatorItem.title = "图片组件"
        self.view.addSubview(navigatorView)
        self.imageView.delegate = self
        
        let img:UIImage? = UIImage.init(named: "111.jpg")
        self.imageView.defaultImage = img
        
        button.setBackgroundImage("http://pic.qiantucdn.com/58pic/13/82/28/06D58PICCbh_1024.jpg", placeholderImage:nil, for: .normal)
        button.setBackgroundImage("http://pic36.nipic.com/20131225/11624852_094715556000_2.png", placeholderImage:nil, for: .highlighted)
         
    }
 
    
    func edit() {
        print("start edit")
    }
    
    func goBack() {
        print("goBack Action")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
   
        
        self.imageView.urlPath = "http://z11.tuanimg.com/imagev2/trade/800x800.94b2e8465d0eba0f6411bc7349ee49a2.380x380.jpg.webp"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: -
    func didLoadImage(_ imageView:ZGImageView, imageUrl : String) {
        print("didLoadImage")
    }
    
    func didFailLoad(_ imageView:ZGImageView, imageUrl : String, error:ZGNetworkError){
        print("didFailLoad")
    }
    
    func willLoadImage(_ imageView:ZGImageView, imageUrl : String) {
        print("willLoadImage")
    }
}


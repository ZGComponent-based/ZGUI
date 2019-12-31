//
//  ZGTabbarButton.swift
//  ZGUIDemo
//
//  Created by bruce on 2017/3/15.
//
//

import UIKit

class ZGTabbarButton: UIView {
    
    /// 是否被选中，默认是false，非选中
    open  var isSelected: Bool = false{
        willSet{
            repeatRenderTabBarItem(newValue)
        }
    }
    
    
    var barItem:ZGTabbarItem?{
        didSet{
            repeatRenderTabBarItem((barItem?.isSelected)!)
        }
    }

    init(_ barItem:ZGTabbarItem?){
        self.barItem = barItem;
        isSelected = false
        let frame:CGRect = CGRect(x:0,y:0,width:49,height:49)
        super.init(frame:frame)
        renderTabbarItem()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 渲染button
   private func renderTabbarItem() -> Void {
        if let item = self.barItem {
            self.addSubview(self.imageView)
            self.addSubview(self.titleLabel)
            repeatRenderTabBarItem(item.isSelected)
        }
    }
    
    private func repeatRenderTabBarItem(_ isSelected:Bool){
        guard let item = self.barItem else {
            return
        }
        if isSelected {
            self.imageView.image = item.selectedImage
            self.titleLabel.text = item.selectedTitle
        }else{
            self.imageView.image = item.defaultImage
            self.titleLabel.text = item.defaultTitle
        }
    }
    
    /// 懒加载UIImageView
   private lazy var imageView:UIImageView = {
        var imageView:UIImageView = UIImageView()
        imageView.frame = CGRect(x:10,y:5,width:29,height:29)
        imageView.backgroundColor = UIColor.clear
        return imageView
    }()
    
    
    /// 懒加载title标题
    private lazy var titleLabel: UILabel = {
        var titleLabel:UILabel = UILabel()
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.frame = CGRect(x:0, y:35, width:self.frame.width, height:15)
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.textColor = UIColor.white
        return titleLabel
    }()
    
    
    ///布局视图
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = CGRect(x:10,y:5,width:29,height:29)
        self.titleLabel.frame = CGRect(x:0, y:35, width:self.frame.width, height:15)
    }
}

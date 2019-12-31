//
//  ZGTabbarItem.swift
//  ZGUIDemo
//
//  Created by bruce on 2017/3/15.
//
//

import UIKit

public class ZGTabbarItem: NSObject {
    
    /// 非选中时的照片链接
    public var defaultImageURL:String? = nil
    
    /// 选中时的照片链接
    public var selectedImageURL:String? = nil
    
    /// 非选中时的照片
    public var defaultImage:UIImage? = nil
    
    /// 选中时的照片
    public var selectedImage:UIImage? = nil
    
    /// 非选中时显示的title
    public var defaultTitle:String? = nil
    
    /// 选中时的显示的title
    public var selectedTitle:String? = nil
    
    /// 是否是处在选中状态，默认是false，非选中状态
    public var isSelected:Bool = false
    
    /// 单次点击事件
    public var singleClickAction:((Int)->Void)? = nil
    
    /// 两次点击事件
    public var doubleClickAction:((Int)->Void)? = nil
    
}

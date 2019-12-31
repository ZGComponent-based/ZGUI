//
//  ZGAlertItem.swift
//  Pods
//
//  Created by zhaogang on 2017/8/25.
//
//

import UIKit

public class ZGAlertButtonItem: ZGBaseUIItem {
    public var buttonTitle:String?
    public var titleColor:UIColor?
    public var backgroundColor:UIColor?
    public var backgroundHighlightColor:UIColor?
}

public class ZGAlertItem: ZGBaseUIItem {
    public var title:String?
    public var content:String?
    public var buttonItems:[ZGAlertButtonItem]?
    public var remindIcon:String?
    
    public var titleFont:UIFont?
    public var contentFont:UIFont? 
  
}

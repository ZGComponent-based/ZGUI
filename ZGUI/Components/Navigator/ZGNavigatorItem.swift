//
//  ZGNavigatorItem.swift
//  ZGUIDemo
//
//  Created by yangjing on 2017/3/22.
//
//

import Foundation
import UIKit

open class ZGNavigatorItem:NSObject{
    
    @objc dynamic public var leftBarButtonItems = [UIBarButtonItem]()
    @objc dynamic public var rightBarButtonItems = [UIBarButtonItem]()
    @objc dynamic public var title: String?
    @objc dynamic public var titleView: UIView?
    @objc dynamic public var leftBarButtonItem: UIBarButtonItem?
    @objc dynamic public var rightBarButtonItem: UIBarButtonItem?
    
    public func allProperties() ->[String] {
        // 这个类型可以使用CUnsignedInt,对应Swift中的UInt32
        var count: UInt32 = 0
        
        let properties = class_copyPropertyList(ZGNavigatorItem.self, &count)
        
        var propertyNames: [String] = []
        
        // Swift中类型是严格检查的，必须转换成同一类型
        for i in 0 ..< Int(count) {
            // UnsafeMutablePointer<objc_property_t>是
            // 可变指针，因此properties就是类似数组一样，可以
            // 通过下标获取
            if let property = properties?[i] {
                let name = property_getName(property)
                
                // 这里还得转换成字符串
                let strName = String.init(cString: name)
                propertyNames.append(strName);
            }
        }
        
        // 不要忘记释放内存，否则C语言的指针很容易成野指针的
        free(properties)
        
        return propertyNames;
    }

}

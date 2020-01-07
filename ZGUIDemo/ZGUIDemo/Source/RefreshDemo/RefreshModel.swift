//
//  RefreshModel.swift
//  ZGUIDemo
//
//  Created by LeAustinHan on 2017/4/20.
//
//

import UIKit
import ZGUI

class RefreshModel: ZGModel {
    func rootItems() ->[RefreshItem]  {
        var items = [RefreshItem]()
        
        let width = (UIScreen.main.bounds.width-10)
        let size = CGSize.init(width: width, height: 80)
        
        let tempItem01 = RefreshItem.init(size: size)
        tempItem01.title = "item01"
        
        let tempItem02 = RefreshItem.init(size: size)
        tempItem02.title = "item02"
        
        let tempItem03 = RefreshItem.init(size: size)
        tempItem03.title = "item03"
        
        let tempItem04 = RefreshItem.init(size: size)
        tempItem04.title = "item04"
        
        let tempItem05 = RefreshItem.init(size: size)
        tempItem05.title = "item05"
        
        let tempItem06 = RefreshItem.init(size: size)
        tempItem06.title = "item06"
        
        let tempItem07 = RefreshItem.init(size: size)
        tempItem07.title = "item07"
        
        let tempItem08 = RefreshItem.init(size: size)
        tempItem08.title = "item08"
        
        items.append(tempItem01)
        items.append(tempItem02)
        items.append(tempItem03)
        items.append(tempItem04)
        
        items.append(tempItem05)
        items.append(tempItem06)
        items.append(tempItem07)
        items.append(tempItem08)
        
        return items
    }

}

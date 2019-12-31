//
//  ZGUIViewExtension.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/3/31.
//
//

import UIKit

public extension UIDevice {
    func isX() -> Bool {
        if UIScreen.main.bounds.height == 812 {
            return true
        }
        return false
    }
}


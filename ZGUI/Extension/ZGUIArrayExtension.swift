//
//  ZGUIArrayExtension.swift
//  Pods
//
//  Created by zhaogang on 2017/8/31.
//
//

import UIKit

public extension Array{
    func randomElement() -> Element?{
        if self.isEmpty{
            return nil
        }
        let index: Int = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}

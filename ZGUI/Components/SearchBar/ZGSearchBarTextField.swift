//
//  ZGSearchBarTextField.swift
//  Pods
//
//  Created by lijiaqi on 2017/4/10.
//
//

import UIKit

open class ZGSearchBarTextField: UITextField {

    var baColor: UIColor?
    
    open override func draw(_ rect: CGRect) {
        self.backgroundColor?.set()
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 4)
        path.stroke()
        path.fill()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
}

//
//  ZGUIDemoPageSubVCL.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/4/6.
//
//

import UIKit
import ZGUI

class ZGUIDemoPageSubVCL: ZGBaseViewCTL {

    var label: UILabel!
    private var _item: Any!
    
    
    deinit {
        print("release \(self)")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.red
        self.label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 300, height: 400))
        self.label.backgroundColor = UIColor.orange
        self.label.center = self.view.boundsCenter
        self.label.textAlignment = .center
        self.view.addSubview(self.label)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    //MARK: - ZGHPaginationSubViewDelegate
 
    override func getView() -> UIView {
        return self.view
    }
    
    override func setObject(_ object: Any) {
        _item = object;
        guard let item = object as? ZGUIDemoPageSubTextItem else {
            return
        }
        label.text = item.text
    }
    
    override func prepareForReuse() {
        self.removeFromParent()
    }
    
    override func reuseIdentifier() -> String {
        guard let item = _item as? ZGUIDemoPageSubTextItem else {
            return ""
        }
        return item.pageReuseIdentifier;
    }
}

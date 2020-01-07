//
//  ZGUIDemoHomeHeaderView.swift
//  ZGUIDemo
//
//  Created by temp on 2017/3/28.
//
//

import UIKit
import ZGUI

class ZGUIDemoHomeHeaderView: ZGCollectionReusableView {
    var titleLabel : UILabel?
    
    override func setObject(_ obj: ZGBaseUIItem) {
        super.setObject(obj)
        if obj is ZGUIDemoHomeSectionItem {
            let homeItem = obj as! ZGUIDemoHomeSectionItem
            self.titleLabel?.text = homeItem.title
        }
        self.alpha = 0.5
    }
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.addTitleLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addTitleLabel(){
        let titleLabel = UILabel()
        titleLabel.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.zero)
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.textColor = .black
        titleLabel.backgroundColor = .white
        titleLabel.textAlignment = .center
        self.addSubview(titleLabel)
        
        self.titleLabel = titleLabel
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let homeItem = self.item as! ZGUIDemoHomeSectionItem
        self.titleLabel?.frame = CGRect.init(origin: CGPoint.zero, size: homeItem.size)
    }

}

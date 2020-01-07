//
//  ZGUIDemoHomeCell.swift
//  ZGUIDemo
//
//  Created by temp on 2017/3/23.
//
//

import UIKit
import ZGUI

class ZGUIDemoHomeCell: ZGCollectionViewCell {
    var titleLabel : UILabel?
    
    override func setObject(_ obj: ZGBaseUIItem) {
        super.setObject(obj)
        if obj is ZGUIDemoHomeItem {
            let homeItem = obj as! ZGUIDemoHomeItem
            self.titleLabel?.text = homeItem.title
        }
        self.backgroundColor = UIColor.orange
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
        
        titleLabel.textAlignment = .center
        self.contentView.addSubview(titleLabel)
        
        self.titleLabel = titleLabel
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let homeItem = self.item as! ZGUIDemoHomeItem
        self.titleLabel?.frame = CGRect.init(origin: CGPoint.zero, size: homeItem.size)
    }
    
}

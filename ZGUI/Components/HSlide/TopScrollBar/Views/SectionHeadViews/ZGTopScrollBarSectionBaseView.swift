//
//  ZGTopScrollBarSectionBaseView.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/3/27.
//
//

import UIKit

public let kkScrollTagSectionViewZPosition:CGFloat = 6;

public protocol ZGTopScrollBarSectionViewDelegate : NSObjectProtocol {
    
    func didLayout(sectionView:ZGTopScrollBarSectionBaseView);
    func didClicked(sectionView:ZGTopScrollBarSectionBaseView);
    func backgroundColor(withSectionView sectionView:ZGTopScrollBarSectionBaseView) -> UIColor;
}

open class ZGTopScrollBarSectionBaseView: ZGCollectionReusableView {
    
    open weak var viewDelegate : ZGTopScrollBarSectionViewDelegate?;
    
    open var contentView: UIView!;
    open var rightLine: UIView!;
    open var bgButton: UIButton!;
    
    override public init(frame: CGRect) {
        super.init(frame: frame);
        self.initContentView();
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.initContentView();
    }
    
    open func initContentView() {
        self.layer.zPosition = kkScrollTagSectionViewZPosition;
        self.backgroundColor = UIColor.clear;
        self.clipsToBounds = false;
        
        self.contentView = UIView.init(frame: self.bounds);
        self.contentView.backgroundColor = UIColor.clear;
        self.addSubview(self.contentView);
        
        self.bgButton = UIButton.init(type: .custom);
        self.bgButton.backgroundColor = UIColor.clear;
        self.bgButton.addTarget(self, action: #selector(ZGTopScrollBarSectionBaseView.bgButtonClicked), for: .touchUpInside);
        self.addSubview(self.bgButton);
        
        self.rightLine = UIView()
        self.rightLine.backgroundColor = UIColor.gray;
        self.addSubview(self.rightLine);
    }

    @objc open func bgButtonClicked() {
        self.viewDelegate?.didClicked(sectionView: self);
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews();
        
        self.contentView.frame = self.bounds;
        self.bgButton.frame = self.bounds;
        
        let width:CGFloat = 0.5;
        self.rightLine.frame = CGRect.init(x: self.frame.width-width, y: 6, width: width, height: self.frame.height-6*2);
        
        self.backgroundColor = self.viewDelegate?.backgroundColor(withSectionView: self);
        self.viewDelegate?.didLayout(sectionView: self);
    }
}


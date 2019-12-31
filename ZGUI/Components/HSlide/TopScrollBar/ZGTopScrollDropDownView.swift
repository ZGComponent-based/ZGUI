//
//  ZGTopScrollDropDownView.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/3/31.
//
//

import UIKit

public protocol ZGTopScrollDropDownViewDelegate:class {
    func dropDownView(_ view:ZGTopScrollDropDownView, didSelectItemAt indexPath:IndexPath, object:Any);
    func dropDownView(_ view:ZGTopScrollDropDownView, hideWith animated:Bool);
}

open class ZGTopScrollDropDownView: UIView,UICollectionViewDelegateFlowLayout {
    
    open weak var delegate : ZGTopScrollDropDownViewDelegate?;
    
    fileprivate weak var _dataSource : ZGTopScrollDropDownDataSource?;
    public var dataSource : ZGTopScrollDropDownDataSource? {
        set {
            _dataSource = newValue
            
            self.collectionView.dataSource = newValue;
            self.collectionView.reloadData();
            self.layoutCollectionBgView();
        }
        get {
            return _dataSource;
        }
    }
    
    open var coverView: UIView!;
    open var dropDownBgView: UIView!;
    open var collectionBgView: UIView!;
    open var collectionView: UICollectionView!;
    open var collectionGridView: UIView!;
    open var footBgView: UIView!;
    
    open var contentSize: CGSize = .zero;
    
    public override init(frame: CGRect) {
        super.init(frame: frame);
        self.backgroundColor = UIColor.clear;
        self.createCoverView();
        self.createCollectionView();
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func createCoverView() {
        //创建蒙层视图
        let coverView = UIView.init(frame: CGRect.zero);
        coverView.backgroundColor = UIColor.black;
        self.addSubview(coverView);

        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(ZGTopScrollDropDownView.didClicked(converView:)));
        coverView.addGestureRecognizer(tapGesture);
        self.coverView = coverView;
    }
    
    open func createCollectionView() {
        //创建横滑背景View
        self.dropDownBgView = UIView.init(frame: .zero);
        self.dropDownBgView.clipsToBounds = true;
        self.dropDownBgView.backgroundColor = UIColor.color(withHex: 0xffffff, alpha: 0.97);
        self.addSubview(self.dropDownBgView);
        
        if #available(iOS 8.0, *) {
            let effect = UIBlurEffect.init(style: .extraLight);
            let visualEffectView = UIVisualEffectView.init(effect: effect);
            visualEffectView.frame = self.dropDownBgView.bounds;
            visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight];
            self.dropDownBgView.addSubview(visualEffectView);
            self.dropDownBgView.backgroundColor = UIColor.clear;
        }
        
        self.collectionBgView = UIView.init(frame: .zero);
        self.collectionBgView.clipsToBounds = true;
        self.collectionBgView.backgroundColor = UIColor.clear;
        self.collectionBgView.autoresizingMask = .flexibleTopMargin;
        self.dropDownBgView.addSubview(self.collectionBgView);
        
        //创建CollectionView
        let layout = UICollectionViewFlowLayout.init();
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = .vertical;
    
        let collection = UICollectionView.init(frame: self.collectionBgView.bounds, collectionViewLayout: layout);
        collection.backgroundColor = UIColor.clear;
        collection.showsVerticalScrollIndicator = false;
        collection.showsHorizontalScrollIndicator = false;
        collection.isScrollEnabled = false;
        collection.delegate = self;
        if #available(iOS 10.0, *) {
            collection.isPrefetchingEnabled = false;
        }
        self.collectionBgView.addSubview(collection);
        self.collectionView = collection;
        self.registerClass();
        
        //创建collectionView网格View
        self.collectionGridView = UIView.init(frame: .zero);
        self.collectionGridView.backgroundColor = UIColor.clear;
        self.collectionGridView.isUserInteractionEnabled = false;
        self.collectionBgView.addSubview(self.collectionGridView);
        
        //创建尾部视图
        self.footBgView = UIView.init(frame: .zero);
        self.footBgView.backgroundColor = UIColor.clear;
        self.collectionBgView.addSubview(self.footBgView);
    }
    
    open func registerClass() {
        ZGTopScrollDropTextCell.register(for: self.collectionView);
        ZGTopScrollDropImageCell.register(for: self.collectionView);
    }
    
    @objc open func didClicked(converView tap:UITapGestureRecognizer) {
        self.delegate?.dropDownView(self, hideWith: true);
    }
    
    
    open func resetAllSelectedState() {
        guard let ds = self.dataSource else {
            return;
        }
        for item in ds.items {
            item.isSelect = false;
        }
    }
    
    open func layoutCollectionBgView() {
        let size = self.dataSource?.contentViewSize() ?? .zero;
        self.collectionBgView.frame = CGRect.init(origin: .zero, size: size);
        self.contentSize = size;
        
        self.footBgView.removeAllSubviews()
        guard let ds = self.dataSource else {
            return;
        }
        
        self.footBgView.frame = ds.footView?.bounds ?? .zero;
        self.footBgView.bottom = self.contentSize.height;
        if let footView = ds.footView {
            self.footBgView.addSubview(footView);
        }
        
        var frame = CGRect.zero;
        frame.size = self.contentSize;
        frame.size.height -= self.footBgView.frame.height;
        self.collectionView.frame = frame;
        
        self.collectionGridView.frame = self.collectionView.frame;
        self.collectionGridView.removeAllSubLayer();
        
        guard ds.lineCount>0 && ds.columnCount>0 else {
            return;
        }
        
        let h: CGFloat = 0.5;
        for i in 1...ds.lineCount {
            let rowLayer = CALayer();
            rowLayer.frame = CGRect.init(x: 0, y: CGFloat(i)*ds.lineHeight-h, width: self.collectionGridView.width, height: h);
            rowLayer.backgroundColor = UIColor.color(withHex: 0xE5E5E5).cgColor;
            self.collectionGridView.layer.addSublayer(rowLayer);
        }
        
        let gridWidth = self.collectionGridView.width / CGFloat(ds.columnCount);
        for i in 1..<ds.columnCount {
            let columnLayer = CALayer();
            columnLayer.frame = CGRect.init(x: CGFloat(i)*gridWidth, y: 0, width: h, height: self.collectionGridView.height);
            columnLayer.backgroundColor = UIColor.color(withHex: 0xE5E5E5).cgColor;
            self.collectionGridView.layer.addSublayer(columnLayer);
        }
    }
    
    
    open func selectItem(atIndexPath indexPath:IndexPath, animated:Bool) {
        guard let ds = self.dataSource else {
            return;
        }
        let object = ds.collectionView(self.collectionView, objectForItemAt: indexPath);
        
        guard let obj = object else {
            return;
        }
        obj.isSelect = true;
        self.collectionView.reloadData();
    }
    
    open func show(withAnimated animated:Bool, completion:@escaping ()->Void) {
        var collectionFrame = CGRect.zero;
        collectionFrame.size = self.contentSize;
        
        self.dropDownBgView.frame = collectionFrame;
        self.dropDownBgView.height = 0;
        self.collectionBgView.bottom = 0;
        
        self.coverView.alpha = 0;
        self.coverView.frame = self.bounds;
        
        var coverFrame = collectionFrame;
        coverFrame.origin.y = collectionFrame.maxY;
        coverFrame.size.height = self.frame.height - coverFrame.origin.y;
        
        UIView.animate(withDuration: animated ? 0.3 : 0,
                       animations: { 
                        self.dropDownBgView.frame = collectionFrame;
                        self.coverView.frame = coverFrame;
                        self.coverView.alpha = 0.5;
        }) { (finished) in
            completion();
        }
    }
    
    open func hide(withAnimated animated:Bool, completion:@escaping ()->Void) {
        UIView.animate(withDuration: animated ? 0.3 : 0,
                       animations: { 
                        self.dropDownBgView.height = 0;
                        self.coverView.frame = self.bounds;
                        self.coverView.alpha = 0;
        }) { (finished) in
            completion();
        }
    }
    
    
    
    //MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let ds = collectionView.dataSource as? ZGTopScrollDropDownDataSource else {
            return CGSize.zero;
        }
        let width = UIScreen.main.bounds.width;
        return CGSize.init(width: width/CGFloat(ds.columnCount), height: ds.lineHeight);
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero;
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.zero;
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let ds = self.dataSource else {
            return;
        }
        let object = ds.collectionView(collectionView, objectForItemAt: indexPath);
        guard let obj = object else {
            return;
        }
        let cell1 = collectionView.cellForItem(at: indexPath);
        guard let cell = cell1 else {
            return;
        }
        cell.backgroundColor = UIColor.red;
        
        if let textCell = cell as? ZGTopScrollDropTextCell {
            let textItem = obj as! ZGTopScrollBarTextItem;
            
            textCell.titleLabel.textColor = UIColor.white;
            textCell.backgroundColor = textItem.isChangeDropColor ? textItem.selectedTextColor : UIColor.red;
        }
        
        self.delegate?.dropDownView(self, didSelectItemAt: indexPath, object: obj);
    }
}

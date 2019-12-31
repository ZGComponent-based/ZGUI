//
//  ZGCollectionViewCell.swift
//  ZGUIDemo
//

//
//

import UIKit

open class ZGCollectionViewCell: UICollectionViewCell {
    final var _object:ZGBaseUIItem?
    
    final public var item:ZGBaseUIItem? {
        get {
            return _object
        }
    }
    
    open func itemDidChange() {
        
    }
    
    //override
    open func setObject (_ obj:ZGBaseUIItem) -> Void {
        _object = obj
        obj.itemChangeHandler = { [weak self] in self?.itemDidChange()  }
    }
    
    //override
    open class func tbbzIdentifier() -> String{
        return "\(self)"
    }
    
    //override
    open class func collectionView (_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForObject object: ZGBaseUIItem) -> CGSize {
        return object.size
    }
    
    open class func register(for collectionView:UICollectionView)  {
        collectionView.register(self, forCellWithReuseIdentifier: self.tbbzIdentifier())
    }
    
    open func addLabel() -> UILabel {
        let label = UILabel()
        self.contentView.addSubview(label)
        label.isUserInteractionEnabled = false
        label.numberOfLines = 0
        return label
    }
    
    open func addButton() -> UIButton {
        let btn = UIButton(type: .custom)
        self.contentView.addSubview(btn)
        return btn
    }
    
    open func addImageView() -> ZGImageView {
        let imageView = ZGImageView()
        self.contentView.addSubview(imageView)
        imageView.backgroundColor = UIColor.clear
        imageView.isUserInteractionEnabled = false
        return imageView
    }
    
    open func addLayer() -> CALayer {
        let layer1 = CALayer()
        self.layer.addSublayer(layer1)
        return layer1
    }
    
    open func initContent()  {
        self.backgroundColor = UIColor.white
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initContent()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initContent()
    }
}

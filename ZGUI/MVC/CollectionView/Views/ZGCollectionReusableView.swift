//
//  ZGCollectionReusableView.swift
//  ZGUIDemo
//
//
//

import UIKit

open class ZGCollectionReusableView: UICollectionReusableView {
    final var _object : ZGBaseUIItem?
    final public var item : ZGBaseUIItem?{
        get {
            return _object
        }
    }
    
    //override
    open func setObject (_ obj:ZGBaseUIItem) -> Void {
        _object = obj
    }
    
    //override
    open class func tbbzIdentifier() -> String{
        return "\(self)"
    }
    
    //override
    open class func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForObject object: ZGBaseUIItem) -> CGSize{
        return object.size
    }
    
    open class func register(for collectionView:UICollectionView, kind:String)  {
        collectionView.register(self, forSupplementaryViewOfKind: kind, withReuseIdentifier: self.tbbzIdentifier());
    }
}

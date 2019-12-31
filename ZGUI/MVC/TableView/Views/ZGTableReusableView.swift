//
//  ZGCollectionReusableView.swift
//  ZGUIDemo
//
//
//

import UIKit

open class ZGTableReusableView: UITableViewHeaderFooterView {
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
    open class func efIdentifier() -> String{
        return "\(self)"
    }
    
    //override
    open class func tableView (_ tableView: UITableView, rowHeightForObject object: ZGBaseUIItem) -> CGFloat {
        return object.size.height
    }
    
    open class func register(for tableView:UITableView)  {
        tableView.register(self, forHeaderFooterViewReuseIdentifier: self.efIdentifier())
    }
}

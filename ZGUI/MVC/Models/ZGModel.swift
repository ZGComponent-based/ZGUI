//
//  ZGModel.swift
//  ZGUIDemo
//
//

import UIKit
import ZGNetwork

open class ZGModel {
    //用于pv打点, 任意取一个设置了statistic_AnalysisData的item
    public var pageViewItem:ZGBaseUIItem?
    
    open var items : [Any]
    open var sections : [ZGCollectionReusableViewItem]
    open var pageSize : Int = 20
    open var pageNumber : Int = 1
    open var loading : Bool = false
    open var hasNext : Bool = false
    open var didFinishLoad: Bool = false
    
    open var pageSourceType : String?
    open var listVersion : String?
    
    open var visibleRect : CGRect?
    
    public init() {
        self.items = []
        self.sections = []
    }
    
    public func resetPageViewItem(_ item:ZGBaseUIItem) {
 
    }
    
    /// 设置item索引
    ///
    open func resetItemsIndex() {
        var modelIndex:Int = 0
        var itemIndex:Int = 0
        for item in self.items {
            
            if item is [Any] {
                modelIndex += 1
                itemIndex = 0
                let arr = item as! [Any]
                for item1 in arr {
                    if item1 is ZGBaseUIItem {
                        itemIndex += 1
                        let uiItem = item1 as! ZGBaseUIItem
                        uiItem.itemIndex = itemIndex
                        uiItem.modelIndex = modelIndex
                        self.resetPageViewItem(uiItem)
                    }
                }
                
            } else if item is ZGBaseUIItem {
                itemIndex += 1
                let uiItem = item as! ZGBaseUIItem
                uiItem.itemIndex = itemIndex
                uiItem.modelIndex = modelIndex
                self.resetPageViewItem(uiItem)
            }
        }
        
    }
    
    open func loadItems(_ parameters : [String:Any]? = nil,
                            completion : @escaping ([String:Any]?)->Void ,
                                failure : @escaping (ZGNetworkError)->Void){
        
    }
    
}

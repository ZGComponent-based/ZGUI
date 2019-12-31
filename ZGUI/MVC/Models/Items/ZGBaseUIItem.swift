//
//  ZGUIItemProtocol.swift
//  ZGUIDemo
// 
//
//

import UIKit
import ZGNetwork

public protocol ZGBaseUIItemProtocol : class {
    func mapViewType() -> ZGCollectionViewCell.Type
    func mapTableViewType() -> ZGTableViewCell.Type
    var size:CGSize {set get}
}

public enum ZGAnalysisVisitType : Int {
    case pageView //PV
    case pageClick //页面点击或tab点击等
    case pageExchange //页面流转
    case pageOut //页面时间
}

//当item数据发生变化时执行回调
public typealias ItemChangeHandler = () -> Void

//必须继承自NSObject, 统计SDK用
open class ZGBaseUIItem : NSObject, ZGBaseUIItemProtocol {
    var _apiVo:ZGNetworkApiVo?
    var _modelName:String?
    var _modelIndex:Int?
    var _itemIndex:Int?
    var _statisticDict:[String:Any]?
    var _posType:String?
    var _visitType:ZGAnalysisVisitType?
    
    public var apiVo:ZGNetworkApiVo? {
        get {
            return _apiVo
        }
        set {
            _apiVo = newValue
            self.refreshAnalysisVo()
        }
    }
    
    public var itemChangeHandler:ItemChangeHandler?
    
    
    open func mapViewType() -> ZGCollectionViewCell.Type {
        return ZGCollectionViewCell.self
    }
    
    //返回item对应的cellType
    open func mapTableViewType() -> ZGTableViewCell.Type{
        return ZGTableViewCell.self
    }
    
    //计算cell的size 默认是zero
    open var size : CGSize = .zero
    
    public override init() {
        super.init()
    }
    
    func refreshAnalysisVo() {
   
        
    }
    
    //MARK: - 打点相关属性
    public var modelName:String? {
        get {
            return _modelName
        }
        set {
            _modelName = newValue
            self.refreshAnalysisVo()
        }
    }
    
    public var modelIndex:Int? {
        get {
            return _modelIndex
        }
        set {
            _modelIndex = newValue
            self.refreshAnalysisVo()
        }
    }
    public var itemIndex:Int? {
        get {
            return _itemIndex
        }
        set {
            _itemIndex = newValue
            self.refreshAnalysisVo()
        }
    }
    public var statisticDict:[String:Any]? {
        get {
            return _statisticDict
        }
        set {
            _statisticDict = newValue
            self.refreshAnalysisVo()
        }
    }
    public var posType:String? {
        get {
            return _posType
        }
        set {
            _posType = newValue
            self.refreshAnalysisVo()
        }
    }
    
    public var visitType:ZGAnalysisVisitType? {
        get {
            return _visitType
        }
        set {
            _visitType = newValue
            self.refreshAnalysisVo()
        }
    }
}


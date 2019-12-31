//
//  ZGTopScrollBarBaseItem.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/3/24.
//
//

import UIKit

public protocol ZGTopScrollBarBaseItem : ZGBaseUIItemProtocol {
    var isSelect : Bool {get set}  //当前item是否被选中
    var pageReuseIdentifier: String {get} //当前item对应page的复用标识
}

public protocol ZGTopScrollBarTextItem : ZGTopScrollBarBaseItem {
    var isLeft:Bool {get set}; //文字靠左
    var isBold : Bool {get set};//粗
    var isLight : Bool {get set};//细
    var text : String {get set};  //横滑滚动条的文字
    var selectIsBold : Bool {get set}; //选中状态字体是否需要加粗
    var selectFontSize: CGFloat {get set}
    var normalTextColor : UIColor {get set}   //正常的文字颜色，optional
    var selectedTextColor : UIColor {get set} //选中的文字颜色，optional
    var selectedLineColor : UIColor {get set} //选中的文字颜色，optional
    var isShowRedBadgeValue : Bool {get set};//文字右上角是否显示红点
    var lineWidth:CGFloat {get set}
    var fontSize: CGFloat {get set}
    var isChangeDropColor : Bool {get set}    //是否改变下拉菜单的文字颜色，optional
}

public protocol ZGTopScrollBarImageItem : ZGTopScrollBarBaseItem {
    var imageData : Data {get set}  //横滑滚动条的gif图
    var imageSelectData : Data? {get set}    //选中gif图，optional
    var horizontalPadding : CGFloat {get set} //水平的总间距，optional
    var verticalPadding : CGFloat {get set}  //垂直的总间距，optional
}

open class ZGTopScrollBarItem: ZGBaseUIItem, ZGTopScrollBarTextItem, ZGTopScrollBarImageItem {
    public var isLight: Bool = false
    public var isLeft: Bool = false
    public var selectedLineColor: UIColor = .red
    public var fontSize: CGFloat = 15
    public var lineWidth:CGFloat = 25
    public var isSelect: Bool = false
    public var isBold: Bool = false
    public var selectIsBold: Bool = false
    public var selectFontSize: CGFloat = 15
    public var isShowRedBadgeValue: Bool = false
    
    public var pageReuseIdentifier: String = ""
    public var text: String = ""
    public var normalTextColor: UIColor = .black
    public var selectedTextColor: UIColor = .red
    
    public var imageData : Data = Data()
    public var imageSelectData : Data?
    public var horizontalPadding : CGFloat = 0.0
    public var verticalPadding : CGFloat = 0.0
    
    public var paramDict: [String: Any]?
    
    public var model: ZGModel?
}


public extension ZGTopScrollBarTextItem {
    var normalTextColor : UIColor {
        set {}
        get {return UIColor.color(withHex: 0x595858)}
    }
    var selectedTextColor : UIColor {
        set {}
        get {return UIColor.color(withHex: 0xef4545)}
    }
    var isChangeDropColor : Bool {
        set {}
        get {return false}
    }
}

public extension ZGTopScrollBarImageItem {
    var imageSelectData : Data? {
        set {}
        get {return nil}
    }
    var horizontalPadding : CGFloat {
        set {}
        get {return 0}
    }
    var verticalPadding : CGFloat {
        set {}
        get {return 0}
    }
}

//
//  ZGTabbar.swift
//  ZGUIDemo
//
//  Created by bruce on 2017/3/15.
//
// Tabbar

import UIKit

open class ZGTabbar: UIView {
    var clickAction:((Int)->Void)? = nil
    
    var doubleClickAction:((Int)->Void)? = nil
    
    var renderBtnArr:Array<ZGTabbarButton> = []
    
    // 使用属性观察者，当items设置改变完成后渲染tab按钮
    private var items:Array<ZGTabbarItem>? = nil{
        didSet{
            demonstrateTabbars()
        }
    }
    
    
    //MARK:---- 初始化方法 ----
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.backgroundColor = UIColor.gray
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open var tabItems:Array<ZGTabbarItem>?{
        get{
            return items
        }
        set(newItems){
           items = newItems
        }
    }
    
    // MARK: ---------- 生成tabbar ----------
    private func demonstrateTabbars() -> Void {
        if let baritems = self.tabItems?.prefix(5) {
            var index:Int = 0
            let btnWidth:Double = 49.0
            let itemCount:Int = baritems.count
            let totalWidth = Double(self.frame.width) - btnWidth * Double(itemCount)
            let padding:Double = (Double(totalWidth) / Double(itemCount + 1))

            for item:ZGTabbarItem in baritems {
                let barBtn:ZGTabbarButton = ZGTabbarButton(item)
                barBtn.backgroundColor = UIColor.clear
                var frame:CGRect = barBtn.frame
                let currentPadding:Double = padding + (padding + Double(frame.width)) * Double(index)
                frame.origin = CGPoint(x:currentPadding,y:0)
                
                let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target:self,action: #selector(ZGTabbar.tabBarAction))
                barBtn.addGestureRecognizer(tapGesture)
                
                let doubleTapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target:self,action: #selector(ZGTabbar.doubleTabBarAction))
                doubleTapGesture.numberOfTapsRequired = 2
                barBtn.addGestureRecognizer(doubleTapGesture)
                
                
                
                barBtn.frame = frame
                barBtn.tag = 1000+index
                index += 1
                self.addSubview(barBtn)
                renderBtnArr.append(barBtn)
                if item.isSelected {
                    tabBarAction(tapGesture)
                }
            }
        }
    }
    
    
    
    // MARK:------------ 单击事件 ------------
    @objc internal func tabBarAction(_ gestur:UIGestureRecognizer){
        let sender:ZGTabbarButton = gestur.view as! ZGTabbarButton
        
        guard !sender.isSelected else {
            return
        }
        changeButtonState(sender)
        
        if let clickAction1 = sender.barItem?.singleClickAction {
            let index = sender.tag - 1000
            clickAction1(index)
        }else{
            if let clickAction1 = self.clickAction {
                let index = sender.tag - 1000
                clickAction1(index)
            }
        }
    }
    
    /// 修改btn的样式
    ///
    /// - Parameter sender: 点击的button对象
    private func changeButtonState(_ sender: ZGTabbarButton) -> Void {
        let _ = self.renderBtnArr.map{
            if !($0.isEqual(sender)){
                $0.isSelected = false
            }
        }
        sender.isSelected = !sender.isSelected
    }
    
    // MARK:----------------- 双击事件 -------------
    @objc internal func doubleTabBarAction(_ gestur:UIGestureRecognizer){
        let sender:ZGTabbarButton = gestur.view as! ZGTabbarButton
        if let doubleclickAction = sender.barItem?.doubleClickAction {
            let index = sender.tag - 1000
            doubleclickAction(index)
        }
        
    }
    
    /// 刷新Tabbar
    ///
    /// - Parameter refreItems: 更新的bar对应的items更新数据
    open func refrshTabbar(_ refreshItems:Array<ZGTabbarItem>) -> Void {
        guard renderBtnArr.count < refreshItems.count else {
            return
        }
        var index:Int = 0
        for sender in renderBtnArr {
            let item:ZGTabbarItem = refreshItems[index]
            item.isSelected = sender.isSelected
            sender.barItem = item
            index += 1
        }
  
    }
}

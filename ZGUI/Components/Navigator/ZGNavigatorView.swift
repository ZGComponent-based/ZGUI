//
//  ZGNavigatorView.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/3/22.
//
//

import Foundation
import UIKit
 
open class ZGNavigatorView:UIView{
    
    private var _navigatorItem: ZGNavigatorItem?
    private var _navigatorItemPropertyNames = [String]()
    
    private var _leftView: UIView!
    private var _rightView: UIView!
    private var _titleView: UIView!
    public var _titleLabel: UILabel!
    private var _backgroundView :UIImageView?

    public var bottomLine: UIView?

    
    private var _buttonFont = UIFont.systemFont(ofSize: 14)
    private var _titleFont = UIFont.systemFont(ofSize: 18)
    private var _titleColor: UIColor = UIColor.color(withHex: 0x2B2929)
    private var _buttonStyleText = "<font color='#333333' size='14' >按钮</font>"

    public var leftPadding: CGFloat = 0
    public var rightPadding: CGFloat = 0
    
    private var _displayShadow: Bool = false
    
    
    let TBNavigatorViewTitleTag = 433322
    let TBDefaultStatusBarHeight:CGFloat = ZGUIUtil.statusBarHeight()
    let TBNavigatorButtonWidth:CGFloat = 44
    
    var myContext = 0
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.initContent()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initContent()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func initContent() -> () {
        self.displayShadow = false
        if (_navigatorItem != nil) {
            _navigatorItemPropertyNames = (_navigatorItem?.allProperties())!
        }
        _leftView = UIView(frame:CGRect.zero)
        _leftView.backgroundColor = UIColor.clear
        _rightView = UIView(frame:CGRect.zero)
        _rightView.backgroundColor = UIColor.clear
        _titleView = UIView(frame:CGRect.zero)
        _titleView.backgroundColor = UIColor.clear
        
        if self.subviews.count == 0 {
            self.addSubview(_titleView)
            self.addSubview(_leftView)
            self.addSubview(_rightView)
        }
        
        self.bottomLine = UIView.init(frame: CGRect.init(x: 0, y: self.height-1, width: self.width, height: 1))
        self.bottomLine?.backgroundColor = UIColor.color(withHex: 0xE7E7E7)
        self.addSubview(self.bottomLine!)
    }
    
    public var titleColor: UIColor{
        get{
            return _titleColor
        }
        set{
            _titleColor = newValue
            if _titleLabel != nil {
                _titleLabel.textColor = _titleColor
            }
        }
    }
    
    public var titleFont: UIFont{
        get{
            return _titleFont
        }
        set{
            _titleFont = newValue
            if (_titleView != nil) {
                if _titleView.viewWithTag(TBNavigatorViewTitleTag) != nil {
                    let label: UILabel = _titleView!.viewWithTag(TBNavigatorViewTitleTag) as! UILabel
                    label.font = newValue
                }
            }
        }
    }
    
    public var buttonStyleText:String {
        get {
            return _buttonStyleText
        }
        set {
            _buttonStyleText = newValue
        }
    }
    
    public var buttonFont: UIFont{
        get{
            return _buttonFont
        }
        set{
            _buttonFont = newValue
            self.setBtnFont(superView: _leftView)
            self.setBtnFont(superView: _rightView)
        }
    }
    
    func setBtnStyleText(superView: UIView){
        let childViews = superView.subviews
        for child in childViews{
            if child is UIButton {
                let btn = child as! UIButton
                btn.titleLabel?.htmlStyleText(_buttonStyleText)
            }
        }
    }
    
    func setBtnFont(superView: UIView){
        let childViews = superView.subviews
        for child in childViews{
            if child is UIButton {
                let btn = child as! UIButton
                btn.titleLabel?.font = _buttonFont
            }
        }
    }

    public var displayShadow: Bool{
        get{
            return _displayShadow
        }
        set{
            _displayShadow = newValue
            if (_titleView != nil) {
                let label: UILabel = _titleView!.viewWithTag(TBNavigatorViewTitleTag) as! UILabel
                if (newValue) {
                    label.layer.shadowColor = UIColor.black.cgColor
                    label.layer.shadowOffset = CGSize.init(width: 0, height: 1)
                    label.layer.shadowOpacity = 1
                    label.layer.shadowRadius = 1.0
                } else {
                    label.layer.shadowOffset = CGSize.init(width: 0, height: 0)
                    label.layer.shadowOpacity = 0
                    label.layer.shadowRadius = 0
                }

            }
        }
    }
    
    public var navigatorItem: ZGNavigatorItem{
        get{
            return _navigatorItem!
        }
        set{
            if _navigatorItem != nil {
                self.removeNavigatorItemObserver()
            }
            _navigatorItem = newValue
            if _navigatorItem == nil {
                return;
            }
            
            _navigatorItemPropertyNames = (_navigatorItem?.allProperties())!
            self.addNavigatorItemPropertyObserver()
            
            self.removeAllSubViews(view: _leftView)
            self.removeAllSubViews(view: _rightView)
            self.removeAllSubViews(view: _titleView)
            if ((_navigatorItem?.leftBarButtonItem) != nil) {
                self.createLeftButton(buttonItem: (_navigatorItem?.leftBarButtonItem)!, index: 0)
            }else{
                self.createLeftButtons()
            }
            if ((_navigatorItem?.rightBarButtonItem) != nil) {
                self.createRightButton(buttonItem: (_navigatorItem?.leftBarButtonItem)!, index: 0)
            }else{
                self.createRightButtons()
            }
            if ((_navigatorItem?.titleView) != nil) {
                self.addTitleView()
            }
            if _navigatorItem?.title != nil{
                self.createTitle()
            }
        }
    }
    
    func addTitleView() {
        var rect = self.titleRect()
        _titleView.frame = rect
        rect.origin = CGPoint.zero
        _navigatorItem?.titleView?.frame = rect
        _titleView .addSubview((_navigatorItem?.titleView)!)
    }
    
    func createTitle(){
        let rect = self.titleRect()
        _titleView.frame = rect;
        
        _titleLabel = UILabel()
        _titleLabel.text = _navigatorItem?.title
        _titleLabel.font = _titleFont
        _titleLabel.textColor = _titleColor
        _titleLabel.frame = CGRect(x: 70, y: 0, width: rect.width - 140, height: rect.height)
        _titleLabel.textAlignment = NSTextAlignment.center
        _titleLabel.autoresizingMask = [UIView.AutoresizingMask.flexibleHeight,UIView.AutoresizingMask.flexibleWidth]
        _titleLabel.tag = TBNavigatorViewTitleTag
        _titleView.addSubview(_titleLabel)
        
        if _displayShadow{
            self.displayShadow = true
        }
    }
    
    func titleRect() -> CGRect {
        let x: CGFloat = 0.0
        var y: CGFloat = 0.0
        let width: CGFloat = self.frame.size.width
        var height: CGFloat = self.frame.size.height
        
        if height > 45 {
            y  = CGFloat(TBDefaultStatusBarHeight)
            height -= y
        }
        return CGRect.init(x: x, y: y, width: width, height: height)
    }
    
    func removeAllSubViews(view: UIView) -> () {
        while view.subviews.count>0 {
            let childView = view.subviews.last
            childView?.removeFromSuperview()
        }
    }
    
    open func setBackgroundImage(image:UIImage) {
        if _backgroundView == nil {
            _backgroundView = UIImageView.init(frame: self.frame)
        }
        _backgroundView?.image = image
        self.addSubview(_backgroundView!)
        self.sendSubviewToBack(_backgroundView!)
    }
    
    //MARK: - KVO
    
    func addNavigatorItemPropertyObserver(){
        for propertyName in _navigatorItemPropertyNames{
            _navigatorItem?.addObserver(self, forKeyPath: propertyName, options: NSKeyValueObservingOptions.new, context:&myContext)
        }
    }
    
    func removeNavigatorItemObserver(){
        if _navigatorItem != nil {
            for propertyName in _navigatorItemPropertyNames{
                _navigatorItem?.removeObserver(self, forKeyPath: propertyName)
            }
        }
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "leftBarButtonItems"{
            self.removeAllSubViews(view: _leftView)
            self.createLeftButtons()
        }else if(keyPath == "rightBarButtonItems"){
            self.removeAllSubViews(view: _rightView)
            self.createRightButtons()
        }else if(keyPath == "titleView"){
            self.removeAllSubViews(view: _titleView)
            self.addTitleView()
        }else if(keyPath == "title"){
            self.removeAllSubViews(view: _titleView)
            self.createTitle()
        }else if(keyPath == "leftBarButtonItem"){
            self.removeAllSubViews(view: _leftView)
            if let leftBarButtonItem = _navigatorItem?.leftBarButtonItem {
                self.createLeftButton(buttonItem:leftBarButtonItem, index: 0)
            }
        }else if(keyPath == "rightBarButtonItem"){
            self.removeAllSubViews(view: _rightView)
            if let rightBarButtonItem = _navigatorItem?.rightBarButtonItem {
                self.createRightButton(buttonItem: rightBarButtonItem, index: 0)
            }
        }
    }
    
//MARK: - createButton
    
    func createButton(buttonItem:UIBarButtonItem,origin_x:CGFloat) -> UIButton {
        var width = buttonItem.width
        if width == 0 {
            width = CGFloat(TBNavigatorButtonWidth)
        }
        let height = width
 
        let origin_y:CGFloat = (TBNavigatorButtonWidth - height)/2
        let rect = CGRect.init(x: origin_x, y: origin_y, width: width, height: height)
        let image = buttonItem.image
        let title = buttonItem.title
        
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.frame = rect
//        button.analysis_name = buttonItem.analysis_name
        if let imageUrl = buttonItem.imageUrl {
            button.setImage(imageUrl, placeholderImage: nil, for: .normal)
        } else if image != nil {
            if title != nil {
                button.setBackgroundImage(image, for: UIControl.State.normal)
                button.setTitle(title, for: UIControl.State.normal)
                button.titleLabel?.font = _buttonFont
            }else{
                button.setImage(image, for: UIControl.State.normal)
            }
        }else{
            if title != nil {
                button.titleLabel?.font = _buttonFont
                button.setTitle(title, for: UIControl.State.normal)
            }
        }
        
        if let at1 = buttonItem.attributedTitleNormal {
            button.setAttributedTitle(at1, for: .normal)
        } else {
            button.setTitleColor(_titleColor, for: UIControl.State.normal)
        }
        button.addTarget(buttonItem.target, action: buttonItem.action!, for: UIControl.Event.touchUpInside)
        return button
        
    }
    
    func createLeftButtons() {
        var i = 0
        for btnItem in (_navigatorItem?.leftBarButtonItems)!{
          self.createLeftButton(buttonItem: btnItem, index: i)
            i += 1
        }
    }
    
    func createRightButtons() -> () {
        guard let items = _navigatorItem?.rightBarButtonItems else {
            return
        }
        var i = 0
        let sortItems = items.sorted { (item1, item2) -> Bool in
            return (item1.orderValue ?? 0) < (item2.orderValue ?? 0) ? true : false
        }
        for btnItem in sortItems{
            self.createRightButton(buttonItem: btnItem, index: i)
            i += 1
        }
    }
    
    func createLeftButton(buttonItem:UIBarButtonItem,index:Int) -> () {
        var leftX: CGFloat = 0.0
        var width = buttonItem.width
        if width == 0 {
            width = CGFloat(TBNavigatorButtonWidth)
        }
        leftX += (width+leftPadding) * CGFloat(index);
        leftX = leftX + leftPadding
        let btn: UIButton = self.createButton(buttonItem: buttonItem, origin_x: leftX)
        _leftView.addSubview(btn)
        btn.userData = buttonItem.userData
        var rect = _leftView.frame
        rect.size.width = leftX + width;
        
        let origin_y: CGFloat = TBDefaultStatusBarHeight
        var height = self.frame.size.height
        height = height - origin_y
        rect.origin.y = origin_y
        rect.size.height = height
        _leftView.frame = rect
    }
    
    func createRightButton(buttonItem:UIBarButtonItem,index:Int) -> () {
        var rightX: CGFloat = 0.0
        var buttonX: CGFloat = 0.0
        var width = buttonItem.width
        if width == 0 {
            width = CGFloat(TBNavigatorButtonWidth)
        }
        if index > 0 {
            buttonX = (width + rightPadding) * CGFloat(index)
        }
        rightX = self.frame.size.width - (width + rightPadding) * CGFloat(index + 1)
        let button = self.createButton(buttonItem: buttonItem, origin_x: buttonX)
        _rightView.addSubview(button)
        button.clearBadge()
        button.badgeOriginOffset = CGPoint(x: -5, y: 3)
        if let showRedDot = buttonItem.showRedDot {
            if showRedDot{
                button.showBadge(.redDot, value: 0)
            }
        }else if let badgeNumber = buttonItem.badgeNumber {
            if badgeNumber > 0{
                button.showBadge(.number, value: badgeNumber)
            }
        }
        button.userData = buttonItem.userData
        var rect = _rightView.frame
        rect.size.width = self.frame.size.width - rightX
        rect.origin.x = rightX
        var origin_y: CGFloat = 0
        var height = self.frame.size.height
        if height>45 {
            origin_y = CGFloat(TBDefaultStatusBarHeight)
        }
        height = height - origin_y
        rect.size.height = height;
        rect.origin.y = origin_y
        _rightView.frame = rect
    }
    
    public func appendRightBarButtonItems(buttonItem: UIBarButtonItem){
        guard let navigatorItem = _navigatorItem else {
            return
        }
        navigatorItem.rightBarButtonItems.append(buttonItem)
    }
    
    public func reloadRightBarButtons(){
        guard let navigatorItem = _navigatorItem else {
            return
        }
        let items = navigatorItem.rightBarButtonItems
        navigatorItem.rightBarButtonItems = items
    }
    
    deinit {
        self.removeNavigatorItemObserver()
    }
}

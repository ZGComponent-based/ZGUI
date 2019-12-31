//
//  ZGCollectionLoadMoreView.swift
//
//  Created by huangyuanqing on 2017/3/30.
//

import UIKit

public protocol ZGCollectionLoadMoreViewDelegate: NSObjectProtocol{
    func didTapLoadMoreView(_ loadMoreView : ZGCollectionLoadMoreView)
}

open class ZGCollectionLoadMoreView: ZGCollectionReusableView {
    open weak var delegate: ZGCollectionLoadMoreViewDelegate?
    
    var finishView: UIView?
    var activityView: ZGLoadMoreActivityView?
    var loadButton : UIButton?
    
    deinit {
        self.delegate = nil
    }
    
    open func createFinishView() -> UIView {
        return ZGCollectionLoadFinishView.init(frame: self.bounds)
    }
    
    open func createActivityView() -> ZGLoadMoreActivityView {
        return ZGLoadMoreActivityView.init(self.bounds, text: "加载中...")
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        let view1 = self.createActivityView()
        self.addSubview(view1)
        self.activityView = view1
        
        self.createLoadButton()
        
        let view2 = self.createFinishView()
        self.addSubview(view2)
        self.finishView = view2
        view2.isHidden = true
        
    }
    
    func createLoadButton(){
        let btn = UIButton.init(type: .custom)
        btn.frame = self.bounds
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(ZGCollectionLoadMoreView.loadAgain), for: .touchUpInside)
        btn.isHidden = true
        self.addSubview(btn)
        
        self.loadButton = btn
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func setObject(_ obj: ZGBaseUIItem) {
        super.setObject(obj)
        guard let myItem = self.item else {
            return
        }
        if myItem is ZGCollectionLoadMoreItem{
            self.setNeedsLayout()
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        guard let myItem = self.item else {
            return
        }
        
        self.activityView?.frame = self.bounds
        self.loadButton?.frame = self.bounds
        self.finishView?.frame = self.bounds
        if myItem is ZGCollectionLoadMoreItem{
            let loadMoreItem = myItem as! ZGCollectionLoadMoreItem
            if loadMoreItem.hasNext && !loadMoreItem.loading {
                loadMoreItem.loading = true
                loadMoreItem.text = "努力加载中..."
                self.loadAgain()
            }
            
            self.showLoadMoreFinishView(loadMoreItem.hasNext)
            
            self.activityView?.mLabel?.text = loadMoreItem.text
            
            if loadMoreItem.loading && !loadMoreItem.failed {
                self.activityView?.startAnimating()
            }else{
                self.activityView?.stopAnimation()
            }
            self.loadButton?.isHidden = !loadMoreItem.failed
            self.activityView?.setNeedsLayout()
        }
    }
    
    
    func showLoadMoreFinishView(_ show: Bool){
        self.finishView?.isHidden = show
        self.activityView?.isHidden = !show
        if !show{
            self.activityView?.stopAnimation()
        }
    }
    
    @objc func loadAgain(){
        self.delegate?.didTapLoadMoreView(self)
    }

}


open class ZGLoadMoreActivityView: UIView {
 
    var mLabel: UILabel?
    var activityIndicatorView: UIActivityIndicatorView?
    
    open func isAnimation() -> Bool {
        guard let view = self.activityIndicatorView else{
            return false
        }
        return view.isAnimating
    }
    
    deinit {
        self.activityIndicatorView?.stopAnimating()
    }
    
    open func initContent(activityText:String) {
        let label = UILabel()
        label.text = activityText
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.color(withHex: 0x878586)
//        label.backgroundColor = UIColor.color(withHex: 0xf6f6f6)
        self.addSubview(label)
        self.mLabel = label
        
        let view = UIActivityIndicatorView.init(style: .gray)
        self.addSubview(view)
        self.activityIndicatorView = view
        
        
        self.startAnimating()
    }
    
    public init(_ frame: CGRect, text:String) {
        super.init(frame: frame) 
        
        self.initContent(activityText:text)
    }
    
    open func startAnimating(){
        self.activityIndicatorView?.startAnimating()
        self.activityIndicatorView?.isHidden = false
        self.layoutSubviews()
    }
    
    open func stopAnimation(){
        self.activityIndicatorView?.startAnimating()
        self.activityIndicatorView?.isHidden = true
        self.layoutSubviews()
    }
    
    ///子类可以重写该方法
    open func layoutContent() {
        let activityWidth:CGFloat = 23.0
        let gap : CGFloat = 7.0
        var textSize = self.mLabel?.sizeThatFits(.zero)
        textSize?.height = self.bounds.height
        let centerWidth = self.bounds.width - activityWidth - (textSize?.width ?? 0) - gap
        let origin_x = centerWidth / 2
        let origin_y = (self.bounds.height - activityWidth) / 2
        
        self.activityIndicatorView?.frame = CGRect.init(x: origin_x, y: origin_y, width: activityWidth, height: activityWidth)
        
        
        var labelOrigin_x = origin_x + activityWidth + gap
        let hidden = (self.activityIndicatorView?.isHidden) ?? true
        labelOrigin_x = hidden ? (self.bounds.width - (textSize?.width ?? 0))/2 : labelOrigin_x
        
        self.mLabel?.frame = CGRect.init(x:labelOrigin_x, y: 0, width: textSize?.width ?? 0, height:textSize?.height ?? 0)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutContent()
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ZGCollectionLoadFinishView: UIView{
    var finishLabel : UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createFinisheLabel()
    }
    
    func createFinisheLabel(){
        let label = UILabel()
        label.frame = self.bounds
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.textAlignment = .center
        label.text = "已经到最后了"
        self.addSubview(label)
        
        self.finishLabel = label
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.finishLabel?.frame = self.bounds
    }
}

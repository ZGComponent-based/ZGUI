//
//  ZGCollectionLoadMoreView.swift
//
//  Created by huangyuanqing on 2017/3/30.
//

import UIKit

public protocol ZGTableLoadMoreViewDelegate: NSObjectProtocol{
    func didTapLoadMoreView(_ loadMoreView : ZGTableLoadMoreView)
}

open class ZGTableLoadMoreView: ZGTableReusableView {
    open weak var delegate: ZGTableLoadMoreViewDelegate?
    
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
    
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
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

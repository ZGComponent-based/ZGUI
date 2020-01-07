//
//  AlertDemoVCL.swift
//
//  Created by zhaogang on 2017/8/25.
//

import UIKit
import ZGUI

class LoadingDemoVCL: ZGCollectionVCL {
    var style:LoadingStyle?
    
    override func getLoadingFrame() -> CGRect {
        var rect = self.view.bounds
        rect.origin.y = self.zbNavigatorView!.height
        rect.size.height -= rect.origin.y
        return rect
    }
    
    @objc func btn2Action(_ sender:UIButton)  {
        guard let style = self.style else {
            return
        }
        
        switch style {
        case .pageLoading:
            self.hidePopupLoading()
        case .popup:
            self.hidePopupLoading()
        case .trasparent:
            self.hidePageLoading()
        }
        self.hidePageLoading()
    }
    
    override func addCollectionView() {
        if self.collectionView != nil {
            return
        }
        guard let zbNavigatorView = self.zbNavigatorView else {
            return
        }
        
        var rect = self.view.bounds
        rect.origin.y = zbNavigatorView.height
        rect.size.height = self.view.height - rect.origin.y
        
        let layout =  self.collectionViewLayout()
        let collectionView = UICollectionView(frame: rect, collectionViewLayout: layout)
        self.collectionView = collectionView
        self.collectionView?.delegate = self
        self.collectionView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.collectionView?.backgroundColor = UIColor.lightGray
        self.collectionView?.alwaysBounceVertical = true
        self.view.addSubview(collectionView)
        
        LoadingDemoCell.register(for: collectionView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.lightGray
        let navigatorView = self.createNavigator()
        navigatorView.navigatorItem.title = "页面Loading"
        self.view.addSubview(navigatorView)
        self.zbNavigatorView = navigatorView
        
        self.addCollectionView()
        
        let button2 = UIButton(type: .custom)
        button2.frame = CGRect.init(x: self.view.width-80-10, y: 26, width: 80, height: 30)
        button2.setTitle("隐藏加载", for: .normal)
        self.view.addSubview(button2)
        button2.backgroundColor = UIColor.orange
        button2.addTarget(self, action: #selector(btn2Action(_:)), for: .touchUpInside)
        
        let model1 = LoadingDemoModel()
        self.model = model1
        model1.loadItems(nil, completion: { [weak self] (params) in
            self?.reloadData()
        }) { (err) in
            
        }
        self.reloadData()
    }
    
    override func reloadData(){
        guard let items =  self.model?.items else {
            return
        }
        let ds = ZGUIDemoRootDataSource.init(items: items as! Array<ZGBaseUIItem>)
        self.dataSource = ds
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = self.model?.items[indexPath.row] as? LoadingDemoItem else {
            return
        }
        guard let style = item.style else {
            return
        }
        self.style = style
        
        switch style {
        case .pageLoading:
            self.showPageLoading(item.text)
        case .popup:
            self.showPopupLoading(item.text)
        case .trasparent:
            self.showPageLoading("加载中", backgroundColor: UIColor.blue)
        }
    }
}

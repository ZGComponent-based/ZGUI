//
//  AlertDemoVCL.swift
//
//  Created by zhaogang on 2017/8/25.
//

import UIKit
import ZGUI

class AlertDemoVCL: ZGCollectionVCL {
    
    
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
        self.collectionView?.backgroundColor = UIColor.white
        self.collectionView?.alwaysBounceVertical = true
        self.view.addSubview(collectionView)
        
        AlertDemoCell.register(for: collectionView)
    } 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        let navigatorView = self.createNavigator()
        navigatorView.navigatorItem.title = "页面弹框"
        self.view.addSubview(navigatorView)
        self.zbNavigatorView = navigatorView
        
        self.addCollectionView()
                 
        let model1 = AlertDemoModel()
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
        guard let item = self.model?.items[indexPath.row] as? AlertDemoItem else {
            return
        }
        item.openAlertWindow()
    }
}

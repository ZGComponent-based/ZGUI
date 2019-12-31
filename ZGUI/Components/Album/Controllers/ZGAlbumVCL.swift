//
//  ZGAlbumVCL.swift
//  ZGUI
//
//  Created by zhaogang on 2017/11/3.
//

import UIKit

open class ZGAlbumVCL: ZGCollectionVCL {
    
    @objc func handleBtn(_ sender:Any) {
        self.dismiss(animated: true) { [weak self] in
            self?.gobackHandler?(nil)
        }
    }
    
    public func addCancelButton() {
        guard let navigatorView = self.zbNavigatorView else {return}
  
        let btnItem = UIBarButtonItem.init(title: "取消", style: .plain, target: self, action: #selector(self.handleBtn(_:)))
        btnItem.width = 40
        navigatorView.rightPadding = 10
        navigatorView.buttonFont = UIFont.systemFont(ofSize: 16)
        navigatorView.navigatorItem.rightBarButtonItem = btnItem
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.model = ZGAlbumModel()
        self.addNavigatorBar(leftImage:nil, title: "照片")
        self.addCollectionView()
        self.addCancelButton()
        guard let navigatorView = self.zbNavigatorView else {
            return
        }
        var cRect = self.view.bounds
        cRect.origin.y = navigatorView.height
        cRect.size.height = cRect.height - cRect.origin.y
        self.collectionView?.frame = cRect
        
        self.view.backgroundColor = UIColor.white
        self.collectionView?.backgroundColor = self.view.backgroundColor
        self.registerClass()
        self.loadItems()
    }
    
    open override func registerClass(){
        super.registerClass()
        guard let collectionView = self.collectionView  else {
            return
        }
        ZGAlbumCell.register(for: collectionView)
    }
    
    open override func loadItems() {
        self.model?.loadItems(nil, completion: {[weak self] (params) in
 
            self?.reloadData()
            }, failure: { [weak self](err) in
                
        })
    }
    
    open override func reloadData(){
        guard let items =  self.model?.items as? [ZGBaseUIItem],
            let collectionView = self.collectionView else {
                return
        }
        let model1:ZGAlbumModel = self.model as! ZGAlbumModel
        
        let ds = ZGCollectionViewDataSource.init(items: items)
        self.dataSource = ds
    }
    
    //MARK: - UICollectionView
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        var pItems:[ZGBaseUIItem]? = self.dataSource?.items
        
        if let sItems = self.dataSource?.sectionItems {
            pItems = sItems[indexPath.section]
        }
        
        guard let items = pItems else {
            return
        }
        
        guard let item = items[indexPath.row] as? ZGAlbumItem else {
            return
        }
        
        let albulmVCL = ZGAlbumCollectionVCL()
        var param = [String:Any]()
        param["item"] = item
        albulmVCL.setParameters(param)
        albulmVCL.callback = self.gobackHandler
        self.navigationController?.pushViewController(albulmVCL, animated: true)
        
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }
}

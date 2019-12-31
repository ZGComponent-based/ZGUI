//
//  ZGAlbumCollectionVCL.swift
//  ZGUI
//
//  Created by zhaogang on 2017/11/3.
//

import UIKit
import ZGCore

public typealias ZGAlbumGoBackHandler = (_ params: [String: Any]?) -> Void

class ZGAlbumCollectionVCL: ZGCollectionVCL {
    weak var bottomView:ZGAlbumBottomView!
    var callback:ZGAlbumGoBackHandler?
    
    override func getLoadingFrame() -> CGRect {
        if let rect = self.collectionView?.frame {
            return rect
        }
        var pRect =  self.view.frame
        pRect.origin.y = ZGUIUtil.statusBarHeight()
        pRect.size.height -= ZGUIUtil.statusBarHeight()
        return pRect
    }

    @objc func handleBtn(_ sender:Any) {
        self.dismiss(animated: true) { [weak self] in
            self?.callback?(self?.paramDict)
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
    
        guard let item = self.paramDict?["item"] as? ZGAlbumItem else {
            return
        }
        var title = "照片"
        if let t1 = item.title {
            title = t1
        }
        self.model = ZGAlbumCollectionModel(assets:item.assets)
        let backImage = ZGUIUtil.bundleForImage("goback_btn.png")
        self.addNavigatorBar(leftImage:backImage, title: title)
        self.addCollectionView()
        self.addCancelButton()
        guard let navigatorView = self.zbNavigatorView else {
            return
        }
        var cRect = self.view.bounds
        cRect.origin.y = navigatorView.height
        cRect.size.height = cRect.height - cRect.origin.y - 44
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
        ZGAlbumCollectionCell.register(for: collectionView)
    }
    
    open override func loadItems() {
        self.model?.loadItems(nil, completion: {[weak self] (params) in
            
            self?.reloadData()
            }, failure: { [weak self](err) in
                
        })
    }
    
    open override func reloadData(){
        guard let items =  self.model?.items as? [ZGBaseUIItem],
            let collectionModel = self.model as? ZGAlbumCollectionModel,
            let collectionView = self.collectionView else {
                return
        }
        if items.count < 1 {
            self.showPageTip(title: "暂无数据", detail: nil, imageBundle: nil, isEmpty: true)
            return
        }
        
        let ds = ZGCollectionViewDataSource.init(items: items)
        self.dataSource = ds
        
        let row:Int = items.count - 1
        var indexPath = IndexPath.init(row: row, section: 0)
        self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: false)
        
        
        guard let bottomItem = collectionModel.bottomItem else {
            return
        }
        
        if self.bottomView == nil {
            let view1 = bottomItem.view()
            self.view.addSubview(view1)
            self.bottomView = view1 as? ZGAlbumBottomView
            var rect = view1.frame
            rect.origin.y = self.view.height - rect.height
            view1.frame = rect
        }
        self.bottomView?.setItem(bottomItem)
    }
    
    //MARK: - UICollectionView
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        var pItems:[ZGBaseUIItem]? = self.dataSource?.items
        
        if let sItems = self.dataSource?.sectionItems {
            pItems = sItems[indexPath.section]
        }
        
        guard let items = pItems, let albumModel = self.model as? ZGAlbumCollectionModel else {
            return
        }
        
        guard let item = items[indexPath.row] as? ZGAlbumCollectionItem, let bottomItem = albumModel.bottomItem else {
            return
        }
    
        albumModel.resetBottomItem()
        let vcl = ZGAlbumPreviewVCL()
        var param = [String:Any]()
        param["selectedItem"] = item
        param["bottomItem"] = bottomItem
        vcl.setParameters(param)
        self.navigationController?.pushViewController(vcl, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let albumCell = cell as? ZGAlbumCollectionCell,
            let collectionModel = self.model as? ZGAlbumCollectionModel else {
                return
        }
  
        if let item = albumCell.item as? ZGAlbumCollectionItem {
            item.countHandler = {[weak self] in
                let count1 = collectionModel.getSelectedCount()
                if count1 > 9 {
                    self?.showTextTip("最多只能选择9个")
                } else {
                    collectionModel.resetBottomItem()
                    if let bottomItem = collectionModel.bottomItem {
                        self?.bottomView?.setItem(bottomItem)
                    }
                }
                return count1
            }
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return ZGAlbumCollectionService.spacing
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let spacing = ZGAlbumCollectionService.spacing
        return UIEdgeInsets.init(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }

}

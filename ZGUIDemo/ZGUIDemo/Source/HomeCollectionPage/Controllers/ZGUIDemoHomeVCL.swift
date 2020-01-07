//
//  ZGUIDemoHomeVCL.swift
//  ZGUIDemo
//
//  Created by temp on 2017/3/23.
//
//

import UIKit
import ZGUI

class ZGUIDemoHomeVCL: ZGCollectionVCL {
    override func collectionViewLayout() -> UICollectionViewLayout{
        // 可以折叠
        let layout : ZGCollectionViewStickFlowLayout = ZGCollectionViewStickFlowLayout()
        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        return layout
        
        //不可以折叠
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        if #available(iOS 9.0, *) {
//            layout.sectionHeadersPinToVisibleBounds = false
//        } else {
//            // Fallback on earlier versions
//        }
//        return layout
    }
    
    deinit {
        print("release \(self)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        let navigatorView = self.createNavigator()
        navigatorView.navigatorItem.title = "CollectionView"
        self.view.addSubview(navigatorView)
        self.zbNavigatorView = navigatorView
        
        if self.collectionView == nil {
            var rect = self.view.bounds
            rect.origin.y = self.zbNavigatorView!.height
            rect.size.height = rect.height - rect.origin.y
            self.createCollectionView(rect)
            self.collectionView?.backgroundColor = UIColor.lightGray
        }
        self.registerClass()
        self.model = ZGUIDemoHomeModel()

        self.loadItems()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.lightGray
    }
    
    override func loadItems() {
        
        self.model?.loadItems(nil, completion: { [weak self](dict) in
            self?.reloadData()
        }, failure: { (error) in
            
        })
    }
    
    override func reloadData(){
        guard let items =  self.model?.items else {
            return
        }
        let ds = ZGUIDemoHomeDataSource.init(sectionItems:items as! Array<Array<ZGBaseUIItem>>, sections:self.model?.sections)
        self.dataSource = ds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    open override func registerClass(){
        super.registerClass()
        self.collectionView?.register(ZGUIDemoHomeCell.self, forCellWithReuseIdentifier: ZGUIDemoHomeCell.tbbzIdentifier())
        
        self.collectionView?.register(ZGUIDemoHomeHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ZGUIDemoHomeHeaderView.tbbzIdentifier())
        self.collectionView?.register(ZGUIDemoHomeHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: ZGUIDemoHomeHeaderView.tbbzIdentifier())
    }

    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 10
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 10
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    //MARK: - ZGHPaginationSubViewDelegate
    
    override func getView() -> UIView {
        return self.view
    }
    
    override func setObject(_ object: Any) {
   
    }
    
    override func prepareForReuse() {
        self.removeFromParent()
    }
    
    override func reuseIdentifier() -> String {
        return "ZGUIDemoHomeVCL"
    }
}

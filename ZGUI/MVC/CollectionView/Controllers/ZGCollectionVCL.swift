//
//  ZGCollectionVCL.swift
//  ZGUIDemo
//

//
//

import UIKit


open class ZGCollectionVCL: ZGScrollVCL,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
 
    @IBOutlet weak public var collectionView : UICollectionView?
    
    private var _dataSource:ZGCollectionViewDataSource?
    public var dataSource:ZGCollectionViewDataSource? {
        get {
            return _dataSource
        }
        set (newValue) {
            if newValue != _dataSource {
                _dataSource = newValue
            }
            self.collectionView?.dataSource = newValue
        }
    }
    
    deinit {
        self.collectionView?.delegate = nil
        self.collectionView?.dataSource = nil
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        //self.collectionView?.collectionViewLayout = self.collectionViewLayout()
        // Do any additional setup after loading the view.
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
     
    open func addCollectionView() {
        if self.collectionView != nil {
            return
        }
        
        var rect = self.view.bounds
        rect.origin.y = ZGUIUtil.statusBarHeight() + 44
        rect.size.height = self.view.height - rect.origin.y
        
        let layout =  self.collectionViewLayout()
        let collectionView = UICollectionView(frame: rect, collectionViewLayout: layout)
        self.collectionView = collectionView
        self.collectionView?.delegate = self
        self.collectionView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.collectionView?.backgroundColor = UIColor.white
        self.collectionView?.alwaysBounceVertical = true
        self.view.addSubview(collectionView)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    open func createCollectionView(_ frame: CGRect){
        let layout = self.collectionViewLayout()
        let collection = UICollectionView.init(frame: frame, collectionViewLayout: layout)
        collection.backgroundColor = .white
        collection.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.collectionView = collection
        self.view.addSubview(self.collectionView!)
        self.collectionView?.delegate = self
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    open func collectionView (_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
                         sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView.dataSource is ZGCollectionViewDataSource) {
            let dc:ZGCollectionViewDataSource = self.collectionView?.dataSource as! ZGCollectionViewDataSource
            let object = dc.collectionView(collectionView, objectForRowAtIndexPath: indexPath)
            if let obj1 = object {
                let cellType = dc.collectionView(collectionView, cellClassForObject: obj1)
                return cellType.collectionView(collectionView, layout: collectionViewLayout, sizeForObject: obj1)
            }
        }
        return CGSize.zero
    }
     
    open func addRefreshView(){
        super.addRefreshView(toScrollView: self.collectionView)
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        
    }
    
    //override
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{
        if (collectionView.dataSource is ZGCollectionViewDataSource) {
            let dc:ZGCollectionViewDataSource = self.collectionView?.dataSource as! ZGCollectionViewDataSource
            let object = dc.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, objectForSection: section)
            if let obj = object{
                let viewType = dc.collectionView(collectionView, reusableViewClassForObject: obj)
                return viewType.collectionView(collectionView: collectionView, layout: collectionViewLayout, sizeForObject: obj)
            }
        }
        return CGSize.zero
    }
    
    //override
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize{
        if (collectionView.dataSource is ZGCollectionViewDataSource) {
            let dc:ZGCollectionViewDataSource = self.collectionView?.dataSource as! ZGCollectionViewDataSource
            let object = dc.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionFooter, objectForSection: section)
            if let obj = object{
                let viewType = dc.collectionView(collectionView, reusableViewClassForObject: obj)
                return viewType.collectionView(collectionView: collectionView, layout: collectionViewLayout, sizeForObject: obj)
            }
        }
        return CGSize.zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 5
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 5
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    //MARK: - Register Class
    open func registerClass(){
        if let cView = self.collectionView{
            ZGCollectionReusableView.register(for: cView, kind: UICollectionView.elementKindSectionHeader)
            ZGCollectionReusableView.register(for: cView, kind: UICollectionView.elementKindSectionFooter)
        }
    }
    
    //MARK: - 子类可以重写设置layout
    open func collectionViewLayout() -> UICollectionViewLayout{
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        return layout
    }
    
    //MARK: -
    open func closeRefreshLoading(animated:Bool=false) {
        super.closeRefreshLoading(animated: animated, scrollView: self.collectionView)
    }
    
    public func startRefreshLoading() {
        super.startRefreshLoading(scrollView: self.collectionView)
    }
    
}



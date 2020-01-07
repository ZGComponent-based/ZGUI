//
//  ZGUIDemoHomeVCL.swift
//  ZGUIDemo
//
//  Created by temp on 2017/3/23.
//
//

import UIKit
import ZGUI
import ZGCore

extension  ZGBaseViewCTL {
    @objc func goBack1() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func createNavigator() -> ZGNavigatorView {
        var frame = self.view.bounds
        frame.size.height = ZGUIUtil.statusBarHeight() + 44
        let tbnavigator1 = ZGNavigatorView(frame: frame)
        let naviItem = ZGNavigatorItem()
        naviItem.title = "swift"
        let btnImage = ZGImage("bundle://common_goback_btn@2x.png")
        let bgImage = ZGImage("bundle://common_navbar_bg@2x.png")
        let leftBtnItem = UIBarButtonItem.init(image: btnImage,
                                               style: UIBarButtonItem.Style.plain,
                                               target: self,
                                               action: #selector(goBack1))
        naviItem.leftBarButtonItem = leftBtnItem
        
        tbnavigator1.navigatorItem = naviItem
        
        tbnavigator1.titleColor = UIColor.black
        tbnavigator1.buttonFont = UIFont.systemFont(ofSize: 14)
        tbnavigator1.titleFont = UIFont.systemFont(ofSize: 17)
        tbnavigator1.layer.contents = bgImage?.cgImage
        
        return tbnavigator1
    }
}

class ZGUIDemoRootVCL: ZGCollectionVCL {
    @IBOutlet weak var tbnavigator: ZGNavigatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerClass()
        let model1 = ZGUIDemoRootModel()
        self.model = model1
        model1.items = model1.rootItems()
        self.reloadData()
        self.initTBNavigator()
 
        
//        let vie1 = UIImageView(frame:CGRect.init(x: 0, y: 180, width: self.view.width, height: 91))
//        self.view.addSubview(vie1)
//        vie1.backgroundColor = UIColor.white
//        if var image = ZGImage("bundle://coupon_bg@2x.png") {
//            image = image.resizableImage(withCapInsets: UIEdgeInsets.init(top: 0, left: 20, bottom: 10, right: 80), resizingMode:.stretch)
//            
//            vie1.image = image
//        }
    }
    
    func initTBNavigator() {
        let naviItem = ZGNavigatorItem()
        naviItem.title = "swift"
        
        let leftBtnItem = UIBarButtonItem.init(image: UIImage.init(named: "common_goback_btn@2x.png"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(goBack))
        naviItem.leftBarButtonItem = leftBtnItem
        
        let rightBtnItem = UIBarButtonItem.init(title: "编辑", style: UIBarButtonItem.Style.plain, target: self, action: #selector(edit))
        let rightBtnItem2 = UIBarButtonItem.init(title: "取消", style: UIBarButtonItem.Style.plain, target: self, action: #selector(edit))
        naviItem.rightBarButtonItems = [rightBtnItem,rightBtnItem2]
        if tbnavigator != nil{
            tbnavigator.navigatorItem = naviItem
            
            tbnavigator.titleColor = UIColor.white
            tbnavigator.buttonFont = UIFont.systemFont(ofSize: 14)
            tbnavigator.titleFont = UIFont.systemFont(ofSize: 30)
            tbnavigator.setBackgroundImage(image: UIImage.init(named: "navi_bar_back.png")!)
        }

    }
    
    @objc func edit() {
        print("start edit")
    }
    
    @objc func goBack() {
        print("goBack Action")
    }
 
    override func reloadData(){
        guard let items =  self.model?.items else {
            return
        }
        let ds = ZGUIDemoRootDataSource.init(items: items as! Array<ZGBaseUIItem>)
        self.dataSource = ds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    open override func registerClass(){
        super.registerClass()
        self.collectionView?.register(ZGUIDemoRootCell.self, forCellWithReuseIdentifier: ZGUIDemoRootCell.tbbzIdentifier())
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
     
        let item = self.model?.items[indexPath.row]
        if let rItem = item {
            let rootItem = rItem as! ZGUIDemoRootItem
            switch rootItem.type {
            case .image:
                self.openImagePage()
            case .home:
                self.openHomePage()
            case .hScroll:
                self.openPageScrollVCL()
            case .refresh:
                self.openRefreshPage()
            case .cycle:
                self.openCyclePage()
            case .preview:
                self.openPrieViewPage()
            case .loading:
                self.openLoadingPage()
            case .toast:
                self.openToastPage()
            case .pageTip:
                self.openPageTip()
            case .alert:
                self.openPageAlert()
            case .album:
                self.openPageAlbum()
            case .qrcode:
                self.openPageQRCode()
            case .slideScale:
                self.openSlideScale()
            case .table:
                self.openTableDemo()
            case .HVScroll:
                self.openHVScrollPage()
            }

        }
    }
    
    func openHVScrollPage() {
        let vcl = HVSCrollVCL()
        self.navigationController?.pushViewController(vcl, animated: true)
    }
    
    func openTableDemo() {
        let nav = ZGNaviController()
        let vcl = TableViewDemoVCL()
        nav.pushViewController(vcl, animated: false)
        self.navigationController?.present(nav, animated: true, completion: nil)
        
//        self.navigationController?.pushViewController(vcl, animated: true)
    }
    
    func openSlideScale() {
        let vcl = ZGSlideScaleDemo()
        self.navigationController?.pushViewController(vcl, animated: true)
    }
    
    func openPageQRCode() {
        let vcl = QRCodeDemoVCL()
        self.navigationController?.pushViewController(vcl, animated: true)
    }
    
    func openPageAlbum() {
        let vcl = ZGAlbumVCL()
        self.navigationController?.pushViewController(vcl, animated: true)
    }
    
    func openPageAlert() {
        let vcl = AlertDemoVCL()
        self.navigationController?.pushViewController(vcl, animated: true)
    }
    
    func openPageTip() {
        let vcl = PageTipDemoVCL()
        self.navigationController?.pushViewController(vcl, animated: true)
    }
    
    func openToastPage() {
        let vcl = ToastDemoVCL()
        self.navigationController?.pushViewController(vcl, animated: true)
    }
    
    func openLoadingPage() {
        let vcl = LoadingDemoVCL()
        self.navigationController?.pushViewController(vcl, animated: true)
    }
    
    func openPrieViewPage() {
        let vcl = PreviewDemoVCL()
        self.navigationController?.pushViewController(vcl, animated: true)
    }
    
    func openCyclePage() {
        let vcl = ZGUICycleDemoVCL()
        self.navigationController?.pushViewController(vcl, animated: true)
    }
    
    func openImagePage() {
        let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.init(for: ZGUIDemoRootVCL.self))
        let vcl = storyBoard.instantiateViewController(withIdentifier: "ViewController")
        self.navigationController?.pushViewController(vcl, animated: true)
    }
    
    func openHomePage() {
        let vcl = ZGUIDemoHomeVCL()
        self.navigationController?.pushViewController(vcl, animated: true)
    }
    
    func openPageScrollVCL() {
        let vcl = ZGUIDemoPageScrollVCL()
        self.navigationController?.pushViewController(vcl, animated: true)
    }
    
    func openRefreshPage() { 
        
        let vcl = RefreshCVCL()
        self.navigationController?.pushViewController(vcl, animated: true)
    }
}

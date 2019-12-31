//
//  ZGBaseViewCTL.swift
//  ZGUIDemo
//
//
//

import UIKit
import ZGCore
import ZGNetwork

public typealias ZGGoBackHandler = (_ params: [String: Any]?) -> Void

public class ZGError : NSObject {
    public var networkError:ZGNetworkError?
    public var userInfo:[String:Any]?
    public var errorMessage:String?
}

open class ZGBaseViewCTL: UIViewController, ZGHPaginationSubViewDelegate {
    open var paramDict : [String:Any]?
    open var model : ZGModel!
    open var zbNavigatorView: ZGNavigatorView?
    open var gobackHandler: ZGGoBackHandler?
    
    open weak var pageTipView:ZGPageTipView?
    
    public var topbarItem: ZGTopScrollBarBaseItem?
    open var index: Int = 0
    
    @objc open func goBackFromNavigation() {
        self.goBack(animated: true)
    }
    
    open func addNavigatorBar(leftImage:String?, title:String) -> Void {
        var frame = self.view.bounds
        frame.size.height = ZGUIUtil.statusBarHeight() + 44
        let tbnavigator = ZGNavigatorView(frame: frame)
        let naviItem = ZGNavigatorItem()
        naviItem.title = title
        
        if let leftImage = leftImage {
            let btnImage = ZGImage(leftImage)
            let leftBtnItem = UIBarButtonItem.init(image: btnImage,
                                                   style: UIBarButtonItem.Style.plain,
                                                   target: self,
                                                   action: #selector(self.goBackFromNavigation))
            leftBtnItem.width = 40
            naviItem.leftBarButtonItem = leftBtnItem
        }
        
        tbnavigator.navigatorItem = naviItem
        tbnavigator.leftPadding = 10
        
        tbnavigator.titleColor = UIColor.black
        tbnavigator.buttonFont = UIFont.systemFont(ofSize: 14)
        tbnavigator.titleFont = UIFont.systemFont(ofSize: 17)
        tbnavigator.backgroundColor = UIColor.white
        
        self.view.addSubview(tbnavigator)
        self.zbNavigatorView = tbnavigator
    }
    
    func mainWindow() -> UIWindow? {
        if let window = UIApplication.shared.delegate?.window {
            return window
        }
        return nil
    }
    
    //需要子类重写, 并且调用基类
    open func reloadData(){
        
    }
    
    //在 gobackHandler之前调用
    open func preGoBack() {
        
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //传递参数
    open func setParameters(_ paramters : [String:Any]?){
        self.paramDict = paramters
    }
    
    open func goBack(animated:Bool = true) {
        self.preGoBack()
        self.gobackHandler?(self.paramDict)
        if let presentingViewController = self.presentingViewController {
            if let count = self.navigationController?.viewControllers.count {
                if count > 1 {
                    self.navigationController?.popViewController(animated: animated)
                } else {
                    self.dismiss(animated: animated, completion: nil)
                }
            } else {
                self.dismiss(animated: animated, completion: nil)
            }
        } else {
            self.navigationController?.popViewController(animated: animated)
        }
    }
    
    // MARK: - Loading相关的方法
    
    /// Loading窗口展示的位置
    /// - returns: Loading展示的区域
    open func getLoadingFrame() -> CGRect {
        let y = ZGUIUtil.statusBarHeight() + 44
        let height = self.view.frame.height - y
        let frame = CGRect(x: 0, y: y, width: self.view.width, height: height)
        return frame
    }
    
    /// 页面平铺展示Loading，展示在#getLoadingFrame()返回的区域
    ///
    /// - parameter text:        Loading提示，默认为nil
    /// - parameter isTransparent:  true:背景透明， false：不透明
    open func showPageLoading(_ text:String? = nil,inView:UIView? = nil, backgroundColor:UIColor = UIColor.clear,frame:CGRect? = CGRect(x: 0, y:ZGUIUtil.statusBarHeight() + 44 , width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - ZGUIUtil.statusBarHeight() - 44)) {
        if let inView = inView {
            ZGLoadingBox.showLoading(frame: frame!, inView: inView, tipString: text, backgroundColor:backgroundColor)
        } else {
            ZGLoadingBox.showLoading(frame: frame!, inView: self.view, tipString: text, backgroundColor:backgroundColor)
        }
    }
    
    open func hidePageLoading(inView:UIView? = nil) {
        if let inView = inView {
           ZGLoadingBox.hideLoading(inView)
        } else {
           ZGLoadingBox.hideLoading(self.view)
        }
    }
    
    open func showTextTip(_ text:String) {
        guard let window = self.mainWindow() else{
            return
        }
        ZGUIToastView.showInView(window, text: text)
    }
    
    /// 用于登录、或有数据时的弹窗加载
    ///
    /// - parameter text: 提示文字
    /// - parameter isTransparent:  true:背景透明， false：不透明
    open func showPopupLoading(_ text:String? = nil) {
        let loadingFrame = self.getLoadingFrame()
        guard let window = self.mainWindow() else {
            return
        }
        ZGLoadingBox.showLoading(frame: loadingFrame, inView: window, tipString: text, popup: true)
    }
    
    open func hidePopupLoading() {
        guard let window = self.mainWindow() else {
            return
        }
        ZGLoadingBox.hideLoading(window)
    }
    
    open func dealError(_ error:ZGNetworkError) {
        
    }
    
    open func didClickPageTipView(item:ZGPageTipItem) {
        
    }
    
    /// 页面平铺展示提示信息，展示在#getLoadingFrame()返回的区域
    /// 错误类型包括无数据、网络错误等
    ///
    /// - parameter title:   默认为nil
    /// - parameter detail:   默认为nil
    /// - parameter buttonTitle:   默认为nil
    /// - parameter error:   默认为nil
    /// - parameter imageBundle: 背景图片(title, detail, buttonTitle同时为nil, 320*200)，  默认为nil; 另外一种模式是图片(115*140)、标题、描述、按钮的展示
    /// - parameter isEmpty:  是否为无数据的提示， 默认为false
    open func showPageTip(title:String? = nil,
                          titleFont:String? = nil,
                          titleColor:String? = nil,
                          face:String? = nil,
                          detail:String? = nil,
                          isHomeworkDetail:Bool = false,
                          buttonTitle:String? = nil,
                          error:ZGNetworkError? = nil,
                          imageBundle:String? = nil,
                          imageSize:CGSize? = nil,
                          view:UIView? = nil,
                          isEmpty:Bool = false,frame:CGRect? = CGRect(x: 0, y: ZGUIUtil.statusBarHeight() + 44, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - ZGUIUtil.statusBarHeight() - 44)) {
        if self.pageTipView == nil {
            if let frame = frame {
                let loadingFrame = frame
                let item = ZGPageTipItem(title: title,
                                         titleFont:titleFont,
                                         titleColor:titleColor,
                                         face:face,
                                         detail: detail,
                                         isHomeworkDetail:isHomeworkDetail,
                                         buttonTitle: buttonTitle,
                                         error: error,
                                         imageBundle: imageBundle,
                                         imageSize:imageSize,
                                         isEmpty: isEmpty,
                                         size:frame.size)
                
                let pView = ZGPageTipView(frame: frame)
                if view == nil{
                    self.view.addSubview(pView)
                }else{
                    view!.addSubview(pView)
                }
                pView.backgroundColor = UIColor.white
                pView.setTipItem(item)
                self.pageTipView = pView
                pView.tipHandler = {[weak self](item) in
                    self?.didClickPageTipView(item: item)
                }
            }
        }
    }
    
    open func hidePageTip() {
        guard let pageTip = self.pageTipView else {
            return
        }
        pageTip.removeFromSuperview()
        self.pageTipView = nil
    }
    
    
    // MARK: - ZGHPaginationSubViewDelegate Methods
    
    open func getView() -> UIView {
        return self.view
    }
    
    open func setObject(_ object: Any) {
        if let item = object as? ZGTopScrollBarBaseItem{
            self.topbarItem = item
        }
    }
    
    open func prepareForReuse() {
        self.removeFromParent()
    }
    
    open func reuseIdentifier() -> String {
        if let item = topbarItem{
            return item.pageReuseIdentifier
        }
        return "\(self)"
    }
    
}


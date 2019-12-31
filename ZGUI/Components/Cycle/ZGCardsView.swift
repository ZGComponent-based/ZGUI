//
//  ZGCardsView.swift
//  Pods
//  Created by zhaogang on 2017/6/6.
//
//

import UIKit
import ZGCore
import ZGNetwork

public class ZGCardItem {
    public var imageUrl:String!
    public var title:NSAttributedString?
    public var nextBgImageUrl:String?
    public var userData:Any?
    public var id:Int?
    public init(){}
}

public class ZGCardsItemView :UIView {
    
    var item:ZGCardItem?
    weak var imageView:ZGImageView!
    weak var nextTipLabel:UILabel!
    weak var nextTipBg:ZGImageView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        let view1 = ZGImageView(frame:frame)
        self.imageView = view1
        self.addSubview(view1)
        
        let view2 = ZGImageView(frame:CGRect.init(x: frame.size.width-135, y: 0, width: 135, height: 16))
        self.addSubview(view2)
        self.nextTipBg = view2
        
        var labelFrame = self.nextTipBg.frame
        labelFrame.origin.x = 0
        labelFrame.size.width = frame.size.width - 44
        let label = UILabel(frame:labelFrame)
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 9)
        label.textColor = .white
        self.addSubview(label)
        self.nextTipLabel = label
        self.nextTipLabel.textAlignment = .right 
        self.imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.isUserInteractionEnabled = false
        
        self.imageView.backgroundColor = UIColor .color(withHex: 0xEEE0E5)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setItem(_ item:ZGCardItem) {
        self.item = item
        self.nextTipBg.urlPath = item.nextBgImageUrl
        if let id = item.id {
//            self.analysis_parameter = String(id)
        }
        
    }
    
    public func setNextTip(_ nextText:NSAttributedString?) {
        self.nextTipLabel.attributedText = nextText
    }
    
    func nextTipEnable(_ enable:Bool) {
        self.nextTipBg.isHidden = !enable
        self.nextTipLabel.isHidden = self.nextTipBg.isHidden
    }
    
    func prepareForReuse() {
        self.nextTipLabel.attributedText = nil
        self.imageView.unsetImage()
    }
}

public class ZGCardsView: UIView , UIGestureRecognizerDelegate {
    public typealias CardsTapHandler = (ZGCardItem) -> Void
    static let speedRatio:CGFloat = 10
    
    public enum CardsDirection : Int {
        case none = 0
        case left = 1
        case right = 2
    }
    
    public weak var pageControl:ZGWaterDropPageControl!
    var isPan:Bool = false
    var isBegin:Bool = false
    var canMove:Bool = false
    var direction:CardsDirection = .none
    var originPoint:CGPoint = .zero
    public var tapHandler:CardsTapHandler?
    
    var urlCache:[String:ZGCardItem]
    var items:[ZGCardItem]?
    var _timeInterval:TimeInterval = 3
    var timeInterval:TimeInterval {
        get {
            return _timeInterval
        }
        set {
            _timeInterval = newValue
            self.timer.timeInterval = timeInterval
        }
    }
    var timer:ZGCoreTimer
    public var cardViews:[ZGCardsItemView]?
    public var enableShowNextTip:Bool = false //下一帧主题预告
    
    var _currentIndex:Int = 0
    public var currentIndex:Int {
        get {
            return _currentIndex
        }
        set {
            _currentIndex = newValue
        }
    }
    
    @objc func didTap(sender:UITapGestureRecognizer) {
        guard let tapHandler = self.tapHandler else {
            return
        }
        guard let items = self.items else {
            return
        }
        if _currentIndex > items.count-1  {
            return
        }
        tapHandler(items[_currentIndex])
        
    }
    
    func addGestureRecognizers() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGesture(pan:)))
        pan.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
        self.addGestureRecognizer(pan)
        self.addGestureRecognizer(tap)
    }
    
    public required init(frame: CGRect, pageControlStyle:ZGWaterDropPageControl.PageControlStyle = .right) {
        self.urlCache = [String:ZGCardItem]()
        self.timer = ZGCoreTimer(timeInterval:_timeInterval)
        
        super.init(frame: frame)
        let cRect = CGRect.init(x: 0, y: frame.height-26, width: frame.size.width, height: 20)
        let pControl = ZGWaterDropPageControl(frame:cRect, style:pageControlStyle)
        self.addSubview(pControl)
        self.pageControl = pControl
        
        self.pageControl.currentPage = 0
        self.pageControl.isUserInteractionEnabled = false
        
        self.addGestureRecognizers()
        self.timer.timerBlock = {[weak self] (timer) in
            self?.fireTimer()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getBottomCard() -> ZGCardsItemView? {
        guard let items = self.items, let cardViews = self.cardViews else {
            return nil
        }
        if items.count>1 && cardViews.count > 1 {
            return cardViews[1]
        }
        return nil
    }
    
    func changeCenterCardView() {
        guard let items = self.items, let bottomCard = self.getBottomCard() else {
            return
        }
        
        var index:Int = _currentIndex + 1
        //向左滑显示下一张
        index = _currentIndex + 1
        if (_currentIndex == items.count-1) {
            index = 0
        }
        
        var frame = bottomCard.frame
        let offset:CGFloat = self.width/ZGCardsView.speedRatio
        frame.origin.x = offset
        bottomCard.frame = frame
        bottomCard.prepareForReuse()
        self.setBottomDataAtIndex(index)
    }
    
    func fireTimer() {
        self.isPan = true
        
        self.direction = .left
        self.changeCenterCardView()
        
        self.resetCurrentCardView(top: top) {[weak self] (finished) in
            self?.isPan = false
            self?.direction = .none
        }
        
        UIView.animate(withDuration: 0.3) { 
            self.pageControl.moveWaterDrop()
        }
    }
    
    public func setCards(_ cards:[ZGCardItem]) {
        self.stopTimer()
        self.urlCache.removeAll()
        
        if cards.count < 1 {
            return
        }
        self.items = cards
        self.pageControl.numberOfPages = CGFloat(cards.count)
        if _currentIndex >= cards.count {
            self.currentIndex = 0
        }
        self.loadData()
        self.layoutSubviews()
        self.startTimer()
    }
    
    deinit {
        self.stopTimer()
    }
    
    public func startTimer() {
        self.stopTimer()
        
        guard let items = self.items else {
            return
        }
        if items.count < 2 {
            return
        }
        self.timer.start()
    }
    
    public func stopTimer() {
        self.timer.stop()
    }
    
    // MARK: - 加载视图
    func loadData() {
        self.pageControl.setCurrentPageAndMoveWaterDropWithoutAnimationToIndex(self.currentIndex)
        if cardViews == nil {
            cardViews = [ZGCardsItemView]()
            for _ in 0 ..< 3 {
                let rect = CGRect.init(x: 0, y: 0, width: self.width, height: self.height)
                let cardView = ZGCardsItemView(frame: rect)
                self.addSubview(cardView)
                cardViews?.append(cardView)
                originPoint = cardView.center
            }
            cardViews?.reverse()
        }
        
        guard let cardViews = self.cardViews else {
            return
        }
        let cardCount = cardViews.count
        for i in 0 ..< cardCount {
            let card = cardViews[i]
            self.loadSubView(card, index: i+_currentIndex)
        }
        
        self.bringSubviewToFront(self.pageControl)
    }
    
    func keyForUrl(_ url:String) -> String {
        return ZGURLCache.sharedInstance.keyForURL(url)
    }
    
    func loadSubView(_ subView:ZGCardsItemView, index:Int) {
        guard let items = self.items else {
            return
        }
        let count:Int = items.count
        
        if count < 1 {
            return
        }
        if count < index+1 {
            return
        }
        
        self.showNextTipText(cartView: subView, i: index)
        
        //        [self setAnalysisData:card.bannerVo];
        let item:ZGCardItem = items[index]
        subView.setItem(item)
//        self.analysis_parameter = subView.analysis_parameter
        
        if let image1 = ZGURLCache.sharedInstance.imageForUrl(item.imageUrl, fromDisk: false) {
            subView.imageView.setImage(image1, enableAnimation: false)
        } else {
            DispatchQueue.global(qos:.userInitiated).async {
                
                let image = ZGImage(item.imageUrl)
                
                DispatchQueue.main.async {
                    if image == nil {
                        
                        self.downloadImage(item: item)
                    } else {
                        self.resetImageForItem(item, image: image)
                    }
                }
            }
        }
        
        self.isHidden = false
    }
    
    func setBottomDataAtIndex(_ index:Int) {
        guard let cardView:ZGCardsItemView = self.getBottomCard() else {
            return
        }
        self.loadSubView(cardView, index: index)
    }
    
    func changeSubCardView() {
        guard let cardViews = self.cardViews, let items = self.items else {
            return
        }
        
        if cardViews.count < 2 || items.count < 2 {
            return
        }
        
        let cardView:ZGCardsItemView = cardViews[0]
        var index:Int = 0
        var offset:CGFloat = 0
        
        let lastDirect:CardsDirection = self.direction;
        
        if (cardView.left<0) {
            self.direction = .left
            //向左滑显示下一张
            index = _currentIndex+1
            if _currentIndex == items.count-1 {
                index = 0;
            }
            offset = self.width/ZGCardsView.speedRatio
        } else {
            self.direction = .right
            //向右滑显示上一张
            index = _currentIndex-1
            if (_currentIndex == 0) {
                index = items.count-1
            }
            offset = -(self.width/ZGCardsView.speedRatio)
        }
        
        guard let bottomCard = self.getBottomCard() else {
            return
        }
        var frame = bottomCard.frame
        if lastDirect != self.direction {
            frame.origin.x = offset;
        }
        bottomCard.frame = frame;
        
        
        self.setBottomDataAtIndex(index)
    }
    
    func showNextTipText(cartView:ZGCardsItemView, i:Int) {
        guard let items = self.items else {
            return
        }
        if items.count < 1 {
            return
        }
        var index = i + 1
        if (index >= items.count) {
            index = 0;
        }
        let item:ZGCardItem = items[index];
        cartView.setNextTip(item.title)
        if (self.enableShowNextTip) {
            //banner只有一帧，右上角不显示标题
            let enable:Bool = items.count > 1
            cartView.nextTipEnable(enable)
            
        }
    }
    
    func resetBottomCardFrame() {
        guard let cardViews = self.cardViews else {
            return
        }
        if cardViews.count < 2 {
            return
        }
        let cardView:ZGCardsItemView = cardViews[1] //底层card
        cardView.center = originPoint
    }
    
    // MARK: - 响应手势
    @objc func panGesture(pan:UIPanGestureRecognizer) {
        guard let cardViews = self.cardViews else {
            return
        }
        guard let items = self.items else {
            return
        }
        if cardViews.count < 2 {
            return
        }
        if items.count < 2 {
            return
        }
        self.stopTimer()
        if self.isPan {
            return
        }
        
        if pan.state == .changed {
            if !self.canMove {
                return
            }
            self.isBegin = true
            let offset = pan.translation(in: self)
            let dragView:ZGCardsItemView = cardViews[0]
            dragView.center = CGPoint.init(x:dragView.center.x + offset.x, y:dragView.center.y)
            pan.setTranslation(.zero, in: self)
            
            //水滴拉伸效果
            self.pageControl.waterDropView.setCurrentOffset(dragView.left)
            self.changeSubCardView()
            
            guard let bottomCard = self.getBottomCard() else {
                return
            }
            
            bottomCard.center = CGPoint.init(x:bottomCard.center.x+offset.x/ZGCardsView.speedRatio, y:bottomCard.center.y)
            
        } else if pan.state == .ended {
            if !self.isBegin {
                return
            }
            self.isBegin = false
            let endPoint = pan.velocity(in: self)
            
            let dragView:ZGCardsItemView = cardViews[0]
            if (dragView.left < -self.width/4.0 || dragView.left > self.width/4.0 || endPoint.x > 1000 || endPoint.x < -1000) {
                self.changedCurrentPageAfterpanGestureEnd(pan:pan)
            } else {
                self.resetCurrentPageAfterpanGestureEnd(pan: pan)
            }
            
            self.direction = .none
        }
    }
    
    func resetCurrentIndex() {
        guard let items = self.items else {
            return
        }
        if items.count < 1 {
            _currentIndex = 0
            return
        }
        if self.direction == .left {
            if (_currentIndex == items.count-1) {
                _currentIndex = 0
            }else{
                _currentIndex += 1
            }
        } else if self.direction == .right {
            if (_currentIndex == 0) {
                _currentIndex = items.count-1;
            }else{
                _currentIndex -= 1
            }
        }
        self.pageControl.currentPage = CGFloat(_currentIndex)
    }
    
    func removeCard(_ card:ZGCardsItemView) {
        guard let cardViews = self.cardViews else {
            return
        }
        var index:Int = 0
        for item in cardViews {
            if item === card {
                self.cardViews?.remove(at: index)
                break
            }
            index += 1
        }
    }
    
    func resetCurrentCardView(top:CGFloat, completion: @escaping ((Bool) -> Swift.Void)) {
        guard let cardViews = self.cardViews else {
            return
        }
        
        if cardViews.count < 1 {
            return
        }
        let cardView = cardViews[0]
        
        UIView.animate(withDuration: 0.4, animations: { 
            if self.direction == .left {
                cardView.right = 0
            } else {
                cardView.left = self.width
            }
            self.resetBottomCardFrame()
        }) { (finished) in
            
            self.removeCard(cardView)
            self.cardViews?.append(cardView)
            
            cardView.removeFromSuperview()
            cardView.prepareForReuse()
            self.insertSubview(cardView, at: 0)
            
            cardView.left = 0;
            completion(finished)
        }
        
        self.resetCurrentIndex()
    }
    
    func changedCurrentPageAfterpanGestureEnd(pan:UIPanGestureRecognizer) {
        if self.isPan {
            return
        }
        self.isPan = true
        let endPoint = pan.velocity(in: self)
        let top:CGFloat = endPoint.y > 0 ? self.height : -self.height
        self.resetCurrentCardView(top: top) {[weak self] (finished) in
            self?.startTimer()
            self?.isPan = false
            //v4.18.0 手动滑动时添加曝光
            //            [self startBannerExposure];
        }
    }
    
    func resetCurrentPageAfterpanGestureEnd(pan:UIPanGestureRecognizer) {
        guard let cardViews = self.cardViews else {
            return
        }
        guard self.items != nil else {
            return
        }
        if cardViews.count < 1 {
            return
        }
        let dragView:ZGCardsItemView = cardViews[0]
        UIView.animate(withDuration: 0.4, animations: { 
            dragView.center = self.originPoint
            dragView.transform = .identity
            
            //水滴拉伸效果恢复
            self.pageControl.waterDropView.setCurrentOffset(dragView.left)
        }) { (finished) in
            self.startTimer()
            self.isPan = false
        }
    }
    
    func resetImageForItem(_ item:ZGCardItem?, image:UIImage?) {
        guard let item = item else {
            return
        }
        guard let cardViews = self.cardViews else {
            return
        }
        if cardViews.count < 1 {
            return
        }
        for card in cardViews {
            guard let cItem = card.item else {
                continue
            }
            if cItem.imageUrl == item.imageUrl {
                card.imageView.setImage(image, enableAnimation: true)
            }
        }
    }
    
    func downloadImage(item:ZGCardItem) {
        guard let url = item.imageUrl else {
            return
        }
        let urlKey = self.keyForUrl(url)
        let item2 = self.urlCache[urlKey]
        
        if item2 != nil {
            //正在下载
            return
        } else {
            urlCache[urlKey] = item
        }
        
        func downloadProgress(progress: Progress) {
            //            print("当前进度：\(progress.fractionCompleted*100)%")
        }
        
        func downloadResponse(response: ZGNetworkDownloadResponse) {
            guard let urlString = response.request?.url?.absoluteString else {
                return
            }
            let urlKey = self.keyForUrl(urlString)
            let item = self.urlCache.removeValue(forKey: urlKey)
            
            if (response.isSuccess) {
                if let destinationURL = response.destinationURL {
                    if let data = try? Data(contentsOf: destinationURL) {
                        if let image:UIImage = ZGImageForData(data) {
                            ZGURLCache.sharedInstance.storeImage(image: image, forUrl: urlString)
                            self.resetImageForItem(item, image: image)
                            
                        }
                    }
                }
            }
        }
        let cachePath = ZGURLCache.sharedInstance.pathForUrl(url)
        let cacheUrl = URL(fileURLWithPath: cachePath)
        guard let downloadRequest = ZGNetwork.download(url, to:cacheUrl) else {
            return
        }
        downloadRequest.downloadProgress(queue: DispatchQueue.main,
                                         closure: downloadProgress) //下载进度
        downloadRequest.responseData(completionHandler: downloadResponse) //下载停止响应
    }
    
    // MARK: - UIGestureRecognizerDelegate Methods
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        self.canMove = true
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer {
            let pan:UIPanGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
            let endPoint = pan.translation(in: self)
            if endPoint.x != 0 {
                return false
            } else if (endPoint.y != 0){
                self.canMove = false
                return true
            }
        }
        
        return false
    }
    
}

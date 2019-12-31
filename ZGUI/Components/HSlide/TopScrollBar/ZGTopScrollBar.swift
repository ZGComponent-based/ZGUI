//
//  ZGTopScrollBar.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2017/3/24.
//
//

import UIKit
import Foundation
import ZGCore

@objc public protocol ZGTopScrollBarDelegate {
    @objc optional func topScrollBar(_ topScrollBar:ZGTopScrollBar, didSelectItemAt indexPath:IndexPath, object:Any);
    
    @objc optional func getDropDownViewSuperView(withScrollTagBar scrollTagBar:ZGTopScrollBar) -> UIView;
    @objc optional func getDropDownViewFrame(withScrollTagBar scrollTagBar:ZGTopScrollBar) -> CGRect;
    
    @objc optional func dropDownViewWillShow(withScrollTagBar scrollTagBar:ZGTopScrollBar);
    @objc optional func dropDownViewWillHide(withScrollTagBar scrollTagBar:ZGTopScrollBar);
}


open class ZGTopScrollBar: UIView, ZGTopScrollBarSectionViewDelegate, UICollectionViewDelegateFlowLayout, ZGTopScrollDropDownViewDelegate {

    open weak var delegate : ZGTopScrollBarDelegate?;
    
    private var _dataSource : ZGTopScrollBarDataSource?;
    public var dataSource : ZGTopScrollBarDataSource? {
        set {
            _dataSource = newValue;
            self.reloadData();
            self.selectItem(at: IndexPath.init(item: 0, section: 0));
        }
        get {
            return _dataSource;
        }
    }
    
    func layoutGradientLayers() {
        if let leftGradientLayer = self.leftGradientLayer,
            let rightGradientLayer = self.rightGradientLayer,
            let newColor = self.backgroundColor
        {
            CATransaction.begin();
            CATransaction.setDisableActions(true);
            let startColor = newColor.withAlphaComponent(1.0);
            let endColor = newColor.withAlphaComponent(0.0);
            let colors = [startColor.cgColor,endColor.cgColor];
            self.leftGradientLayer.colors = colors;
            self.rightGradientLayer.colors = colors;
            CATransaction.commit();
        }
    }
    
    override open var backgroundColor: UIColor? {
        set{
            let newColor = newValue ?? UIColor.white;
            super.backgroundColor = newColor;
        
            self.dropDownLabel.backgroundColor = newColor;
            self.dataSource?.sectionHeadView?.backgroundColor = newColor;
            
            self.layoutGradientLayers()
        }
        get{
            return super.backgroundColor;
        }
    }
    
    
    open var collectionBgView : UIView!;
    open var collectionView : UICollectionView!;
    open var dropDownLabel : UILabel!;
    open var dropDownButton : UIButton!;
    open var leftGradientLayer : CAGradientLayer!;
    open var rightGradientLayer : CAGradientLayer!;
    open var collectionBottomLine : UIView!;
    open var barBottomLine : UIView!;
    open var separateShadowLine : ZGImageView!;
    open var dropDownView:ZGTopScrollDropDownView!;

    open var isDropDown: Bool = false;
    open var selectedIndex: Int = 0;
    open var isLineMoveToSectionHeadView: Bool = false;
    
    public let kNormalSectionZPosition = CGFloat(kStickFlowLayoutSectionZPosition-1);
    public let kHighSectionZPosition = CGFloat(kStickFlowLayoutSectionZPosition+2);
    
    override public init(frame: CGRect) {
        super.init(frame: frame);
        self.setupView();
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.setupView();
    }
    
    public func setBottomLineCorner(_ height:CGFloat) {
        self.collectionBottomLine.height = height
        self.collectionBottomLine.bottom = self.collectionBgView.height
        self.collectionBottomLine.layer.cornerRadius = height / 2
        self.collectionBottomLine.layer.masksToBounds = true
    }
    
    public func setBottomLineHeight(_ height:CGFloat) {
        self.collectionBottomLine.height = height
        self.collectionBottomLine.bottom = self.collectionBgView.height
    }
    
    open func setupView() {
        //创建CollectionView
        self.createCollectionView();
        //创建左右两侧渐隐梯度视图
//        self.createGradientView();
        //创建下拉时遮住滚动条的label 和 下拉按钮
        self.createExpandView();
        //创建bar底部分隔线
        self.createSeparationLine();
        //创建下拉视图
        self.createDropDownView();
        
        self.backgroundColor = UIColor.white;
        self.clipsToBounds = false;
    }

    //创建CollectionView
    open func createCollectionView() {

        //创建横滑背景View
        self.collectionBgView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.width, height: self.height));
        self.collectionBgView.backgroundColor = UIColor.clear;
        self.addSubview(self.collectionBgView);
        
        //创建横滑CollectionView
        let layout = ZGCollectionViewStickFlowLayout.init();
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = .horizontal;
        
        let collection = UICollectionView.init(frame: self.collectionBgView.bounds, collectionViewLayout: layout);
        collection.backgroundColor = UIColor.clear;
        collection.showsVerticalScrollIndicator = false;
        collection.showsHorizontalScrollIndicator = false;
        collection.delegate = self;
        collection.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        if #available(iOS 10.0, *) {
            collection.isPrefetchingEnabled = false;
        }
        self.collectionView = collection;
        self.collectionBgView.addSubview(collection);
        self.registerClass();
        
        self.collectionBottomLine = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 2));
        self.collectionBottomLine.bottom = self.collectionBgView.height;
        self.collectionBottomLine.autoresizingMask = [.flexibleTopMargin];
        self.collectionBottomLine.backgroundColor = UIColor.color(withHex: 0xef4545);
        self.collectionBottomLine.layer.zPosition = self.kNormalSectionZPosition;
        self.collectionView.addSubview(self.collectionBottomLine);
    }
    
    public func registerClass() {
        ZGTopScrollBarTextCell.register(for: self.collectionView);
        ZGTopScrollBarImageCell.register(for: self.collectionView);
        
        ZGTopScrollBarSectionTextView.register(for: self.collectionView, kind: UICollectionView.elementKindSectionHeader);
        ZGTopScrollBarSectionImageView.register(for: self.collectionView, kind: UICollectionView.elementKindSectionHeader);
    }

    //创建左右两侧渐隐梯度视图
    open func createGradientView() {
        let leftLayer = CAGradientLayer();
        leftLayer.colors = [UIColor.init(white: 1, alpha: 1).cgColor, UIColor.init(white: 1, alpha: 0).cgColor];
        leftLayer.startPoint = CGPoint.init(x: 0, y: 0);
        leftLayer.endPoint = CGPoint.init(x: 1, y: 0);
        self.collectionBgView.layer.addSublayer(leftLayer);
        self.leftGradientLayer = leftLayer;
        
        
        let rightLayer = CAGradientLayer();
        rightLayer.colors = [UIColor.init(white: 1, alpha: 1).cgColor, UIColor.init(white: 1, alpha: 0).cgColor];
        rightLayer.startPoint = CGPoint.init(x: 1, y: 0);
        rightLayer.endPoint = CGPoint.init(x: 0, y: 0);
        self.collectionBgView.layer.addSublayer(rightLayer);
        self.rightGradientLayer = rightLayer;
    }

    //创建下拉时遮住滚动条的label 和 下拉按钮
    open func createExpandView() {
        //创建下拉时遮住滚动条的label
        let label = UILabel.init(frame: CGRect.zero);
        label.backgroundColor = UIColor.white;
        label.isUserInteractionEnabled = true;
        label.isHidden = true;
        self.collectionBgView.addSubview(label);
        self.dropDownLabel = label;

        //创建下拉按钮
        let btnImage = ZGImage("bundle://ZGUI/ui_topscrollbar_more@2x.png")
        let button = UIButton.init(type: .custom);
        button.frame = CGRect.init(x: 0, y: 0, width: 1, height: 20);
        button.backgroundColor = UIColor.clear;
        button.setImage(btnImage, for: .normal);
        button.addTarget(self, action: #selector(ZGTopScrollBar.didClicked(dropDownButton:)), for: .touchUpInside);
        button.adjustsImageWhenDisabled = false;
        button.adjustsImageWhenHighlighted = false;
        self.dropDownButton = button;
        self.addSubview(button);
        
        let buttonLeftLine = UIView.init(frame: CGRect.init(x: 0, y: 6, width: 0.5, height: button.frame.height-6*2));
        buttonLeftLine.backgroundColor = UIColor.color(withHex: 0xd5d5d5);
        buttonLeftLine.autoresizingMask = .flexibleHeight;
        button.addSubview(buttonLeftLine);
    }

    //创建bar底部分隔线
    open func createSeparationLine() {
        //创建bar底部分隔线
        let lineView = UIView.init(frame: CGRect.zero);
        lineView.backgroundColor = UIColor.color(withHex: 0xd5d5d5);
        lineView.layer.zPosition = 100.0;
        self.addSubview(lineView);
        self.barBottomLine = lineView;
        
        //创建bar底部分隔线阴影
        self.separateShadowLine = ZGImageView.init(frame: CGRect.zero);
        self.separateShadowLine.backgroundColor = UIColor.clear;
        self.separateShadowLine.isHidden = true;
        self.separateShadowLine.urlPath = "bundle://ZGUI/ui_topscrollbar_shadow.png";
        self.addSubview(self.separateShadowLine);
    }
    
    //创建下拉视图
    open func createDropDownView() {
        self.dropDownView = ZGTopScrollDropDownView.init(frame: CGRect.zero);
        self.dropDownView.delegate = self;
    }
    
    
    @objc open func didClicked(dropDownButton button:UIButton) {
        if !self.isDropDown {
            self.showDropDownView();
        }else {
            self.hideDropDownView();
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews();
        
        guard let dataSource = self.dataSource else {
            return;
        }
        
        //设置底部分割线frame
        self.barBottomLine.frame = CGRect.init(x: 0, y: self.frame.height-0.5, width: self.frame.width, height: 0.5);
        self.separateShadowLine.frame = CGRect.init(x: 0, y: self.frame.height, width: self.frame.width, height: 8);
        
        //设置右侧下拉按钮和CollectionView的frame
        let barHeight:CGFloat = self.height
        self.dropDownButton.isHidden = true;
        self.dropDownButton.frame = CGRect.init(x: self.frame.width-barHeight, y: 0, width: barHeight, height: self.frame.height);
        self.collectionBgView.frame = CGRect.init(x: 0, y: 0, width: self.frame.width-barHeight, height: self.frame.height);
        self.dropDownButton.isHidden = !dataSource.isNeedDropDown;
        if self.dropDownButton.isHidden {
            self.collectionBgView.frame = self.bounds;
        }
        
        //设置expandLabel的frame
        self.dropDownLabel.frame = (dataSource.dropDownText==nil) ? CGRect.zero : self.collectionBgView.bounds;
        
        //设置左右两侧渐隐梯度frame
        let leftWidht: CGFloat = 12;
        let leftX = dataSource.stickItem?.size.width ?? 0;
        
        let rightWidth: CGFloat = 28;
        let rightX = self.collectionBgView.frame.width-rightWidth;
        
        let gradientHeight: CGFloat = self.collectionBgView.frame.height-self.collectionBottomLine.frame.height;
        
        if let leftGradientLayer = self.leftGradientLayer,
            let rightGradientLayer = self.rightGradientLayer   {
            CATransaction.begin();
            CATransaction.setDisableActions(true);
            self.leftGradientLayer.frame = CGRect.init(x: leftX, y: 0, width: leftWidht, height: gradientHeight);
            self.rightGradientLayer.frame = CGRect.init(x: rightX, y: 0, width: rightWidth, height: gradientHeight);
            CATransaction.commit();
        }
    }
    
    
    //MARK: - separate shadow line
    public func showSeparateLineView(with duration:TimeInterval = 0.25) {
        self.separateShadowLine.isHidden = false;
        self.separateShadowLine.alpha = 0;
        UIView.animate(withDuration: duration) {
            self.separateShadowLine.alpha = 1;
        }
    }
    
    public func hideSeparateLineView(with duration:TimeInterval = 0.25) {
        self.separateShadowLine.alpha = 1;
        UIView.animate(withDuration: duration) {
            self.separateShadowLine.alpha = 0;
            self.separateShadowLine.isHidden = true;
        }
    }
    
    
    //MARK: - reload
    public func reload(dropDownFootView:UIView?) {
        guard let ds =  self.dataSource?.dropDownDataSource else {
            return;
        }
        ds.footView = dropDownFootView;
        self.dropDownView.layoutCollectionBgView();
    }
    
    
    public func reloadData() {
        self.dropDownView.dataSource = self.dataSource?.dropDownDataSource;
        self.dataSource?.topScrollBar = self;
        
        self.collectionView.dataSource = self.dataSource;
        self.reloadCollectionData();
        
        self.selectedIndex = -1;
        self.setNeedsLayout();
    }
    
    public func reloadCollectionData() {
        self.collectionView.reloadData();
        
        guard let dataSource = self.dataSource else {
            return;
        }
        for topItem in dataSource.allItems {
            if let textItem = topItem as? ZGTopScrollBarTextItem {
                self.collectionBottomLine.backgroundColor = textItem.selectedLineColor
                break;
            }
        }
        self.dropDownLabel.attributedText = dataSource.dropDownText;
    }
    
    public func resetAllSelectedState() {
        guard let dataSource = self.dataSource else {
            return;
        }
        for item in dataSource.allItems {
            item.isSelect = false;
        }
    }
    
    
    //MARK: - select item
    
    
    /// 选中Item
    ///
    /// - Parameters:
    ///   - indexPath: item对应的indexPath
    ///   - animated: 滚动动画
    ///   - dropDownAnimated: 下拉动画
    public func selectItem(at toIndexPath:IndexPath, animated:Bool = true, dropDownAnimated:Bool = true) {
        guard let ds = self.dataSource else {
            return;
        }
        let count = ds.allItems.count;
        guard count > 0 else {
            return;
        }
        var indexPath = toIndexPath;
        if indexPath.item<0 || indexPath.item>=count {
            indexPath.item = 0;
        }
        if indexPath.item == self.selectedIndex {
            return;
        }
        //收起下拉视图
        self.hideDropDownView(withAnimated: dropDownAnimated);
        
        //设置选中index
        self.selectedIndex = indexPath.item;
        //转换选中indexPath(对于self.allItems)到实际indexPath(对于self.items的，也即对应CollectionView的)
        var actIndexPath:IndexPath = indexPath;
        if let _ = ds.stickItem {
            actIndexPath.item = actIndexPath.item-1;
        }
        
        //底部线条动画
        let lineWidth = self.getLineWidth(with: actIndexPath);
        let cellFrame = self.getCellFrame(with: actIndexPath);
        
        let toView = (actIndexPath.item == -1) ? ds.sectionHeadView : self.collectionView;
        let _ = self.moveBottomLine(to: toView)
        
        UIView.animate(withDuration: animated ? 0.3:0, animations: {
            self.collectionBottomLine.width = lineWidth;
            self.collectionBottomLine.centerX = cellFrame.midX;
        }) { (_) in
            self.collectionBottomLine.layer.zPosition = self.kNormalSectionZPosition;
        }
        
        //选中item
        self.resetAllSelectedState();
        let obj = ds.collectionView(self.collectionView, objectForItemAt: actIndexPath);
        obj?.isSelect = true;
        DispatchQueue.main.async(execute: {
             self.collectionView.reloadData()
        })
        //横滑动画
        if actIndexPath.item == -1 {
            //如果是-1，说明此时选中的是sectionView
            self.collectionView.setContentOffset(.zero, animated: animated);
        }else {
            self.collectionView.selectItem(at: actIndexPath, animated: animated, scrollPosition: .centeredHorizontally);
        }
    }

    
    //MARK: - UICollectionViewDelegateFlowLayout
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let ds = self.dataSource else {
            return;
        }
        
        if ds.stickItem != nil && scrollView.contentOffset.x <= 0 {
            //如果有section，左侧没有弹性
            var offset = scrollView.contentOffset;
            offset.x = 0;
            scrollView.contentOffset = offset;
        }
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:UICollectionViewLayout, sizeForItemAt indexPath:IndexPath) ->CGSize {
        guard let ds = self.dataSource else {
            return CGSize.zero;
        }
        let obj = ds.collectionView(collectionView, objectForItemAt: indexPath);
        guard let object = obj else {
            return CGSize.zero;
        }
        let cellClass = ds.collectionView(collectionView, cellClassFor: object);
        return cellClass.collectionView(collectionView, layout: collectionViewLayout, sizeForObject: object as! ZGBaseUIItem);
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let ds = self.dataSource else {
            return CGSize.zero;
        }
        guard let object = ds.stickItem else {
            return CGSize.zero;
        }
        return object.size;
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let ds = self.dataSource else {
            return;
        }
        let obj = ds.collectionView(collectionView, objectForItemAt: indexPath);
        guard let object = obj else {
            return;
        }
        
        //转换indexPath到self.allItems
        var selectIndexPath = indexPath;
        if let _ = ds.stickItem {
            selectIndexPath = IndexPath.init(item: indexPath.item+1, section: 0);
        }
        
        if selectIndexPath.item == self.selectedIndex { //已经选中
            return;
        }
        
        self.selectItem(at: selectIndexPath);
        self.delegate?.topScrollBar?(self, didSelectItemAt: selectIndexPath, object: object);
    }
    
    
    
    //MARK: - bottomLine

    /// 获取红线的长度
    ///
    /// - Parameter indexPath: 对应的indexPath
    /// - Returns: 红线长度
    public func getLineWidth(with indexPath:IndexPath) -> CGFloat {
        guard let ds = self.dataSource else {
            return 0;
        }
        let obj = ds.collectionView(self.collectionView, objectForItemAt: indexPath);
        
        var lineWidth:CGFloat = 0;
        if let textItem = obj as? ZGTopScrollBarTextItem {
            let text:String = textItem.text;
            lineWidth = textItem.lineWidth
        }else if let imageItem = obj as? ZGTopScrollBarImageItem {
            lineWidth = imageItem.size.width - imageItem.horizontalPadding;
        }
        
        return lineWidth;
    }
    
    
    
    /// 获取cell或者section的frame
    ///
    /// - Parameter actIndexPath: 实际的indexPath,如果是section,indexPath.item==-1;
    /// - Returns: 对应的frame
    public func getCellFrame(with actIndexPath:IndexPath) -> CGRect {
        guard let ds = self.dataSource else {
            return CGRect.zero;
        }
        
        var x:CGFloat = 0;
        for i in -1..<actIndexPath.item {
            let indexPath = IndexPath.init(item: i, section: 0);
            let obj = ds.collectionView(self.collectionView, objectForItemAt: indexPath);
            guard let item = obj else {
                continue;
            }
            x += item.size.width;
        }
        
        let obj = ds.collectionView(self.collectionView, objectForItemAt: actIndexPath);
        guard let item = obj else {
            return CGRect.zero;
        }
        return CGRect.init(origin: CGPoint.init(x: x, y: 0), size: item.size);
    }
    
    /// 将底部红线移动到对应视图
    ///
    /// - Parameter view: 移动到的视图
    /// - Returns: 返回值为YES，表示父视图有变化，NO表示无变化
    public func moveBottomLine(to view:UIView?) -> Bool {
        guard let _ = view else {
            //如果view是nil，说明此时要移动到sectionView，但是sectionView还没有实例出来，所以这里先记录一个变量isLineMoveToSectionHeadView，等到sectionView出来再移动
            self.isLineMoveToSectionHeadView = true;
            return false;
        }
        
        if self.collectionBottomLine.superview == view {
            return false;
        }
        
        self.isLineMoveToSectionHeadView = false;
        let newFrame = self.collectionBottomLine.convert(self.collectionBottomLine.bounds, to: view);
        self.collectionBottomLine.frame = newFrame;
        //此时需要变换底部红线的zPosition，否则红线会被sectionView遮住
        self.collectionBottomLine.layer.zPosition = self.kHighSectionZPosition;
        view!.addSubview(self.collectionBottomLine);
        return true;
    }
    
    public func adjustBottomLine(from fromIndex:Int, to toIndex:Int, progress:CGFloat) {
        if fromIndex == toIndex { //说明已经拖动结束
            self.collectionBottomLine.layer.zPosition = self.kNormalSectionZPosition;
            return;
        }
        
        guard let ds = self.dataSource else {
            return;
        }
        
        var fromIndexPath = IndexPath.init(item: fromIndex, section: 0);
        var toIndexPath = IndexPath.init(item: toIndex, section: 0);
        if let _ = ds.stickItem {
            fromIndexPath = IndexPath.init(item: fromIndex-1, section: 0);
            toIndexPath = IndexPath.init(item: toIndex-1, section: 0);
        }
        
        let oldRect = self.getCellFrame(with: fromIndexPath);
        let currentRect = self.getCellFrame(with: toIndexPath);
        
        let oldLineWidth = self.getLineWidth(with: fromIndexPath);
        let currentLineWidth = self.getLineWidth(with: toIndexPath);
        
        if toIndexPath.item == -1 {
            //说明要滑动到sectionView
            let _ = self.moveBottomLine(to: ds.sectionHeadView);
        }else if fromIndexPath.item == -1 {
            if self.moveBottomLine(to: self.collectionView) {
                //说明是从sectionView到cell，此时需要变换底部红线的zPosition，否则红线会被sectionView遮住
                self.collectionBottomLine.layer.zPosition = self.kHighSectionZPosition;
            }
        }
        
        let centerX = oldRect.midX + (currentRect.midX - oldRect.midX) * progress;
        let lineWidth = oldLineWidth + (currentLineWidth - oldLineWidth) * progress;
        self.collectionBottomLine.width = lineWidth;
        self.collectionBottomLine.centerX = centerX;
    }

    
    //MARK: - ZGTopScrollBarSectionViewDelegate
    
    public func didLayout(sectionView: ZGTopScrollBarSectionBaseView) {
        //这个函数是sectionView出现后的回调，如果toSection为YES，说明要把底部红线移动到sectionView
        if self.isLineMoveToSectionHeadView {
            guard let ds = self.dataSource else {
                return;
            }
            ds.sectionHeadView?.addSubview(self.collectionBottomLine);
            self.isLineMoveToSectionHeadView = false;
        }
    }
    
    public func didClicked(sectionView: ZGTopScrollBarSectionBaseView) {
        guard let item = sectionView.item as? ZGTopScrollBarBaseItem else {
            return;
        }
        if 0 == self.selectedIndex { //已经选中
            return;
        }
        let indexPath = IndexPath.init(item: 0, section: 0);
        self.selectItem(at: indexPath);
        self.delegate?.topScrollBar?(self, didSelectItemAt: indexPath, object: item);
    }
    
    public func backgroundColor(withSectionView sectionView:ZGTopScrollBarSectionBaseView) -> UIColor {
        return self.backgroundColor ?? UIColor.white;
    }
    
    
 
    //MARK: - ZGTopScrollDropDownView
    
    public func showDropDownView(withAnimated animated:Bool = true, completion:(()->Void)? = nil) {
        if self.isDropDown {
            return;
        }
        self.delegate?.dropDownViewWillShow?(withScrollTagBar: self);
        
        //设置为已展开下拉视图
        self.isDropDown = true;
        //显示dropDownLabel
        self.dropDownLabel.isHidden = false;
        self.dropDownLabel.alpha = 0;
        
        //下拉按钮箭头方向动画
        self.dropDownButton.isEnabled = false;
        self.dropDownButton.imageView?.transform = .identity;
        UIView.animate(withDuration: 0.3, animations: {
            self.dropDownButton.imageView?.transform = CGAffineTransform(rotationAngle: 0.000001);
            self.dropDownButton.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
            self.dropDownLabel.alpha = 1;
        }) { (finished) in
            self.dropDownButton.isEnabled = true;
            completion?();
        }
        
        //下拉视图动画
        let sview = self.delegate?.getDropDownViewSuperView?(withScrollTagBar: self);
        guard let superView = sview else {
            return;
        }
        superView.addSubview(self.dropDownView);
        let frame = self.delegate?.getDropDownViewFrame?(withScrollTagBar: self) ?? CGRect.zero;
        self.dropDownView.frame = frame;
        self.dropDownView .show(withAnimated: true){};
        
        //默认选中当前选择的indexPath
        let indexPath = IndexPath.init(item: self.selectedIndex, section: 0);
        self.dropDownView.selectItem(atIndexPath: indexPath, animated: false);
    }
    
    public func hideDropDownView(withAnimated animated:Bool = true, completion:(()->Void)? = nil) {
        guard self.isDropDown else {
            return;
        }
        
        self.delegate?.dropDownViewWillHide?(withScrollTagBar: self);
        
        //设置为未展开下拉视图
        self.isDropDown = false;
        
        //下拉按钮箭头方向动画
        self.dropDownButton.isEnabled = false;
        self.dropDownButton.imageView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
        var timeinterval:TimeInterval = 0.3
        if !animated {
            timeinterval = 0
        }
        UIView.animate(withDuration: timeinterval, animations: {
            self.dropDownButton.imageView?.transform = CGAffineTransform(rotationAngle: 0.000001);
            self.dropDownButton.imageView?.transform = .identity;
            self.dropDownLabel.alpha = 0;
        }) { (finished) in
            self.dropDownButton.isEnabled = true;
            //隐藏dropDownLabel
            self.dropDownLabel.isHidden = true;
            completion?();
        }
        
        //下拉视图动画
        guard let _ = self.dropDownView.superview else {
            return;
        }
        self.dropDownView.hide(withAnimated: animated) {
            self.dropDownView.frame = .zero;
            self.dropDownView.removeFromSuperview();
        }
    }
    
    
    public func dropDownView(_ view:ZGTopScrollDropDownView, didSelectItemAt indexPath:IndexPath, object:Any) {
        
        if indexPath.item == self.selectedIndex {
            //已经选中
            self.hideDropDownView(withAnimated: true);
            return;
        }
        
        self.selectItem(at: indexPath, animated: false, dropDownAnimated: true);
        self.delegate?.topScrollBar?(self, didSelectItemAt: indexPath, object: object);
    }
    
    public func dropDownView(_ view:ZGTopScrollDropDownView, hideWith animated:Bool) {
        self.hideDropDownView(withAnimated: animated);
    }
}

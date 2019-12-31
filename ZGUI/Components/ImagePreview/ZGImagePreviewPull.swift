//
//  ZGImagePreviewPull.swift
//  Pods
//
//  Created by zhaogang on 2017/7/11.
//
//
import ZGCore
import UIKit

public class ZGImagePreviewPull: UIView {
    enum PullState:Int {
        case pulling = 0
        case normal = 1
    }
    
    static let pullHeight:CGFloat = 50
    static let padding:CGFloat = 5 //图片和文字的间距
    static let animationDuration:TimeInterval = 0.18
    
    var item:ZGImagePreviewPullingItem?
    
    weak var arrowImageLayer:CALayer!
    weak var statusLabel:UILabel!
    var _state:PullState = .normal
    
    var state:PullState {
        get {
            return _state
        }
        set {
            switch newValue {
            case .pulling:
                self.statusLabel.text = self.item?.triggerText
                let angle:CGFloat = CGFloat((Double.pi / 180.0) * 180.0)
                CATransaction.begin()
                CATransaction.setAnimationDuration(ZGImagePreviewPull.animationDuration)
                self.arrowImageLayer.transform = CATransform3DMakeRotation(angle, 0.0, 0.0, 1.0)
                CATransaction.commit()

            case .normal:
                if _state == .pulling {
                    CATransaction.begin()
                    CATransaction.setAnimationDuration(ZGImagePreviewPull.animationDuration)
                    self.arrowImageLayer.transform = CATransform3DIdentity
                    CATransaction.commit()
                }
                self.statusLabel.text = self.item?.pullingText
                CATransaction.begin()
                CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                self.arrowImageLayer.transform = CATransform3DIdentity
                CATransaction.commit()
            }
            _state = newValue
        }
    }
    
    public func setPullingItem(_ item:ZGImagePreviewPullingItem) {
        self.item = item
        
        self.statusLabel.text = item.pullingText
        self.statusLabel.font = UIFont.systemFont(ofSize: item.fontSize)
        self.statusLabel.textColor = item.textColor
        
        self.setArrowImage(imagePath: item.arrowImageUrl)
    }
    
    func setArrowImage(imagePath:String) {
        let image = ZGImage(imagePath)
        self.arrowImageLayer.contents = image?.cgImage
    }
 
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        //该视图添加后做90度旋转
        let imgWidth:CGFloat = 18
        
        let layer = CALayer()
        self.layer.addSublayer(layer)
        self.arrowImageLayer = layer
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        layer.frame = CGRect.init(x: 0, y: 0, width: imgWidth, height: imgWidth)
        CATransaction.commit()
        
        layer.contentsGravity = CALayerContentsGravity.resizeAspect
        layer.contentsScale = UIScreen.main.scale
        
        let labelHeight:CGFloat = 20
        let labelY:CGFloat = ZGImagePreviewPull.pullHeight - labelHeight - ZGImagePreviewPull.padding
        let label = UILabel()
        self.addSubview(label)
        label.frame = CGRect.init(x: 0, y: labelY, width: labelHeight, height: self.width)
        self.statusLabel = label
        
        self.statusLabel.textAlignment = .center
        self.statusLabel.numberOfLines = 0
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        var rect = self.arrowImageLayer.frame
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        rect.origin.x = (self.height-rect.size.height)/2
        rect.origin.y = self.width-rect.size.height-ZGImagePreviewPull.padding
        self.arrowImageLayer.frame = rect
        CATransaction.commit()
    }
    
    func containerDidScroll(_ scrollView:UIScrollView) {
        if scrollView.isDragging {
            let compareHeightA:CGFloat = scrollView.contentOffset.x + scrollView.frame.size.width
            var compareHeightB:CGFloat = scrollView.contentSize.width + ZGImagePreviewPull.pullHeight
            if scrollView.contentSize.width < scrollView.frame.size.width {
                compareHeightB = scrollView.frame.size.width + ZGImagePreviewPull.pullHeight
            }
            if _state == .pulling && compareHeightA < compareHeightB && scrollView.contentOffset.x > 0 {
                self.state = .normal
            } else if _state == .normal && compareHeightA > compareHeightB {
                self.state = .pulling
            }
            
            if scrollView.contentInset.bottom != 0 {
                scrollView.contentInset = .zero
            }
        }
    }
    
    func containerDidEndDragging(_ scrollView:UIScrollView) {
        let compareHeightA:CGFloat = scrollView.contentOffset.x + scrollView.frame.size.width
        var compareHeightB:CGFloat = scrollView.contentSize.width + ZGImagePreviewPull.pullHeight
        if (scrollView.contentSize.width < scrollView.frame.size.width) {
            compareHeightB = scrollView.frame.size.width + ZGImagePreviewPull.pullHeight
        }
        
        if (compareHeightA > compareHeightB) {
            
            //view停止等待效果
            self.state = .normal
            
            if let handler = self.item?.handler {
                handler()
            }
            self.resetToDefaultState(scrollView)
        }
    }
    
    func resetToDefaultState(_ scrollView:UIScrollView) {
        
        self.statusLabel.text = self.item?.pullingText
 
        var height:CGFloat = scrollView.contentSize.height
        if (height < scrollView.frame.size.height) {
            height = scrollView.frame.size.height
        }
        
        self.arrowImageLayer.transform = CATransform3DIdentity
        self.state = .normal
    }
}

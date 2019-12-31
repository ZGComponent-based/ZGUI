//
//  ZGSearchBar.swift
//  Pods
//
//  Created by lijiaqi on 2017/4/10.
//
//

import UIKit

@objc public protocol ZGSearchBarDelegate{
    
    /// return NO to not become first responder
    @objc optional func searchBarShouldBeginEditing(_ searchBar: ZGSearchBar) -> Bool
    
    /// called when text starts editing
    @objc optional func searchBarTextDidBeginEditing(_ searchBar: ZGSearchBar)
    
    /// return NO to not resign first responder
    @objc optional func searchBarShouldEndEditing(_ searchBar: ZGSearchBar) -> Bool
    
    /// called when text ends editing
    @objc optional func searchBarTextDidEndEditing(_ searchBar: ZGSearchBar)
    
    /// called when text changes (including clear)
    @objc optional func searchBar(_ searchBar: ZGSearchBar,textDidChange searchText: String)
    
    @objc optional func searchBar(_ searchBar: ZGSearchBar,shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool

    /// called when keyboard search button pressed
    @objc optional func searchBarSearchButtonClicked(_ searchBar: ZGSearchBar)
    
    @objc optional func searchBarLeftViewButtonClicked(_ searchBar: ZGSearchBar)
    
    /// called when cancel button pressed
    @objc optional func searchBarCancelButtonClicked(_ searchBar: ZGSearchBar)
    
    @objc optional func resetSubViewSizeByFlag(_ flag: Bool)

}

public class ZGSearchBar: UIView{

    var isAnimating: Bool = false
    var showCancelButton: Bool = false
    var pNeedLayoutSubviews: Bool = true
    
    public var animateDelay: Double = 0.1
    public var horizontalPadding: CGFloat = 8.0
    public var verticalPadding: CGFloat = 8.0
    public var cancelButtonWidth: CGFloat = 70.0
    
    public var searchTextField: ZGSearchBarTextField!

    public var cancelButton: UIButton!
    public var searchResultCountLabel: UILabel!
    
    public weak var delegate: ZGSearchBarDelegate?
    public weak var searchDisplayDelegate: ZGSearchBarDelegate?
    
    public var needShowCancelButton: Bool = false
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configSubViews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configSubViews()
    }
    
    public func layoutCancelButton(_ animated: Bool){
        if animated {
            layoutCancelButton()
        }else{
            layoutSearchBar()
        }
    }
        
    func layoutSearchBar() {
        var tfRect = searchTextField.frame
        var cancelRect = cancelButton.frame
        
        if !showCancelButton && !needShowCancelButton {
            cancelRect.origin.x = self.width
        }else{
            cancelRect.origin.x = self.width - cancelButtonWidth - horizontalPadding
        }
        cancelButton.frame = cancelRect
        
        tfRect.size.width = cancelRect.origin.x - horizontalPadding * 2
        searchTextField.frame = tfRect
    }
    
    public func layoutCancelButton(){
        if !pNeedLayoutSubviews {
            return
        }
        isAnimating = true
        perform(#selector(self.animateTextField), with: nil, afterDelay: animateDelay)
    }
    
    public func textFieldShowKeyBoard(){
        self.searchTextField.becomeFirstResponder()
    }
    @objc func animateTextField() {
        isAnimating = true
        delegate?.resetSubViewSizeByFlag?(showCancelButton)
        UIView.animate(withDuration: 0.3, animations: { 
            self.layoutSearchBar()
        }) { (finished) in
            if finished{
                self.isAnimating = false
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        var tfRect = searchTextField.frame
        tfRect.origin.x = horizontalPadding
        tfRect.origin.y = verticalPadding
        tfRect.size.height = self.height - verticalPadding*2
        
        var cancelRect = cancelButton.frame
        if !showCancelButton && !needShowCancelButton {
            cancelRect.origin.x = self.width
        }else{
            cancelRect.origin.x = self.width - cancelButtonWidth - horizontalPadding
        }
        cancelRect.origin.y = verticalPadding
        cancelRect.size = CGSize(width: cancelButtonWidth, height: self.height - verticalPadding * 2)
        cancelButton.frame = cancelRect
        
        tfRect.size.width = cancelRect.origin.x - horizontalPadding * 2
        searchTextField.frame = tfRect
    }

    func configSubViews(){
        
        searchTextField = ZGSearchBarTextField()
        searchTextField.borderStyle = .none
        searchTextField.backgroundColor = UIColor.white
        searchTextField.delegate = self
        searchTextField.contentVerticalAlignment = .center
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.returnKeyType = .search
        self.addSubview(searchTextField)
        
        cancelButton = UIButton(type: .custom)
        cancelButton.setTitle("取消", for: .normal)
        self.addSubview(cancelButton)
        
        searchResultCountLabel = UILabel()
        searchResultCountLabel.font = UIFont.systemFont(ofSize: 13)
        searchResultCountLabel.textColor = UIColor.gray
        self.addSubview(searchResultCountLabel)
        
        let leftView = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: self.height))
        //没写完 图片
        let image = UIImage(named: "bundle://ZGUI/common_search@2x.png")
        leftView .setImage(image, for: .normal)
        leftView.addTarget(self, action: #selector(self.handleBookmarkAction(_:)), for: .touchUpInside)
        leftView.imageEdgeInsets = UIEdgeInsets(top: 16, left: 9, bottom: 16, right: 9)
        searchTextField.leftView = leftView
        searchTextField.leftViewMode = .always
        
        cancelButton.addTarget(self, action: #selector(self.handleCancelAction(_:)), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.textFieldTextDidChange(_:)), name:UITextField.textDidChangeNotification, object: searchTextField)
    }
    
    @objc public func handleCancelAction(_ sender: Any){
        if isAnimating {
            return
        }
        delegate?.searchBarCancelButtonClicked?(self)
        searchDisplayDelegate?.searchBarCancelButtonClicked?(self)
        pNeedLayoutSubviews = true
        showCancelButton = false
        layoutCancelButton()
        searchTextField.resignFirstResponder()
    }

    public func cancelAction(){
        pNeedLayoutSubviews = true
        showCancelButton = false
        layoutCancelButton()
        searchTextField.resignFirstResponder()
    }
    
    @objc func handleBookmarkAction(_ sender: Any){
        pNeedLayoutSubviews = true
        searchTextField.becomeFirstResponder()
        delegate?.searchBarLeftViewButtonClicked?(self)
        searchDisplayDelegate?.searchBarLeftViewButtonClicked?(self)
    }

    public func addSearchResultDealCountsLabel(_ count: NSNumber){
        searchResultCountLabel.text = "共\(count.intValue)条结果"
        var rect = searchResultCountLabel.frame
        let text = searchResultCountLabel.text!
        rect.size =  text.textSize(attributes: [.font:searchResultCountLabel.font]);
        rect.origin.x = self.width - rect.size.width - 10;
        rect.origin.y = (self.height - rect.size.height)/2;
        searchResultCountLabel.frame = rect;
    }
    
    public func hiddenSearchResultDealCountsLabel(_ hidden: Bool) {
        searchResultCountLabel.isHidden = hidden
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ZGSearchBar: UITextFieldDelegate {
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let should = delegate?.searchBarShouldBeginEditing?(self){
            return should
        }
        if let should = searchDisplayDelegate?.searchBarShouldBeginEditing?(self){
            return should
        }
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        showCancelButton = true
        layoutCancelButton()
        delegate?.searchBarTextDidBeginEditing?(self)
        searchDisplayDelegate?.searchBarTextDidBeginEditing?(self)
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let should = delegate?.searchBarShouldEndEditing?(self){
            return should
        }
        if let should = searchDisplayDelegate?.searchBarShouldEndEditing?(self){
            return should
        }
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        showCancelButton = false
        delegate?.searchBarTextDidEndEditing?(self)
        searchDisplayDelegate?.searchBarTextDidEndEditing?(self)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let should = delegate?.searchBar?(self, shouldChangeTextInRange: range, replacementText: string){
            return should
        }
        
        if let should = searchDisplayDelegate?.searchBar?(self, shouldChangeTextInRange: range, replacementText: string){
            return should
        }
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        pNeedLayoutSubviews = true
        delegate?.searchBarSearchButtonClicked?(self)
        searchDisplayDelegate?.searchBarSearchButtonClicked?(self)
        return true
    }
    
    
    @objc func textFieldTextDidChange(_ note: Notification){
        guard let textField = note.object as? ZGSearchBarTextField else {
            return
        }
        if textField != searchTextField {
            return
        }
        
        delegate?.searchBar?(self, textDidChange: textField.text ?? "")
        searchDisplayDelegate?.searchBar?(self, textDidChange: textField.text ?? "")
    }
}







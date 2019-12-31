//
//  ZGCollectionVCL.swift
//  ZGUIDemo
//

import UIKit


open class ZGTableVCL: ZGScrollVCL, UITableViewDelegate {
    
    @IBOutlet weak public var tableView : UITableView?
    
    private var _dataSource:ZGTableViewDataSource?
    public var dataSource:ZGTableViewDataSource? {
        get {
            return _dataSource
        }
        set (newValue) {
            if newValue != _dataSource {
                _dataSource = newValue
            }
            self.tableView?.dataSource = newValue
        }
    }
    
    deinit {
        self.tableView?.delegate = nil
        self.tableView?.dataSource = nil
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
    
    open func addTableView(style: UITableView.Style = .plain) {
        if self.tableView != nil {
            return
        }
        
        var rect = self.view.bounds
        rect.origin.y = ZGUIUtil.statusBarHeight() + 44
        rect.size.height = self.view.height - rect.origin.y
        
        let pTableView = UITableView(frame: rect, style: style)
        pTableView.delegate = self
        pTableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        pTableView.backgroundColor = UIColor.white
        pTableView.alwaysBounceVertical = true
        pTableView.sectionIndexBackgroundColor = UIColor.white
        pTableView.sectionIndexColor = UIColor.colorOfHexText("#8E9DAE")
        pTableView.separatorStyle = .none
        self.view.addSubview(pTableView)
        self.tableView = pTableView
        
        if #available(iOS 11.0, *) {
            pTableView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let dc = tableView.dataSource as? ZGTableViewDataSource {
            if let object = dc.tableView(tableView, objectForRowAtIndexPath: indexPath) {
                let viewType = dc.tableView(tableView, cellClassForObject: object)
                return viewType.tableView(tableView, rowHeightForObject: object)
            } 
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let dc = tableView.dataSource as? ZGTableViewDataSource {
            return dc.tableView(tableView, viewForSection:section)
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let dc = tableView.dataSource as? ZGTableViewDataSource {
            return dc.tableView(tableView, viewForSection:section)
        }
        return nil
    }
    
    private func tableView(_ tableView: UITableView, heightForSection section: Int, type:ZGTableSectionType) -> CGFloat {
        if let dc = tableView.dataSource as? ZGTableViewDataSource {
            return dc.tableView(tableView, heightForSection: section, type: type)
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

       return  self.tableView(tableView, heightForSection: section, type: .header)
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.tableView(tableView, heightForSection: section, type: .footer)
    }
}



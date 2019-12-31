//
//  ZGCollectionViewDataSource.swift
//  ZGUIDemo
//

import UIKit

open class ZGTableViewDataSource: NSObject, UITableViewDataSource {
    
    open var sectionItems:[[ZGBaseUIItem]]? //多个section
    open var items:[ZGBaseUIItem]?//一个section
    open var sectionViewItems : [ZGTableReusableViewItem]?//section header footer对应的item数组
    
    public func tableView(_ tableView: UITableView, cellClassForObject object: ZGBaseUIItem) -> ZGTableViewCell.Type {
        return object.mapTableViewType()
    }
    
    public func tableView(_ tableView: UITableView, objectForRowAtIndexPath indexPath: IndexPath) -> ZGBaseUIItem? {
        var retItems = self.items
        if let section = self.sectionItems{
            if indexPath.section >= 0 && indexPath.section < section.count {
                retItems = section[indexPath.section]
            }
        }
        
        if let sourceItems = retItems{
            if indexPath.row >= 0 && indexPath.row < sourceItems.count {
                return sourceItems[indexPath.row]
            }
        }
        
        return nil
    }
    
    public init(items:[ZGBaseUIItem],sections:[ZGTableReusableViewItem]? =  nil) {
        self.items = items
        self.sectionViewItems = sections
    }
    
    public init(sectionItems:[[ZGBaseUIItem]],sections:[ZGTableReusableViewItem]? =  nil) {
        self.sectionItems = sectionItems
        self.sectionViewItems = sections
    }
    
    public func tableView(_ tableView: UITableView, objectForSection section: Int) -> ZGBaseUIItem? {
        guard let sectionViewItems = self.sectionViewItems else {
            return nil
        }
        for item in sectionViewItems {
            if item.sectionIndex == section {
                return item
            }
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, sectionClassForObject object: ZGTableReusableViewItem) -> ZGTableReusableView.Type {
        return object.mapReusableViewType()
    }
    
    public func tableView(_ tableView: UITableView, heightForSection section: Int, type:ZGTableSectionType) -> CGFloat {
        
        if let object = self.tableView(tableView, objectForSection: section) as? ZGTableReusableViewItem {
            if object.kind == type {
                let viewType = self.tableView(tableView, sectionClassForObject: object)
                return viewType.tableView(tableView, rowHeightForObject: object)
            }
        }
        
        return 0
    }
    
    public func tableView(_ tableView: UITableView, viewForSection section: Int) -> UIView? {
        if let object = self.tableView(tableView, objectForSection: section) as? ZGTableReusableViewItem {
            let viewType = self.tableView(tableView, sectionClassForObject: object)
            let identifier = viewType.efIdentifier()
            if let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier) {
                if let view1 = view as? ZGTableReusableView {
                    view1.setObject(object)
                }
                return view
            }
        }
        return nil
    }
  
    //MARK: - UITableViewDataSource
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionItems?.count ?? 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var retItems = self.items
        if let section1 = self.sectionItems {
            if section >= 0 && section < section1.count {
                retItems = section1[section]
            }
        }
        
        return retItems?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let obj : ZGBaseUIItem? = self.tableView(tableView, objectForRowAtIndexPath: indexPath)
        
        guard let object = obj  else {
            return UITableViewCell()
        }
        
        let cellType = self.tableView(tableView, cellClassForObject: object)
        let identifier = cellType.tbbzIdentifier()
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        if let cell2 = cell as? ZGTableViewCell {
            cell2.setObject(object)
        }
        return cell
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        guard let sections = self.sectionViewItems else {
            return nil
        }
        if sections.count < 1 {
            return nil
        }
        var titles = [String]()
        for item in sections {
            if let c1 = item.indexCharactor {
                titles.append(c1)
            }
        }
        return titles
    }
    
    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let sections = self.sectionViewItems else {
            return nil
        }
        
        return nil
    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = self.sectionViewItems else {
            return nil
        }
        //用自定义视图展示
//        var titles = [String]()
//        for item in sections {
//            if let c1 = item.indexCharactor {
//                titles.append(c1)
//            }
//        }
//        if section < titles.count {
//            return titles[section]
//        }
        
        return nil
    }
}

//
//  TableViewDemoVCL.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2018/2/9.
//  Copyright © 2018年 zhaogang. All rights reserved.
//

import UIKit
import ZGUI

class TableViewDemoVCL: ZGTableVCL {
    @objc override func goBack1() {
        self.goBack()
    }
    var searchController:UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        let navigatorView = self.createNavigator()
        navigatorView.navigatorItem.title = "CollectionView"
        self.view.addSubview(navigatorView)
        self.zbNavigatorView = navigatorView
        
        self.addTableView()
        self.registerClass()
        let model1 = TableDemoModel()
        self.model = model1
        
        let result = DemoSearchResultVCL()
        result.datas = ["zhe1", "zhe2", "zhe3"]
        let search = UISearchController(searchResultsController: result)
        result.gobackHandler = {[weak self] (param) in
            if let text = param?["keyword"] as? String {
                print(text)
            }
            self?.goBack()
        }
        
        // Use the current view controller to update the search results.
        search.searchResultsUpdater = result
        search.searchBar.placeholder = "车牌号"
        // Install the search bar as the table header.
        self.tableView?.tableHeaderView = search.searchBar
        
        self.searchController = search
        
        // It is usually good to set the presentation context.
        self.definesPresentationContext = true
        self.searchController.dimsBackgroundDuringPresentation = true
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .default
    }
    
      func registerClass(){
        guard let tableView = self.tableView  else {
            return
        }
        TableDemoCell.register(for: tableView)
        TabelHeaderSectionView.register(for: tableView)
    }
    
    override public func loadItems() {
        self.showPageLoading()
        self.model.loading = true
        self.model?.loadItems(nil, completion: {[weak self] (params) in
            self?.reloadData()
            }, failure: { [weak self](err) in
                self?.dealError(err)
        })
    }
    
    override public func reloadData(){
        super.reloadData()
        
        self.hidePageTip()
        self.hidePageLoading()
        
        guard let model1 = self.model as? TableDemoModel else {
            return
        }
        
        if let items =  self.model?.items as? [ZGBaseUIItem] {
             self.dataSource = ZGTableViewDataSource.init(items: items)
        } else if let items =  self.model?.items as? [[ZGBaseUIItem]] {
            self.dataSource = ZGTableViewDataSource.init(sectionItems: items, sections: model1.sectionViewItems)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

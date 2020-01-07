//
//  DemoSearchResultVCL.swift
//  ZGUIDemo
//
//  Created by zhaogang on 2018/2/9.
//  Copyright © 2018年 zhaogang. All rights reserved.
//

import UIKit
import ZGUI

class DemoSearchResultVCL: UITableViewController, UISearchResultsUpdating {
    var results = [String]()
    var datas = [String]()
    var gobackHandler: ZGGoBackHandler?
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let inputStr = searchController.searchBar.text else {
            return
        }
        if (self.results.count > 0) {
            results.removeAll()
        }
        for str in self.datas {
            
            if str.lowercased().contains(inputStr.lowercased()) {
                self.results.append(str)
            }
        }
        
        self.tableView.reloadData()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        cell.textLabel?.text = self.results[indexPath.row]

        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let text = self.results[indexPath.row]
        if let gobackHandler = self.gobackHandler {
            self.dismiss(animated: false, completion: nil)
            gobackHandler(["keyword":text])
        }
//
    }

    deinit {
        print("release result")
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

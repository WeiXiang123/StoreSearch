//
//  ViewController.swift
//  StoreSearch
//
//  Created by WeiXiang on 15/1/11.
//  Copyright (c) 2015年 WeiXiang. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var tableViewInSearch: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var searchResult = [SearchResult]()
    var hasSearched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        println("Search text is '\(searchBar.text)'")

        searchBar.resignFirstResponder()  //hide keyboard
        searchResult.removeAll(keepCapacity: false)
        hasSearched = true

        if searchBar.text != "apple" {
            for i in 0...3 {
                let result = SearchResult()
                result.name = String(format: "Fake result %d for", i)
                result.artistName = searchBar.text
                searchResult.append(result)
            }
        }

        tableViewInSearch.reloadData()
    }

    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched {
            return 0
        }else if searchResult.count == 0 {
            return 1
        }else {
            return searchResult.count
        }

    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cellIndentifer = "searchCell"
        var cell = tableViewInSearch.dequeueReusableCellWithIdentifier(cellIndentifer) as UITableViewCell!
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellIndentifer)
        }

        if searchResult.count == 0 {
            if let textLabel = cell.textLabel {
                textLabel.text = "(Nothing found)"
            }

            if let detailTable = cell.detailTextLabel {
                detailTable.text = ""
            }

        }else {
            if let textLabel = cell.textLabel {
                textLabel.text = searchResult[indexPath.row].name
            }

            if let detailTable = cell.detailTextLabel {
                detailTable.text = searchResult[indexPath.row].artistName
            }
        }


        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if searchResult.count == 0 {
            return nil
        }else{
            return indexPath
        }
    }
}

extension SearchViewController:UITableViewDelegate {

}




//
//  ViewController.swift
//  StoreSearch
//
//  Created by WeiXiang on 15/1/11.
//  Copyright (c) 2015年 WeiXiang. All rights reserved.
//

import UIKit
import Foundation

class SearchViewController: UIViewController {

    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingfoundCell = "NothingFoundCell"
    }

    @IBOutlet weak var tableViewInSearch: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!


    var searchResult = [SearchResult]()
    var hasSearched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableViewInSearch.becomeFirstResponder()

        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        var nothingCellNib = UINib(nibName: TableViewCellIdentifiers.nothingfoundCell, bundle: nil)
        tableViewInSearch.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        tableViewInSearch.registerNib(nothingCellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingfoundCell)

        tableViewInSearch.rowHeight = 80
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {

        searchBar.resignFirstResponder()  //hide keyboard
        searchResult.removeAll(keepCapacity: false)
        hasSearched = true

        let url = urlWithSearchText(searchBar.text)
        println("*** URL:'\(url)'")

        if let jasonString = performStoreRequestWithURl(url) {
            //println("Receive jason: '\(jasonString)'")
            if let dictionary = parseJSON(jasonString) {
                //println("parse json : '\(dictionary)'")
                searchResult = parseDictionary(dictionary)
                searchResult.sort{
                    $0.name.localizedStandardCompare($1.name) == NSComparisonResult.OrderedAscending
                }

                tableViewInSearch.reloadData()
                return
            }
        }

        showNetWorkError()
    }

    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }

    //MARK - URL
    func urlWithSearchText(searchText:String) -> NSURL {
        let escapedSearchText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!

        let urlString = String(format: "http://itunes.apple.com/search?term=%@",escapedSearchText)

        return NSURL(string: urlString)!
    }

    // in main thread －－－ is bad example
    func performStoreRequestWithURl( url : NSURL)->String? {

        var error: NSError?
        if let data = NSData(contentsOfURL: url, options: NSDataReadingOptions.DataReadingUncached, error: &error) {
            return  NSString(data: data, encoding: NSUTF8StringEncoding)
        }else if let error = error {
            println("DownLoad error:\(error)")
        }else {
            println("Unknown download error")
        }

        return nil
    }

    func parseJSON(jsonString: String)-> [String: AnyObject]? {
        if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
            var error:NSError?
            if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &error) as? [String: AnyObject] {
                return json
            }else if let error = error {
                println("parse Json error: '\(error)'")
            }else {
                println("parse json nuknown error")
            }
        }

        return nil
    }

    func parseDictionary(dictionary: [String : AnyObject])->[SearchResult] {

        var searchResults = [SearchResult]()

        if let array: AnyObject = dictionary["results"] {
            for resultDic in array as [AnyObject] {
                if let resultDic  = resultDic as? [String: AnyObject] {
                    var searchResult: SearchResult?
                    
                    if let wrapperType = resultDic["wrapperType"] as? NSString {
                        switch wrapperType {
                        case "track":
                            searchResult = parseTrack(resultDic)
                        case "audiobook":
                            searchResult = parseAudioBook(resultDic)
                        case "software":
                            searchResult = parseSoftware(resultDic)
                        default:
                            break
                        }
                    }else if let kind = resultDic["kind"] as? NSString{
                        //e-books do not have a wrapperType field
                        if kind == "ebook" {
                            searchResult = parseEBook(resultDic)
                        }

                    }

                    if let result = searchResult {
                        searchResults.append(result)
                    }
                }
            }//end for
        }

        return searchResults
    }

    func parseTrack(dictionary: [String: AnyObject])-> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as NSString
        searchResult.artistName = dictionary["artistName"] as NSString
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as NSString
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as NSString
        searchResult.storeURL = dictionary["trackViewUrl"] as NSString
        searchResult.kind = dictionary["kind"] as NSString
        searchResult.currency = dictionary["currency"] as NSString

        //can not use NSNumber?
        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }

        if let genre = dictionary["primaryGenreName"] as? NSString {
            searchResult.genre = genre
        }

        return searchResult
    }

    func showNetWorkError() {
        let alert = UIAlertController(title: "Whoops!...", message: "There is an error reading from itunes, please try it again!", preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)

        alert.addAction(action)

        presentViewController(alert, animated: true, completion: nil)
    }

    func kindForDisplay(kind: String) -> String {

        switch kind {
        case "album":           return "Album"
        case "audiobook":       return "Audio Book"
        case "book":            return "Book"
        case "ebook":           return "E-Book"
        case "feature-movie":   return "Movie"
        case "music-video":     return "Music Video"
        case "podcast":         return "Podcast"
        case "software":        return "App"
        case "song":            return "Song"
        case "tv-episode":      return "TV Episode"
        default:
            return kind
        }
    }

    //Audio books don’t have a “kind” field, so set the kind property to "audiobook".
    func parseAudioBook(dictionary: [String: AnyObject]) -> SearchResult {
            let searchResult = SearchResult()
            searchResult.name = dictionary["collectionName"] as NSString
            searchResult.artistName = dictionary["artistName"] as NSString
            searchResult.artworkURL60 = dictionary["artworkUrl60"] as NSString
            searchResult.artworkURL100 = dictionary["artworkUrl100"] as NSString
            searchResult.storeURL = dictionary["collectionViewUrl"] as NSString
            searchResult.kind = "audiobook"
            searchResult.currency = dictionary["currency"] as NSString
            if let price = dictionary["collectionPrice"] as? Double {
                searchResult.price = price
            }
            if let genre = dictionary["primaryGenreName"] as? NSString {
                searchResult.genre = genre
            }
            return searchResult
    }

    
    func parseSoftware(dictionary: [String: AnyObject]) -> SearchResult {
            let searchResult = SearchResult()
            searchResult.name = dictionary["trackName"] as NSString
            searchResult.artistName = dictionary["artistName"] as NSString
            searchResult.artworkURL60 = dictionary["artworkUrl60"] as NSString
            searchResult.artworkURL100 = dictionary["artworkUrl100"] as NSString
            searchResult.storeURL = dictionary["trackViewUrl"] as NSString
            searchResult.kind = dictionary["kind"] as NSString
            searchResult.currency = dictionary["currency"] as NSString
            if let price = dictionary["price"] as? Double {
                searchResult.price = price
            }
            if let genre = dictionary["primaryGenreName"] as? NSString {
                searchResult.genre = genre
            }
            return searchResult
    }

    //E-books don’t have a “primaryGenreName” field, but an array of genres
    func parseEBook(dictionary: [String: AnyObject]) -> SearchResult {
            let searchResult = SearchResult()
            searchResult.name = dictionary["trackName"] as NSString
            searchResult.artistName = dictionary["artistName"] as NSString
            searchResult.artworkURL60 = dictionary["artworkUrl60"] as NSString
            searchResult.artworkURL100 = dictionary["artworkUrl100"] as NSString
            searchResult.storeURL = dictionary["trackViewUrl"] as NSString
            searchResult.kind = dictionary["kind"] as NSString
            searchResult.currency = dictionary["currency"] as NSString

            if let price = dictionary["price"] as? Double {
                searchResult.price = price
            }
            if let genres: AnyObject = dictionary["genres"] {
                searchResult.genre = ", ".join(genres as [String])
            }

            return searchResult
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

        //it only works when you have registered a nib with the table view.
        if searchResult.count == 0 {
            return tableViewInSearch.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingfoundCell, forIndexPath: indexPath) as UITableViewCell

        }else {
            var cell = tableViewInSearch.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as SearchResultCell
            cell.nameLabel.text =  searchResult[indexPath.row].name

            if searchResult[indexPath.row].artistName.isEmpty {
                cell.artistNameLabel.text = "Unknown"
            }else{
                let name = String(format: "%@ (%@)", searchResult[indexPath.row].artistName, kindForDisplay(searchResult[indexPath.row].kind))
                cell.artistNameLabel.text = name
            }

            return cell
        }

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




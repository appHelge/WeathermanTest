//
//  LocationsViewController.swift
//  WeathermanTest
//
//  Created by Helge Larsen on 26.07.15.
//  Copyright © 2015 Helge Larsen. All rights reserved.
//

import UIKit

class LocationsViewController: UITableViewController {

  var search = LocationSearch()
  let searchController = UISearchController(searchResultsController: nil)
  
  struct TableViewCellIdentifiers {
    static let searchResultCell = "SearchResultCell"
    static let nothingFoundCell = "NothingFoundCell"
    static let loadingCell = "LoadingCell"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    searchController.searchBar.delegate = self
    searchController.searchBar.scopeButtonTitles = []
    searchController.searchBar.sizeToFit()
    tableView.tableHeaderView = searchController.searchBar
    definesPresentationContext = true

    var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
    cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
    cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
    tableView.rowHeight = 80
  
  }
  
  func showNetworkError() {
    let alert = UIAlertController(
      title: NSLocalizedString("Whoops...", comment: "Error alert: title"),
      message: NSLocalizedString("There was an error reading from the iTunes Store. Please try again.", comment: "Error alert: message"),
      preferredStyle: .Alert)
    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alert.addAction(action)
    presentViewController(alert, animated: true, completion: nil)
  }


    // MARK: - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch search.state {
    case .NotSearchedYet:
      return 0
    case .Loading:
      return 1
    case .NoResults:
      return 1
    case .Results(let list):
      return list.searchResults.count
    }
  }

  override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
    if (!self.searchController.active)
    {
      if (index > 0)
      {
        // The index is offset by one to allow for the extra search icon inserted at the front
        // of the index
        
        return index-1
      }
      else
      {
        // The first entry in the index is for the search icon so we return section not found
        // and force the table to scroll to the top.
        
        let searchBarFrame = self.searchController.searchBar.frame
        tableView.scrollRectToVisible(searchBarFrame, animated: false)
        return NSNotFound;
      }
    }
    return 0;
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    switch search.state {
    case .NotSearchedYet:
      fatalError("Should never get here")
    case .Loading:
      let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as UITableViewCell
      let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
      spinner.startAnimating()
      return cell
    case .NoResults:
      return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
    case .Results(let list):
      let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
      let searchResult = list.searchResults[indexPath.row]
      cell.configureForSearchResult(searchResult)
      
      return cell
    }
  }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LocationsViewController: UISearchBarDelegate {
  
}

extension LocationsViewController: UISearchResultsUpdating {
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    performSearch()
  }
  
  func performSearch() {
    guard let searchString = searchController.searchBar.text where searchController.searchBar.text != nil else {
      return
    }
    search.performSearchForText(searchString, completion: { success in
      if !success {
        self.showNetworkError()
      }
        
      self.tableView.reloadData()
      //self.searchController.searchBar.resignFirstResponder()
    })
  }
}
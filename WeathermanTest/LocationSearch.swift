//
//  LocationSearch.swift
//  WeathermanTest
//
//  Created by Helge Larsen on 26.07.15.
//  Copyright © 2015 Helge Larsen. All rights reserved.
//

import Foundation
import UIKit

typealias SearchComplete = (Bool) -> Void

class LocationSearch {
  
  enum State {
    case NotSearchedYet
    case Loading
    case NoResults
    case Results(SearchResultArray)
  }
  
  private(set) var state: State = .NotSearchedYet
  
  private var dataTask: NSURLSessionDataTask? = nil
  
  func performSearchForText(text: String, completion: SearchComplete) {
    if !text.isEmpty {
      dataTask?.cancel()
      
      UIApplication.sharedApplication().networkActivityIndicatorVisible = true
      state = .Loading
      
      let url = urlWithSearchText(text)
      let session = NSURLSession.sharedSession()
      dataTask = session.dataTaskWithURL(url, completionHandler: {
        data, response, error in
        
        self.state = .NotSearchedYet
        var success = false
        
        if let error = error {
          if error.code == -999 { return } // Search was cancelled
        } else if let httpResponse = response as? NSHTTPURLResponse {
          if httpResponse.statusCode == 200 {
            if let searchResults = self.parseHTML(data!) {
              let searchResultsArray = SearchResultArray(searchResults: searchResults)
            //if let dictionary = self.parseJSON(data!) {
              //let searchResults = SearchResultArray(searchResults: self.parseDictionary(dictionary))
              //var searchResults = self.parseDictionary(dictionary)
              if searchResults.isEmpty {
                self.state = .NoResults
              } else {
                self.state = .Results(searchResultsArray)
              }
              success = true
            }
          }
        }
        
        dispatch_async(dispatch_get_main_queue()) {
          UIApplication.sharedApplication().networkActivityIndicatorVisible = false
          completion(success)
        }
      })
      
      dataTask?.resume()
    }
  }
  
  private func urlWithSearchText(searchText: String) -> NSURL {
    //let locale = NSLocale.autoupdatingCurrentLocale()
    //let language = locale.localeIdentifier
    //let countryCode = locale.objectForKey(NSLocaleCountryCode) as! String
    
    let escapedSearchText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    let urlString = String(format: "http://www.yr.no/soek/soek.aspx?sted=%@", escapedSearchText)
    let url = NSURL(string: urlString)
    print("URL: \(url!)")
    return url!
  }
  
  private func parseHTML(data: NSData) -> [LocationSearchResult]? {
    //let htmlString = NSString(data: data, encoding: NSUTF8StringEncoding)
    let locationsParser = TFHpple(HTMLData: data)
    let resultTablesXpath = "//table[@class='yr-table yr-table-search-results']/tr"
    let resultTablesNodes = locationsParser.searchWithXPathQuery(resultTablesXpath)
    print("resultTableNodes count:\(resultTablesNodes.count)")
    var searchResults = [LocationSearchResult]()
    
    for resultTableElement in resultTablesNodes {
      let searchResult = LocationSearchResult()
      let locationDataList = resultTableElement.childrenWithTagName("td")

      /*
      for locationDataItem in locationDataList {
        print(locationDataItem.content)
      }
      */
      searchResult.placeName = locationDataList[1].content
      searchResult.type = locationDataList[3].content
      searchResult.municipality = locationDataList[4].content
      searchResult.area = locationDataList[5].content
      searchResults.append(searchResult)
    }
    return searchResults
  }
  
  private func parseJSON(data: NSData) -> [String: AnyObject]? {
    do {
      let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject]
      return json
    } catch let error as NSError {
      print("JSON Error: \(error)")
    } catch {
      print("Unknown JSON Error")
    }
    return nil
  }
  
}
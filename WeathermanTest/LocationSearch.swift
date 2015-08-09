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
      
      guard let url = urlWithSearchText(text) else {
        return
      }
      
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
  
  private func urlWithSearchText(searchText: String) -> NSURL? {
    //let locale = NSLocale.autoupdatingCurrentLocale()
    //let language = locale.localeIdentifier
    //let countryCode = locale.objectForKey(NSLocaleCountryCode) as! String
    if let escapedSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
      let urlString = String(format: "http://www.yr.no/soek/soek.aspx?sted=%@", escapedSearchText)
      let url = NSURL(string: urlString)
      print("URL: \(url!)")
      return url!
    }
    return nil
  }
  
  private func parseHTML(data: NSData) -> [LocationSearchResult]? {
    //let htmlString = NSString(data: data, encoding: NSUTF8StringEncoding)
    let locationsParser = TFHpple(HTMLData: data)
    let resultTablesXpath = "//table[@class='yr-table yr-table-search-results']/tr"
    let resultTablesNodes = locationsParser.searchWithXPathQuery(resultTablesXpath)
    print("resultTableNodes count:\(resultTablesNodes.count)")
    var searchResults = [LocationSearchResult]()
    var href: String = ""
    
    for resultTableElement in resultTablesNodes {
      let searchResult = LocationSearchResult()
      let locationDataList = resultTableElement.childrenWithTagName("td")

      for locationDataItem in locationDataList {
        let locationDataItemHref = locationDataItem.childrenWithTagName("a")
        if locationDataItemHref.count > 0 {
          href = String(locationDataItemHref[0].attributes["href"])
          //print("href: \(href)")
          searchResult.url = "http://www.yr.no\(href)"
        }
        print(locationDataItem.content)
        for (attribName, attribValue) in locationDataItem.attributes {
          print("attrib: \(attribName): \(attribValue)")
        }
      }
      searchResult.resultListIndex = removeUnwantedCharactersFromText(locationDataList[0].content)
      searchResult.placeName = removeUnwantedCharactersFromText(locationDataList[1].content)
      searchResult.url = String(locationDataList[1].childrenWithTagName("a")[0].attributes["href"]!)
      searchResult.elevation = removeUnwantedCharactersFromText(locationDataList[2].content)
      searchResult.type = removeUnwantedCharactersFromText(locationDataList[3].content)
      searchResult.municipality = removeUnwantedCharactersFromText(locationDataList[4].content)
      searchResult.area = removeUnwantedCharactersFromText(locationDataList[5].content)
      searchResult.country = removeUnwantedCharactersFromText(locationDataList[6].content)
      searchResult.countryFlagImgSrc = String(locationDataList[6].childrenWithTagName("a")[0].childrenWithTagName("img")[0].attributes["src"]!)
      searchResults.append(searchResult)
    }
    return searchResults
  }
  
  func removeUnwantedCharactersFromText(text: String) -> String {
    var filteredText = text
    filteredText = filteredText.stringByReplacingOccurrencesOfString("\r\n      ", withString: "")
    filteredText = filteredText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    return filteredText
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
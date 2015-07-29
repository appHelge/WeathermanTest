//
//  LocationSearchResult.swift
//  WeathermanTest
//
//  Created by Helge Larsen on 26.07.15.
//  Copyright © 2015 Helge Larsen. All rights reserved.
//

import Foundation

class LocationSearchResult {
  var placeName: String = ""
  var type: String = ""
  var municipality: String = ""
  var area: String = ""
  var country: String = ""
  var url: String = ""
  var resultDataDict = [String: String]()
  var title: String {
    var titleString: String = ""
    for (index, value) in resultDataDict {
      titleString += "\(index): \(value)"
    }
    return titleString
  }
  var subtitle: String {
    return "\(type), \(municipality), (\(area)), \(country)"
  }
}


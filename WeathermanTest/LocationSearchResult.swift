//
//  LocationSearchResult.swift
//  WeathermanTest
//
//  Created by Helge Larsen on 26.07.15.
//  Copyright © 2015 Helge Larsen. All rights reserved.
//

import Foundation
import UIKit

class LocationSearchResult {
  var resultListIndex: String = ""
  var placeName: String = ""
  var type: String = ""
  var elevation: String = ""
  var municipality: String = ""
  var area: String = ""
  var country: String = ""
  var url: String = ""
  var countryFlagImgSrc: String = ""
  var countryFlagImagePath: String? {
    guard countryFlagImgSrc != "" else {
      return nil
    }
    return (countryFlagImgSrc as NSString).lastPathComponent
    // http://fil.nrk.no/contentfile/web/icons/flags/h14/NO.png
    
  }
  
  var countryFlagImage: UIImage? {
    guard countryFlagImagePath != nil, var flagPath = countryFlagImagePath else {
      return nil
    }
    let fileManager = NSFileManager.defaultManager()
    flagPath = (applicationDocumentsDirectory as NSString).stringByAppendingPathComponent(flagPath)
    if fileManager.fileExistsAtPath(flagPath) {
      return UIImage(named: flagPath)
    } else {
      return nil
    }
  }
}


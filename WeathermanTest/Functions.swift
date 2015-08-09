//
//  Functions.swift
//  WeathermanTest
//
//  Created by Helge Larsen on 01.08.15.
//  Copyright © 2015 Helge Larsen. All rights reserved.
//

import Foundation

let applicationDocumentsDirectory: String = {
  let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as [String]
  return paths[0]
}()

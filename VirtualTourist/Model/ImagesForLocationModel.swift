//
//  PhotoInfo.swift
//  VirtualTourist
//
//  Created by Kappa on 2020-03-25.
//  Copyright © 2020 qi. All rights reserved.
//

import Foundation

class ImagesForLocationModel {
  
  static var totalPages: [Pin: Int] = [:] {
    didSet {
      print("pages: \(totalPages)")
    }
  }
  
}

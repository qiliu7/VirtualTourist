//
//  FlickrResponse.swift
//  VirtualTourist
//
//  Created by Kappa on 2020-03-13.
//  Copyright © 2020 qi. All rights reserved.
//

import Foundation

struct FlickrResponse: Codable {
  let stat: String
  let code: Int
  let message: String
}

extension FlickrResponse: LocalizedError {
  var errorDescription: String? {
    return message
  }
}

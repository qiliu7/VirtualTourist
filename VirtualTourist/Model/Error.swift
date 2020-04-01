//
//  Error.swift
//  VirtualTourist
//
//  Created by Kappa on 2020-03-26.
//  Copyright © 2020 qi. All rights reserved.
//

import Foundation

struct NoMoreNewPhotoError : LocalizedError {
  var errorDescription: String? {
    return "That was all the photos Flickr could find."
  }
}

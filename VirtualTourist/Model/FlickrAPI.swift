//
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by Kappa on 2020-03-12.
//  Copyright © 2020 qi. All rights reserved.
//

import Foundation

class FlickrAPI {
  
  let session = URLSession.shared
  
  enum Endpoints {
    static let base = "https://www.flickr.com/services/rest/"
    static let method = "?method=flickr.photos.search"
    static let apiKeyParam = "&api_key=\(FlickrAPI.apiKey)"
    static let format = "&format=json"
    
    case searchImagesForLocation(Float, Float)

    var stringValue: String {
      switch self {
      case let .searchImagesForLocation(lat, lon):
        return Endpoints.base + Endpoints.method + Endpoints.apiKeyParam + "&lat=\(lat)&lon=\(lon)" + Endpoints.format
      }
    }
    
    var url: URL {
      return URL(string: stringValue)!
    }
  }

}

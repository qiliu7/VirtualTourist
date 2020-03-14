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
  
  struct Endpoint {
    
    let host: String
    let path: String
    let queryItems: [URLQueryItem]?
    
    var url: URL {
      var components = URLComponents()
      components.scheme = "https"
      components.host = host
      components.path = path
      components.queryItems = queryItems
      
      return components.url!
    }
    
    static func searchImagesForLocation(lat: Double, lon: Double) -> Endpoint {
      return Endpoint(
        host: "www.flickr.com",
        path: "/services/rest",
        queryItems: [
          URLQueryItem(name: "api_key", value: FlickrAPI.apiKey),
          URLQueryItem(name: "lat", value: "\(lat)"),
          URLQueryItem(name: "lon", value: "\(lon)"),
          URLQueryItem(name: "format", value: "json"),
          URLQueryItem(name: "nojasoncallback", value: "1")]
      )
    }
    
    static func downloadImage(farmId: Int, serverId: String, id: String, secret: String) -> Endpoint {
      return Endpoint(
        host: "farm\(farmId).staticflickr.com",
        path: "/\(serverId)/\(id)_\(secret).jpg", queryItems: nil)
    }
  }
  
  func searchImagesForLocation(lat: Double, lon: Double, completion: @escaping ([PhotoData]?, Error?) -> Void) {
    let url = Endpoint.searchImagesForLocation(lat: lat, lon: lon).url
    let task = session.dataTask(with: url) { (data, response, error) in
      guard let data = data else {
        dispatchToMain {
          completion(nil, error)
        }
        return
      }
      let decoder = JSONDecoder()
      do {
        let responseObject = try decoder.decode(ImagesForLoctaionResponse.self, from: data)
        let photos = responseObject.photos.photoList
        dispatchToMain {
          completion(photos, nil)
        }
      } catch {
        do {
          let errorResponse = try decoder.decode(FlickrResponse.self, from: data)
          dispatchToMain {
            completion(nil, errorResponse)
          }
        } catch {
          dispatchToMain {
            completion(nil, error)
          }
        }
      }
    }
    task.resume()
  }
}

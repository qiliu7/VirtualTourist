//
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by Kappa on 2020-03-12.
//  Copyright © 2020 qi. All rights reserved.
//

import UIKit
import MapKit


class FlickrAPI {
  
  static let session = URLSession.shared
  
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
        path: "/services/rest/",
        queryItems: [
          URLQueryItem(name: "method", value: "flickr.photos.search"),
          URLQueryItem(name: "api_key", value: FlickrAPI.apiKey),
          URLQueryItem(name: "lat", value: "\(lat)"),
          URLQueryItem(name: "lon", value: "\(lon)"),
          URLQueryItem(name: "format", value: "json"),
          URLQueryItem(name: "nojsoncallback", value: "1")]
      )
    }
  }
  
  class func getImageURLForLocation(coordinate: CLLocationCoordinate2D, completion: @escaping ([URL]?, Error?) -> Void) {
    let lat = coordinate.latitude
    let lon = coordinate.longitude
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
//        let total = responseObject.photos.info.total
        // MARK: if total > 0 show no photo in the second VC?
        let photos = responseObject.photos.photo
        var urls = [URL]()
        let bound = photos.count < Setting.numberOfPhotos ? photos.count : Setting.numberOfPhotos
        for photo in photos[0..<bound] {
          if let url = photo.getUrl() {
                      urls.append(url)
          }
        }
        print(bound)
        print(photos[0])
        dispatchToMain {
          completion(urls, nil) //MARK: ????
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

  class func downloadImage(with url: URL, completion: @escaping (Data?, Error?) -> Void) {
      let task = session.dataTask(with: url) { (data, response, error) in
        guard let data = data else {
          dispatchToMain {
            completion(nil, error)
          }
          return
        }
        dispatchToMain {
          completion(data, error)
        }
      }
      task.resume()
    // MARK: TODO: change ERROR MESSAGE
  }
}

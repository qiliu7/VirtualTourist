//
//  ImagesForLocationResponse.swift
//  VirtualTourist
//
//  Created by Kappa on 2020-03-13.
//  Copyright © 2020 qi. All rights reserved.
//

import Foundation

struct ImagesForLoctaionResponse: Codable {
  let photos: PhotosResponse
  let stat: String
}

struct PhotosResponse: Codable {
  let info: PhotosInfo
  let photoList: [PhotoData]
}

struct PhotosInfo: Codable {
  let page: Int
  let pages: Int
  let perpage: Int
  let total: Int
}

struct PhotoData: Codable {
  let id: String
  let owner: String
  let secret: String
  let server: String
  let farm: Int
  let title: String
  let isPublic: Int
  let isFriend: Int
  let isFamily: Int

  enum CodingKeys: String, CodingKey {
    case id
    case owner
    case secret
    case server
    case farm
    case title
    case isPublic = "ispublic"
    case isFriend = "isfriend"
    case isFamily = "isfamily"
  }
}

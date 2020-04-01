//
//  Constants.swift
//  VirtualTourist
//
//  Created by Kappa on 2020-03-18.
//  Copyright © 2020 qi. All rights reserved.
//

import Foundation
import MapKit

struct Name {
  static let model = "VirtualTourist"
  static let showPhotosSegue = "showPhotos"
}

struct Setting {
  static let photoPerRow = 3
  static let numberOfRows = 20
  static let numberOfPhotos = Setting.photoPerRow * Setting.numberOfRows
}

struct DefaultMapSetting {
  static let center = CLLocationCoordinate2D(latitude: 50.49984733546685, longitude: -98.46515985375761)
  static let region = MKCoordinateRegion(center: DefaultMapSetting.center, latitudinalMeters: 103.91172475308929, longitudinalMeters: 88.73235233334937)
}

struct UserDefaultsKeyMap {
  static let centerLat = "mapCenterLatitude"
  static let centerLon = "mapCenterLongitude"
  static let regionLat = "mapRegionLatitude"
  static let regionLon = "mapRegionLongitude"
}

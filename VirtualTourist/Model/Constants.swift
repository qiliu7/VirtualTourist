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
  static let center = CLLocationCoordinate2D(latitude: 42.44935469166303, longitude: -98.23396319017317)
  static let region = MKCoordinateRegion(center: DefaultMapSetting.center, span: MKCoordinateSpan(latitudeDelta: 109.63462025101087, longitudeDelta: 86.32466104386504))
}

struct UserDefaultsKeyMap {
  static let centerLat = "mapCenterLatitude"
  static let centerLon = "mapCenterLongitude"
  static let latDelta = "mapRegionLatitude"
  static let lonDelta = "mapRegionLongitude"
}

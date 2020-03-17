//
//  Pin+Extensions.swift
//  VirtualTourist
//
//  Created by Kappa on 2020-03-17.
//  Copyright © 2020 qi. All rights reserved.
//

import UIKit
import MapKit
import CoreData

extension Pin {
  
  func convertToAnnotation() -> MKPointAnnotation {
     let annotation = MKPointAnnotation()
     annotation.coordinate = CLLocationCoordinate2D(latitude: self.lat, longitude: self.lon)
    return annotation
  }
}

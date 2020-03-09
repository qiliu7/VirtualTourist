//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Kappa on 2020-03-09.
//  Copyright © 2020 qi. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsMapView: UIViewController {
  
  lazy var mapView: MKMapView = {
    var mv = MKMapView(frame: self.view.frame)
    mv.delegate = self
    // TODO: add configure of span, center etc
    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressDetected))
    mv.addGestureRecognizer(longPress)
    return mv
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    customizeNavBar()
    view.addSubview(mapView)
  }
  
  private func customizeNavBar() {
    navigationItem.title = "Drop a Pin"
  }
  
  @objc func longPressDetected() {
    print("pressed")
  }
}

extension TravelLocationsMapView: MKMapViewDelegate {
  
}


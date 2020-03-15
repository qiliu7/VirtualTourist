//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Kappa on 2020-03-09.
//  Copyright © 2020 qi. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapView: UIViewController {
  
  lazy var mapView: MKMapView = {
    var mv = MKMapView(frame: self.view.frame)
    mv.delegate = self
    //TODO: zoom to a initial location when opened - e.g. current location?
    let longPress = UILongPressGestureRecognizer()
    longPress.addTarget(self, action: #selector(longPressRecognized(_:)))
    mv.addGestureRecognizer(longPress)
    return mv
  }()

  fileprivate func loadPersistedPins() -> [MKPointAnnotation] {
    let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
    if let result = try? dataController.viewContext.fetch(fetchRequest){
      pins = result
    }
    var annotations = [MKPointAnnotation]()
    for pin in pins {
      let annotation = MKPointAnnotation()
      annotation.coordinate = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.lon)
      annotations.append(annotation)
    }
    return annotations
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    customizeNavBar()
    view.addSubview(mapView)
  }
  
  private func customizeNavBar() {
    navigationItem.title = "Drop a Pin"
  }
  
  @objc func longPressRecognized(_ gestureRecognizer: UILongPressGestureRecognizer) {
    if gestureRecognizer.state != .began {
      return
    }
    let location = gestureRecognizer.location(in: mapView)
    let newPin = MKPointAnnotation()
    newPin.coordinate = mapView.convert(location, toCoordinateFrom: mapView)
    mapView.addAnnotation(newPin)
    print(mapView.annotations.count)
  }
}

extension TravelLocationsMapViewController: MKMapViewDelegate {

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let pinIdentifier = "pinIdentifier"
    var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: pinIdentifier) as? MKPinAnnotationView

    if let pinView = pinView {
      pinView.annotation = annotation
    } else {
      pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinIdentifier) as MKPinAnnotationView
      pinView?.animatesDrop = true
    }
    return pinView
  }
}


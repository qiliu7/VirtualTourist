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

class MapViewController: UIViewController {
  
  var dataController: DataController!
  var pins = [Pin]()
  
  lazy var mapView: MKMapView = {
    var mv = MKMapView(frame: self.view.frame)
    mv.delegate = self
    let longPress = UILongPressGestureRecognizer()
    longPress.addTarget(self, action: #selector(handleLongPress(_:)))
    mv.addGestureRecognizer(longPress)
    return mv
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    customizeNavBar()
    view.addSubview(mapView)
    mapView.addAnnotations(fetchStoredPins())
  }
  
  private func customizeNavBar() {
    navigationItem.title = ""
  }
  
  @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
    if gestureRecognizer.state != .began {
      return
    }
    let location = gestureRecognizer.location(in: mapView)

    let annotation = MKPointAnnotation()
    annotation.coordinate = mapView.convert(location, toCoordinateFrom: mapView)
    mapView.addAnnotation(annotation)
    
    let pin = Pin(context: dataController.viewContext)
    pin.lat = annotation.coordinate.latitude
    pin.lon = annotation.coordinate.longitude
    do {
        _ = try dataController.viewContext.save()
    } catch {
      print(error.localizedDescription)
    }
  }

  
  private func fetchStoredPins() -> [MKPointAnnotation] {
    let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
    if let result = try? dataController.viewContext.fetch(fetchRequest){
      pins = result
    }
    var annotations = [MKPointAnnotation]()
      for pin in pins {
        annotations.append(pin.convertToAnnotation())
      }
      return annotations
    }
}

//MARK: Map View Delegate
extension MapViewController: MKMapViewDelegate {

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

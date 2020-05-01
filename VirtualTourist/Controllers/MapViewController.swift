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
  
  // MARK: Properties
  var dataController: DataController!
  var pins = [Pin]()
  var mapRegion: MKCoordinateRegion!
  
  // MARK: Outlets
  @IBOutlet weak var mapView: MKMapView!
  
  // MARK: Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureNavBar()
    configureMapView()
    //    deleteDataEntry()
  }
  
  // MARK: Set UI & MapView
  private func configureNavBar() {
    navigationItem.title = ""
  }
  
  private func configureMapView() {
    mapView.setRegion(mapRegion, animated: true)
    mapView.delegate = self
    let longPress = UILongPressGestureRecognizer()
    longPress.addTarget(self, action: #selector(addNewPin(_:)))
    mapView.addGestureRecognizer(longPress)
    mapView.addAnnotations(fetchStoredPins())
  }
  
  // MARK: Actions
  @objc func addNewPin(_ gestureRecognizer: UILongPressGestureRecognizer) {
    if gestureRecognizer.state != .began {
      return
    }
    let location = gestureRecognizer.location(in: mapView)
    
    let annotation = MKPointAnnotation()
    let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
    annotation.coordinate = coordinate
    mapView.addAnnotation(annotation)
    
    let pin = Pin(context: dataController.viewContext)
    pin.lat = coordinate.latitude
    pin.lon = coordinate.longitude
    do {
      try dataController.viewContext.save()
    } catch {
      fatalError(error.localizedDescription)
    }
    pins.append(pin)
    FlickrAPI.getImageURLsForLocation(coordinate: coordinate, completion: handleImageURLResponse(urls:error:))
  }
  
  private func handleImageURLResponse(urls: [URL]?, error: Error?) {
    // save urls to Photo
    guard let urls = urls else {
      showAlert(title: "Error", message: "Retrive images failed \(error!.localizedDescription)", OKHandler: nil)
      return
    }
    // create photos associated with the new pin and store their url
    for url in urls {
      let aPhoto = Photo(context: dataController.viewContext)
      aPhoto.pin = pins.last
      aPhoto.url = url.absoluteString
      do {
        try dataController.viewContext.save()
      } catch {
        fatalError("not able to save \(error.localizedDescription)")
      }
    }
  }
  
  // MARK: Fetch Pin
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
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let photoAlbumVC = segue.destination as! PhotoAlbumViewController
    let pin = sender as! Pin
    photoAlbumVC.dataController = dataController
    photoAlbumVC.selectedPin = pin
  }
}

// MARK: Map View Delegate
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
  
  // MARK: Anti Pattern?
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    performSegue(withIdentifier: Name.showPhotosSegue, sender: view.annotation?.findAssociatedPin(pins))
  }
  
  // MARK: FOR TEST ONLY
  fileprivate func deleteDataEntry() {
    //MARK: clear core data for test
    let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
    if let result = try? dataController.viewContext.fetch(fetchRequest){
      for pin in result {
        dataController.viewContext.delete(pin)
      }
    }
    try? dataController.viewContext.save()
  }
}

extension MKAnnotation {
  
  func findAssociatedPin(_ pins: [Pin]) -> Pin? {
    for pin in pins {
      if pin.lat == self.coordinate.latitude &&
        pin.lon == self.coordinate.longitude {
        return pin
      }
    }
    return nil
  }
}

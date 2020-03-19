//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Kappa on 2020-03-18.
//  Copyright © 2020 qi. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
  
  // MARK: Properties
  var dataController: DataController!
  var fetchedResultController: NSFetchedResultsController<Photo>!
  var coordinate: CLLocationCoordinate2D!
  
  // MARK: Outlets
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var collectionView: UICollectionView!
  
  // MARK: Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
//    collectionView.dataSource = self
//    setUpFetchedResultController()
    setUpMapView()
  }
  private func setUpMapView() {
    mapView.delegate = self
    mapView.setCenter(coordinate, animated: true)
    let annotation = MKPointAnnotation()
    annotation.coordinate = coordinate
    mapView.addAnnotation(annotation)
  }
  
  // Mark: Set Up Fetched Result Controller
  private func setUpFetchedResultController() {
    let fetchRequest = NSFetchRequest<Photo>()
    let sortDescriptor = NSSortDescriptor(key: "url", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]
    fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    do {
      try fetchedResultController.performFetch()
    } catch {
      // TODO: add alert
      fatalError("fetched failed: \(error.localizedDescription)")
    }
  }
}

// MARK: Map View Delegate
extension PhotoAlbumViewController: MKMapViewDelegate {

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let pinIdentifier = "pinIdentifier"
      let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinIdentifier) as MKPinAnnotationView
      pinView.animatesDrop = true
    return pinView
  }
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return fetchedResultController.sections?.count ?? 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return fetchedResultController.sections?[section].numberOfObjects ?? 1
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//    let photo = fetchedResultController.object(at: indexPath)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath)
//    cell.backgroundColor = .black
    cell.contentView.largeContentImage = UIImage(imageLiteralResourceName: "AppIcon")
    return cell
  }
}

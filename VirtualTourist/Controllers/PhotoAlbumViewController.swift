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
  var selectedPin: Pin!
  
  private var operations = [BlockOperation]()
  
  // MARK: Outlets
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
  @IBOutlet weak var refreshButton: UIButton!
  
  // MARK: Life Cycle
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationItem.title = "Pull to Refresh"
    setUpFetchedResultController()
    setUpMapView()
    configureCollectionView()
    loadImages()
  }
  
  deinit {
    mapView.delegate = nil
    mapView = nil
    fetchedResultController.delegate = nil
    fetchedResultController = nil
    for op in operations {
      op.cancel()
    }
    operations.removeAll()
  }
  
  // MARK: Actions
  @IBAction func refreshButtonTapped(_ button: UIButton) {
    button.isEnabled = false
    // remove all photos belong to this pin
    if let photos = fetchedResultController.fetchedObjects {
      for photo in photos {
        dataController.viewContext.delete(photo)
      }
    }
    FlickrAPI.getTotalImagePagesForPin(selectedPin, completion: handleRefreshResponse(totalPages:error:))
  }
  
  
  private func setUpMapView() {
    mapView.delegate = self
    let annotation = selectedPin.convertToAnnotation()
    mapView.setRegion(MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 50_000, longitudinalMeters: 50_000), animated: true)
    mapView.addAnnotation(annotation)
  }
  
  private func setUpFetchedResultController() {
    let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
    let sortDescriptor = NSSortDescriptor(key: "url", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]
    let predicate = NSPredicate(format: "pin == %@", selectedPin)
    fetchRequest.predicate = predicate
    fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    fetchedResultController.delegate = self
    do {
      try fetchedResultController.performFetch()
    } catch {
      fatalError("fetched failed: \(error.localizedDescription)")
    }
  }
  
  private func configureCollectionView() {
    collectionView.dataSource = self
    collectionView.delegate = self
    
    let photoPerRow = Setting.photoPerRow
    let space: CGFloat = CGFloat(3.0)
    let dimension = (self.view.frame.width - (CGFloat(photoPerRow - 1) * space)) / CGFloat(photoPerRow)
    
    flowLayout.minimumLineSpacing = space
    flowLayout.minimumInteritemSpacing = space
    flowLayout.itemSize = CGSize(width: dimension, height: dimension)
  }
  
  fileprivate func loadImages() {
    if fetchedResultController.fetchedObjects?.count == 0 {
      showAlert(title: "No Images", message: "No images available for this location. Please try somewhere else.", OKHandler: {_ in
        self.navigationController?.popViewController(animated: true)
      })
    }
    // if has previous stored photos, show those
    if let fetchedPhoto = fetchedResultController.fetchedObjects?.first{
      fetchedPhoto.image == nil ? downloadImages() : ()
    }
  }

  private func handleRefreshResponse(totalPages: Int?, error: Error?) {
    guard let pages = totalPages else {
      showAlert(title: "Refresh Failed", message: "Error occured \(error?.localizedDescription ?? "").", OKHandler: nil)
      return
    }
    if pages == 1 {
      showAlert(title: "Can Not Refresh", message: "Current location has only one page of photos.", OKHandler: {_ in self.collectionView.refreshControl?.endRefreshing()})
    } else {
      
      // Flickr API seems to return repeated photos when the page number is too large
      let pageLimit = min(pages, 40)
      let randomPage = Int.random(in: 2...pageLimit)
      FlickrAPI.getImageURLsForLocation(coordinate: CLLocationCoordinate2D(latitude: selectedPin.lat, longitude: selectedPin.lon), onPage: randomPage, completion: handleImageURLResponse(urls:error:))
    }
  }
  
  private func handleImageURLResponse(urls: [URL]?, error: Error?) {
    // save urls to Photo
    guard let urls = urls else {
      showAlert(title: "Error", message: "Retrive images failed \(error!.localizedDescription)", OKHandler:  {_ in self.collectionView.refreshControl?.endRefreshing()})
      return
    }
    // create photos associated with the selected pin and store their url
    for url in urls {
      let aPhoto = Photo(context: dataController.viewContext)
      aPhoto.pin = selectedPin
      aPhoto.url = url.absoluteString
      do {
        try dataController.viewContext.save()
      } catch {
        fatalError("not able to save \(error.localizedDescription)")
      }
    }
    downloadImages()
  }
  
  private func downloadImages() {
    do {
      try fetchedResultController.performFetch()
    } catch {
      fatalError("fetched failed: \(error.localizedDescription)")
    }
    
    let downloadGroup = DispatchGroup()
    let photos = fetchedResultController.fetchedObjects
    if let photos = photos {
      for photo in photos {
        if let url = URL(string: photo.url ?? "") {
          downloadGroup.enter()
          FlickrAPI.downloadImage(with: url) { (data, error) in
            if let data = data {
              photo.image = data
            }
          }
          downloadGroup.leave()
        }
      }
    }
    // Notify the main thread when all images finished downloading
    downloadGroup.notify(queue: DispatchQueue.main) {
      do {
        try self.dataController.viewContext.save()
        if !self.refreshButton.isEnabled {
          self.refreshButton.isEnabled = true
        }
      } catch {
        fatalError(error.localizedDescription)
      }
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
     let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
    // if is called after refresh is called and all the photos are deleted
    if fetchedResultController.fetchedObjects?.count == 0 {
      cell.imageView.image = nil
      // if photos are downloaded
    } else {
       let photo = fetchedResultController.object(at: indexPath)
       if let data = photo.image {
         cell.imageView.image = UIImage(data: data)
       }
    }
  return cell
  }
}

extension PhotoAlbumViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let photo = fetchedResultController.object(at: indexPath)
    dataController.viewContext.delete(photo)
    do {
      try dataController.viewContext.save()
    } catch {
      fatalError(error.localizedDescription)
    }
  }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      operations.append(BlockOperation(block: {
        self.collectionView.insertItems(at: [newIndexPath!])
      }))
    case .delete:
      operations.append(BlockOperation(block: {
        self.collectionView.deleteItems(at: [indexPath!])
      }))
    case .update:
      operations.append(BlockOperation(block: {
        self.collectionView.reloadItems(at: [indexPath!])
      }))
    case .move:
      operations.append(BlockOperation(block: {
        if indexPath != newIndexPath {
          self.collectionView.moveItem(at: indexPath!, to: newIndexPath!)
        }
      }))
    @unknown default:
      break
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    do {
      try fetchedResultController.performFetch()
    } catch {
      fatalError(error.localizedDescription)
    }
    collectionView.performBatchUpdates({
      for op in self.operations {
        op.start()
      }
    }) { (finished) in
      self.operations.removeAll()
    }
  }
}


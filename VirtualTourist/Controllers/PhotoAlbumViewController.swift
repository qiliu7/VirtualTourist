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
  
  private let itemsPerRow: CGFloat = 3
  
  // MARK: Outlets
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
  
  // MARK: Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.dataSource = self
    setUpFetchedResultController()
    setUpMapView()
    configureCollectionView()
    downloadImages()
  }
  
  private func setUpMapView() {
    mapView.delegate = self
    let annotation = selectedPin.convertToAnnotation()
    mapView.setCenter(annotation.coordinate, animated: true)
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
      // TODO: add alert
      fatalError("fetched failed: \(error.localizedDescription)")
    }
  }
  
  private func configureCollectionView() {
    collectionView.refreshControl = UIRefreshControl()
    collectionView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    
    let photoPerRow = Setting.photoPerRow
    let space: CGFloat = CGFloat(3.0)
    let dimension = (self.view.frame.width - (CGFloat(photoPerRow - 1) * space)) / CGFloat(photoPerRow)
    
    flowLayout.minimumLineSpacing = space
    flowLayout.minimumInteritemSpacing = space
    flowLayout.itemSize = CGSize(width: dimension, height: dimension)
  }
  
  @objc func handleRefreshControl() {
    print("refreshing")
    FlickrAPI.getTotalImagePagesForPin(selectedPin, completion: handleRefreshResponse(totalPages:error:))
  }
  
  private func handleRefreshResponse(totalPages: Int?, error: Error?) {
    guard let pages = totalPages else {
      // MARK: Show alert error
      return
    }
    print(pages)
    if pages == 1 {
      // MARK: Show alert cant refresh
      print("Location has only 1 page of photos")
    } else {
      // get photos on a random page
      let randomPage = Int.random(in: 2...pages)
      print(randomPage)
      FlickrAPI.getImageURLsForLocation(coordinate: CLLocationCoordinate2D(latitude: selectedPin.lat, longitude: selectedPin.lon), onPage: randomPage, completion: handleImageURLResponse(urls:error:))
    }
  }
  
  private func handleImageURLResponse(urls: [URL]?, error: Error?) {
    // save urls to Photo
    guard let urls = urls else {
      // TODO: handles error
      print(error!.localizedDescription)
      return
    }
    // rewrite urls in stored Photos
    if let photos = fetchedResultController.fetchedObjects {
      print("\(photos.count), \(urls.count)")
      for (photo, newURL) in zip(photos, urls) {
        photo.url = newURL
      }
    }
    do {
      try dataController.viewContext.save()
    } catch {
      fatalError("not able to save url \(error.localizedDescription)")
    }
    downloadImages()
  }
  
  private func downloadImages() {
    let photos = fetchedResultController.fetchedObjects
    
    let downloadGroup = DispatchGroup()
    var storedError: NSError?
    if let photos = photos {
      for photo in photos {
        if let url = photo.url {
          downloadGroup.enter()
          FlickrAPI.downloadImage(with: url) { (data, error) in
            if error != nil {
              storedError = error as NSError?
            } else {
              photo.image = data
            }
          }
          downloadGroup.leave()
        }
      }
    }
    downloadGroup.notify(queue: DispatchQueue.main) {
      do {
        try self.dataController.viewContext.save()
        self.collectionView.refreshControl?.endRefreshing()
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
    let photo = fetchedResultController.object(at: indexPath)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
    if let data = photo.image {
      cell.imageView.image = UIImage(data: data)
    }
    return cell
  }
}
  
  extension PhotoAlbumViewController: UICollectionViewDelegateFlowLayout {
  
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
  
      return CGSize(width: 200, height: 200)
    }
  }
  
  extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      collectionView.reloadData()
    }
 
}



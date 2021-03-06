//
//  SceneDelegate.swift
//  VirtualTourist
//
//  Created by Kappa on 2020-03-09.
//  Copyright © 2020 qi. All rights reserved.
//

import UIKit
import MapKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  var mapViewController: MapViewController!
  let userDefaults = UserDefaults.standard
  let dataController = DataController(modelName: Name.model)
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    guard let _ = (scene as? UIWindowScene) else { return }
    setDataController()
    loadMapSetting()
  }

  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
//    dataController.saveContext()
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
  }
  
  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
    dataController.saveContext()
    saveMapSetting()
  }

  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.

    // Save changes in the application's managed object context when the application transitions to the background.
//    dataController.saveContext()
  }
  
  fileprivate func setDataController() {
    dataController.load()
    let navigationController = window?.rootViewController as! UINavigationController
    mapViewController = navigationController.topViewController as?  MapViewController
    mapViewController.dataController = dataController
  }
  
  fileprivate func loadMapSetting() {
    // has launched the app previously
    if let latCenter = userDefaults.value(forKey: UserDefaultsKeyMap.centerLat) as? Double,
      let lonCenter = userDefaults.value(forKey: UserDefaultsKeyMap.centerLon) as? Double,
      let latRegion = userDefaults.value(forKey: UserDefaultsKeyMap.latDelta) as? Double,
      let lonRegion = userDefaults.value(forKey: UserDefaultsKeyMap.lonDelta) as? Double {
      mapViewController.mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latCenter, longitude: lonCenter), span: MKCoordinateSpan(latitudeDelta: latRegion, longitudeDelta: lonRegion))
      // is the first time to have launched the app
    } else {
      mapViewController.mapRegion = DefaultMapSetting.region
    }
  }
  
  fileprivate func saveMapSetting() {
    let latCenter = mapViewController.mapView.centerCoordinate.latitude
    let lonCenter = mapViewController.mapView.centerCoordinate.longitude
    let latDelta = mapViewController.mapView.region.span.latitudeDelta
    let lonDelta = mapViewController.mapView.region.span.longitudeDelta
    userDefaults.set(latCenter, forKey: UserDefaultsKeyMap.centerLat)
    userDefaults.set(lonCenter, forKey: UserDefaultsKeyMap.centerLon)
    userDefaults.set(latDelta, forKey: UserDefaultsKeyMap.latDelta)
    userDefaults.set(lonDelta, forKey: UserDefaultsKeyMap.lonDelta)
  }

}


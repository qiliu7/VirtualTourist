//
//  DataController.swift
//  VirtualTourist
//
//  Created by Kappa on 2020-03-14.
//  Copyright © 2020 qi. All rights reserved.
//

import Foundation
import CoreData

class DataController {
  
  let persistenContainer: NSPersistentContainer
  
  var viewContext: NSManagedObjectContext {
    return persistenContainer.viewContext
  }
  
  init(modelName: String) {
    persistenContainer = NSPersistentContainer(name: modelName)
  }
  
  func load(completion: (() -> Void)? = nil) {
    persistenContainer.loadPersistentStores { (storeDescription, error) in
      guard error == nil else {
        fatalError(error!.localizedDescription)
      }
      completion?()
    }
  }
  
}

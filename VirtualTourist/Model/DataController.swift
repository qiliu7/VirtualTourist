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
  
  let persistentContainer: NSPersistentContainer
  
  var viewContext: NSManagedObjectContext {
    return persistentContainer.viewContext
  }
  
  init(modelName: String) {
    persistentContainer = NSPersistentContainer(name: modelName)
  }
  
  func load(completion: (() -> Void)? = nil) {
    persistentContainer.loadPersistentStores { (storeDescription, error) in
      guard error == nil else {
        fatalError(error!.localizedDescription)
      }
      completion?()
    }
  }

   func saveContext () {
       let context = persistentContainer.viewContext
       if context.hasChanges {
           do {
               try context.save()
           } catch {
               // Replace this implementation with code to handle the error appropriately.
               // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
               let nserror = error as NSError
               fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
           }
       }
   }
  
}

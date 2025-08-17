//
//  CoreDataManager.swift
//  MovieFinder
//
//  Created by Samyak Pawar on 17/08/2025.
//

import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "MovieModel")
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved Core Data error: \(error)")
            }
        }
    }
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
}

//
//  DataManager.swift
//  CoreDataMergeConflict
//
//  Created by Maxime Boulat on 3/29/17.
//  Copyright © 2017 Maxime Boulat. All rights reserved.
//

import Foundation
import CoreData

struct DataManager {
	
	
	static var rootFolder: Folder = {
		
		// Check for existence of Root folder, if it doesn't exist create it.
		let context = persistentContainer.viewContext
		
		let request = NSFetchRequest<Folder>(entityName: "Folder")
		request.predicate = NSPredicate(format: "isRoot = YES")
		let result = try! DataManager.persistentContainer.viewContext.fetch(request)
		
		let root: Folder!
		
		if result.count == 0 {
			root = Folder(context: context)
			root.isRoot = true
			try! context.save()
		}
		else {
			root = result[0]
		}
		
		return root
	}()
	
	static var persistentContainer: NSPersistentContainer = {
		/*
		The persistent container for the application. This implementation
		creates and returns a container, having loaded the store for the
		application to it. This property is optional since there are legitimate
		error conditions that could cause the creation of the store to fail.
		*/
		let container = NSPersistentContainer(name: "CoreDataMergeConflict")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				
				/*
				Typical reasons for an error here include:
				* The parent directory does not exist, cannot be created, or disallows writing.
				* The persistent store is not accessible, due to permissions or data protection when the device is locked.
				* The device is out of space.
				* The store could not be migrated to the current model version.
				Check the error message to determine what the actual problem was.
				*/
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		container.viewContext.automaticallyMergesChangesFromParent = true
		return container
	}()
	
	static func insertPhoto(with name: String, and data: Data) {
		
		self.persistentContainer.performBackgroundTask { (context) in
			
//			context.mergePolicy = NSMergePolicy.overwrite
			
			let new = Photo(context: context)
			new.name = name
			new.data = data as NSData
			
			let corresponding = try! context.existingObject(with: rootFolder.objectID) as! Folder
			new.parent = corresponding
			
			try! context.save()
		}
		
	}
	
}

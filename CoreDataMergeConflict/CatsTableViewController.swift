//
//  CatsTableViewController.swift
//  CoreDataMergeConflict
//
//  Created by Maxime Boulat on 3/29/17.
//  Copyright © 2017 Maxime Boulat. All rights reserved.
//

import UIKit
import CoreData

class CatsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
	
	let cats: NSFetchedResultsController<Photo> = {
		
		let request = NSFetchRequest<Photo>(entityName: "Photo")
		request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
		request.predicate = NSPredicate(format: "parent = %@", DataManager.rootFolder)
		let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: DataManager.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		
		return frc
		
	}()
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		cats.delegate = self
		try! cats.performFetch()
	}
	
	// MARK: - Actions
	

	@IBAction func didPressAdd(_ sender: Any) {
		
		let alert = UIAlertController(title: nil, message: "Choose a source", preferredStyle: .alert)
		
		let addOne = UIAlertAction(title: "Add one cat", style: .default) {(action) in
			
			let imageData = UIImageJPEGRepresentation(#imageLiteral(resourceName: "cat"), 0.5)
			DataManager.insertPhoto(with: "cat", and: imageData!)
		}
		
		// This is what is failing... Multiple concurrent background transactions cause NSMergeConflict....
		let addMultiple = UIAlertAction(title: "Add multiple cats", style: .default) {(action) in
			
			let bundlePath = Bundle.main.resourceURL!
			
			let directoryEnumerator = FileManager.default.enumerator(at: bundlePath, includingPropertiesForKeys: [URLResourceKey.isDirectoryKey, URLResourceKey.nameKey])
			while let url = directoryEnumerator?.nextObject() as? URL {
				
				if url.pathExtension == "jpeg" {
					let imageData = try! Data(contentsOf: url)
					DataManager.insertPhoto(with: url.lastPathComponent, and: imageData)
				}
			}
		}
		
		alert.addAction(addOne)
		alert.addAction(addMultiple)
		self.navigationController?.present(alert, animated: true, completion: nil)
		
	}
	
	// MARK: - Tableview methods
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 1
	}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cats.fetchedObjects!.count
    }

	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cat = cats.fetchedObjects![indexPath.row]
		
        let cell = tableView.dequeueReusableCell(withIdentifier: "CatCell", for: indexPath)
		cell.textLabel?.text = cat.name
		cell.imageView?.image = UIImage(data: cat.data as! Data)

        // Configure the cell...

        return cell
    }
	
	// MARK: - NSFetchedResultsControllerDelegate methods

	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>){
		tableView.beginUpdates()
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
	                didChange anObject: Any,
	                at indexPath: IndexPath?,
	                for type: NSFetchedResultsChangeType,
	                newIndexPath: IndexPath?){
		
		switch type {
		case .insert:
			tableView.insertRows(at: [newIndexPath!], with: .automatic)
		case .delete:
			tableView.deleteRows(at: [indexPath!], with: .automatic)
		case .move:
			tableView.deleteRows(at: [indexPath!], with: .automatic)
			tableView.insertRows(at: [newIndexPath!], with: .automatic)
		default:
			break
		}
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>){
		tableView.endUpdates()
	}

}

//
//  StorageManager.swift
//  TaskList
//
//  Created by Максим Назаров on 30.09.2024.
//

import CoreData

final class StorageManager {
    
    static let shared = StorageManager()
    
    // MARK: - Core Data stack
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    private let viewContext: NSManagedObjectContext

    private init() {
        viewContext = persistentContainer.viewContext
    }
    
    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Create Data
    func create(_ taskName: String, completion: (ToDoTask) -> Void) {
        let task = ToDoTask(context: viewContext)
        task.title = taskName
        completion(task)
        saveContext()
    }
    // MARK: - Read Data
    func fetchData(completion: (Result<[ToDoTask], Error>) -> Void) {
        let fetchRequest = ToDoTask.fetchRequest()
        
        do {
            let tasks = try viewContext.fetch(fetchRequest)
            completion(.success(tasks))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    // MARK: - Update Data
    func update(_ task: ToDoTask, newName: String) {
        task.title = newName
        saveContext()
    }
    
    // MARK: - Delete data
    func deleteContext(object: NSManagedObject) {
        viewContext.delete(object)
        saveContext()
    }
    
}

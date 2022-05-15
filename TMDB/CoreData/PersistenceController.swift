//
//  PersistenceController.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 03-05-22.
//

import CoreData


//MARK: Clase encargada de Core Data. Altamente basada de acuerdo a las prácticas de Apple: https://developer.apple.com/documentation/coredata/loading_and_displaying_a_large_data_feed

final class PersistenceController {
    
    private let inMemory: Bool
    private var notificationToken: NSObjectProtocol?
    static let shared = PersistenceController()
    
    private init(inMemory: Bool = false) {
        self.inMemory = inMemory
//        ValueTransformer.setValueTransformer(CastTransformer(),
//                                                 forName: NSValueTransformerName("CastTransformer"))
        // Observe Core Data remote change notifications on the queue where the changes were made.
        notificationToken = NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: nil, queue: nil) { note in
            print("Received a persistent store remote change notification.")
            Task {
                await self.fetchPersistentHistory()
            }
        }
    }
    
    deinit {
        if let observer = notificationToken {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    /// A peristent history token used for fetching transactions from the store.
    private var lastToken: NSPersistentHistoryToken?
    
    /// A persistent container to set up the Core Data stack.
    lazy var container: NSPersistentContainer = {
        
        /// - Tag: persistentContainer
        let container = NSPersistentContainer(name: "MovieCDModel")
        
        guard let description = container.persistentStoreDescriptions.first else {
            //Mejor manejo
            fatalError("Failed to retrieve a persistent store description.")
        }
        
        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Enable persistent store remote change notifications
        /// - Tag: persistentStoreRemoteChange
        description.setOption(true as NSNumber,
                              forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        // Enable persistent history tracking
        /// - Tag: persistentHistoryTracking
        description.setOption(true as NSNumber,
                              forKey: NSPersistentHistoryTrackingKey)
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // This app refreshes UI by consuming store changes via persistent history tracking.
        /// - Tag: viewContextMergeParentChanges
        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.name = "viewContext"
        /// - Tag: viewContextMergePolicy
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        return container
    }()
    
    
    func importMovies(from propertiesList: [FullMovieModel]) async throws {
        guard !propertiesList.isEmpty else { return }
        
        let taskContext = newTaskContext()
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importMovies"

            print("BEFORE")
        try await taskContext.perform {
                print("DURING")
                let batchInsertRequest = self.newBatchInsertRequest(with: propertiesList)
                
                if let fetchResult = try? taskContext.execute(batchInsertRequest),
                   let batchInsertResult = fetchResult as? NSBatchInsertResult,
                   let success = batchInsertResult.result as? Bool, success {
                    return
                }else{
                    print("Failed to execute batch insert request.")
                    throw CoreDataError.batchInsertError
                }
         }
        print("AFTER")
        print("Successfully inserted data.")
        
        
    }
    

}

//MARK: Funciones encargadas de guardar la información (Películas) en CoreData en formato de batches para un bajo uso de RAM.
extension PersistenceController{
    private func newBatchInsertRequest(with propertyList: [FullMovieModel]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count
        
        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: MovieModelCD.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            dictionary.addEntries(from: propertyList[index].dictionaryValue)
            index += 1
            return false
        })
        return batchInsertRequest
    }
    
    /// Creates and configures a private queue context.
    private func newTaskContext() -> NSManagedObjectContext {
        // Create a private queue context.
        /// - Tag: newBackgroundContext
        let taskContext = container.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        // Set unused undoManager to nil for macOS (it is nil by default on iOS)
        // to reduce resource requirements.
        taskContext.undoManager = nil
        return taskContext
    }
    
    func fetchPersistentHistory() async {
        do {
            try await fetchPersistentHistoryTransactionsAndChanges()
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    private func fetchPersistentHistoryTransactionsAndChanges() async throws {
        let taskContext = newTaskContext()
        taskContext.name = "persistentHistoryContext"
        print("Start fetching persistent history changes from the store...")
        
            try await taskContext.perform {
                // Execute the persistent history change since the last transaction.
                /// - Tag: fetchHistory
                let changeRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: self.lastToken)
                let historyResult = try taskContext.execute(changeRequest) as? NSPersistentHistoryResult
                if let history = historyResult?.result as? [NSPersistentHistoryTransaction],
                   !history.isEmpty {
                    self.mergePersistentHistoryChanges(from: history)
                    return
                }else{
                    print("No persistent history transactions found.")
                    throw CoreDataError.persistentHistoryChangeError
                }
            }
        print("Finished merging history changes.")
    }
    
    private func mergePersistentHistoryChanges(from history: [NSPersistentHistoryTransaction]) {
        print("Received \(history.count) persistent history transactions.")
        // Update view context with objectIDs from history change request.
        /// - Tag: mergeChanges
        let viewContext = container.viewContext
        viewContext.perform {
            for transaction in history {
                viewContext.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
                self.lastToken = transaction.token
            }
        }
    }
}

extension NSManagedObjectContext {
    @available(iOS, deprecated: 15, message: "Only for iOS 13 and 14")
    func perform<T>(_ block: @escaping () throws -> T) async throws -> T {
  
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<T, Error>) in
            perform {
                let result = Result { try block() }
                continuation.resume(with: result)
            }

        }
    }
}



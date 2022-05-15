//
//  PersistenceController2.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 04-05-22.
//

import CoreData
import SwiftUI

//MARK: Clase encargada de CoreData. Esta es una forma más sencilla, comparada con PersistenceController, el cual añade las películas a través del contexto (no por batches).
final class PersistenceController2 {
    static let shared = PersistenceController2()
    
    private init(){}

    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MovieCDModel")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
}


extension PersistenceController2{

    func importMovies(from pelis: [FullMovieModel], category: MovieCategory) async throws {
        
        let backgroundContext = newTaskContext()
        
        try await backgroundContext.perform{

               for peli in pelis{
                   let movie = MovieModelCD(context: backgroundContext)
                   movie.genres = peli.genres.first?.name ?? "Desconocido"
                   movie.voteCount = Int64(peli.voteCount)
                   movie.voteAverage = peli.voteAverage
                   movie.releaseDate = peli.releaseDate
                   movie.overview = peli.overview
                   movie.posterPath = peli.posterPath
                   movie.popularity = peli.popularity
                   movie.runtime = Int64(peli.runtime ?? 0)
                   movie.id = Int64(peli.id)
                   movie.budget = Int64(peli.budget)
                   movie.title = peli.title
                   movie.revenue = Int64(peli.revenue)
                   movie.tagline = peli.tagline
                   movie.credits  = peli.credits
                   movie.category = category
               }
               
               if backgroundContext.hasChanges{
                   do {
                       try backgroundContext.save()
                       print("Películas guardadas con éxito")
                   } catch  {
                      throw CoreDataError.savingError
                   }
               }
           }
    }
    
    private func newTaskContext() -> NSManagedObjectContext {
        let taskContext = container.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return taskContext
    }
    
}

//MARK: Extension del modelo de coredata que permite trabajar con facilidad algunas propiedades. Los elementos más complejos como los credits (actores, productores y directores) se codifican a JSON, por lo que se guardan en formato de string en Coredata.
extension MovieModelCD {
    
    var credits : Credits {
        get {
            return (try? JSONDecoder().decode(Credits.self, from: Data(credits_!.utf8))) ?? Credits(cast: [], crew: [])
        }
        set {
           do {
               let crewTest = try JSONEncoder().encode(newValue)
               credits_ = String(data: crewTest, encoding:.utf8)!
           } catch { credits_ = "" }
        }
    }
    
    var directors: [Cast2] {
        credits.crew.filter { $0.job!.lowercased() == "director" }
    }
    
    var producers: [Cast2] {
        credits.crew.filter { $0.job!.lowercased() == "producer" }
    }
    
    var cast:[Cast2]{
        credits.cast
    }
    
    var category: MovieCategory {
        get {
            MovieCategory(rawValue: category_!) ?? .unknown
        }
        set {
            category_ = newValue.rawValue
        }
    }
    
    
    
}

enum MovieCategory: String {
    case popular, search, topRated, unknown
}

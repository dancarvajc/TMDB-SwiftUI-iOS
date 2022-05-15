//
//  FullMovieModel.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 29-04-22.
//

import Foundation
import UIKit
// MARK: - FullMovieModel, contiene toda la información de la película
struct FullMovieModel: Codable, Identifiable {

    
    let budget: Int
    let genres: [Genre]
    let id: Int
    let originalLanguage: String
    let popularity: Double
    let posterPath,overview: String?
    let productionCompanies: [ProductionCompany]
    let productionCountries: [ProductionCountry]
    let releaseDate: String
    let revenue: Int
    let runtime: Int?
    let tagline:String?
    let title: String
    let voteAverage: Double
    let voteCount: Int
    let credits: Credits

    var identy:String{
        String(id)+(releaseDate)
    }
    
//    var crewString: String {
//        do {
//            let crewData = try JSONEncoder().encode(credits.cast)
//            return String(data: crewData, encoding:.utf8)!
//        } catch { return  "" }
//    }
    
    var dictionaryValue: [String: Any] {
        [
            "budget": budget,
            "genres": genres.first?.name,
            "id": id,
            "popularity": popularity,
//            "posterPath": posterPath,
            "overview": overview,
            "releaseDate": releaseDate,
            "revenue": revenue,
            "runtime": runtime,
            "tagline": tagline,
            "title": title,
            "voteAverage": voteAverage,
            "voteCount": voteCount,
            "cast": credits.cast
        ]
    }

    enum CodingKeys: String, CodingKey {
        case budget, genres, id
        case originalLanguage = "original_language"
        case overview, popularity
        case posterPath = "poster_path"
        case productionCompanies = "production_companies"
        case productionCountries = "production_countries"
        case releaseDate = "release_date"
        case revenue, runtime
        case tagline, title
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case credits
    }
    
    var directors: [Cast2] {
        credits.crew.filter { $0.job!.lowercased() == "director" }
    }
    
    var producers: [Cast2] {
        credits.crew.filter { $0.job!.lowercased() == "producer" }
    }
    
   
    
}

//MARK: Otros Models para la ayuda de FullMovieModel

// Credits
struct Credits: Codable {
    let cast, crew: [Cast2]
}

//  Cast
public class Cast: NSObject, Codable, NSSecureCoding {
    
    public static var supportsSecureCoding: Bool = true
    
    enum Keys:String {
        case id,name,profilePath, castID, gender, character, creditID, job
    }
    
    public func encode(with coder: NSCoder) {
    
        coder.encode(id, forKey: Keys.id.rawValue)
        coder.encode(name, forKey: Keys.name.rawValue)
        coder.encode(profilePath, forKey: Keys.profilePath.rawValue)
        coder.encode(castID, forKey: Keys.castID.rawValue)
        coder.encode(gender, forKey: Keys.gender.rawValue)
        coder.encode(character, forKey: Keys.character.rawValue)
        coder.encode(creditID, forKey: Keys.creditID.rawValue)
        coder.encode(job, forKey: Keys.job.rawValue)
    }
    
    public required init?(coder: NSCoder) {
        
        self.id =  coder.decodeInteger(forKey: Keys.id.rawValue)
        self.name = coder.decodeObject(forKey: Keys.name.rawValue) as! String
        self.profilePath = coder.decodeObject(forKey: Keys.profilePath.rawValue) as? String
        self.castID = coder.decodeObject(forKey: Keys.castID.rawValue) as? Int
        self.gender = coder.decodeObject(forKey: Keys.gender.rawValue) as? Int
        self.character = coder.decodeObject(forKey: Keys.character.rawValue) as? String
        self.creditID = coder.decodeObject(forKey: Keys.creditID.rawValue) as? String ?? "asda"
        self.job = coder.decodeObject(forKey: Keys.job.rawValue) as? String
    }
    
    let id: Int
    let name: String
    let profilePath: String?
    let castID, gender: Int?
    let character: String?
    let creditID: String
    let job: String?
    
    var identy:String{
        String(id)+(job ?? "")
    }

    enum CodingKeys: String, CodingKey {
        case gender, id
        case name
        case profilePath = "profile_path"
        case castID = "cast_id"
        case character
        case creditID = "credit_id"
        case job
    }
}

//Cast2
struct Cast2: Codable {
    
    
    let id: Int
    let name: String
    let profilePath: String?
    let castID, gender: Int?
    let character: String?
    let creditID: String
    let job: String?
    
    var identy:String{
        String(id)+(job ?? "")
    }

    enum CodingKeys: String, CodingKey {
        case gender, id
        case name
        case profilePath = "profile_path"
        case castID = "cast_id"
        case character
        case creditID = "credit_id"
        case job
    }
}

// Genre
struct Genre: Codable {
    let id: Int
    let name: String
}

// ProductionCompany
struct ProductionCompany: Codable {
    let id: Int
    let logoPath: String?
    let name, originCountry: String

    enum CodingKeys: String, CodingKey {
        case id
        case logoPath = "logo_path"
        case name
        case originCountry = "origin_country"
    }
}

// ProductionCountry
struct ProductionCountry: Codable, Identifiable {
    let id: UUID = UUID()
    
    let iso3166_1, name: String
    
    enum CodingKeys: String, CodingKey {
        case iso3166_1 = "iso_3166_1"
        case name
    }
}



//MARK: Ejemplos para preview
extension FullMovieModel{
    
    static let example1 = FullMovieModel(budget: 1000, genres: [.init(id: 22, name: "Drama")], id: 1, originalLanguage: "en", popularity: 7.5, posterPath: "/74xTEgt7R36Fpooo50r9T25onhq.jpg", overview: "In his second year of fighting crime, Batman uncovers corruption in Gotham City that connects to his own family while facing a serial killer known as the Riddler. In his second year of fighting crime, Batman uncovers corruption in Gotham City that connects to his own family while facing a serial killer known as the Riddler. In his second year of fighting crime, Batman uncovers corruption in Gotham City that connects to his own family while facing a serial killer known as the Riddler. In his second year of fighting crime, Batman uncovers corruption in Gotham City that connects to his own family while facing a serial killer known as the Riddler. In his second year of fighting crime, Batman uncovers corruption in Gotham City that connects to his own family while facing a serial killer known as the Riddler", productionCompanies: [.init(id: 1, logoPath: "asdasd", name: "fox 20", originCountry: "en")], productionCountries: [ProductionCountry(iso3166_1: "asda", name: "en")], releaseDate: "10-02-1996", revenue: 500000, runtime: 132, tagline: "peli muy buena", title: "The Batnam", voteAverage: 8.6, voteCount: 8999, credits: Credits(cast: [], crew: []))
    static let example2 = FullMovieModel(budget: 1000, genres: [.init(id: 22, name: "Drama")], id: 2, originalLanguage: "en", popularity: 7.5, posterPath: "/74xTEgt7R36Fpooo50r9T25onhq.jpg", overview: "In his second year of fighting crime, Batman uncovers corruption in Gotham City that connects to his own family while facing a serial killer known as the Riddler. In his second year of fighting crime, Batman uncovers corruption in Gotham City that connects to his own family while facing a serial killer known as the Riddler. In his second year of fighting crime, Batman uncovers corruption in Gotham City that connects to his own family while facing a serial killer known as the Riddler. In his second year of fighting crime, Batman uncovers corruption in Gotham City that connects to his own family while facing a serial killer known as the Riddler. In his second year of fighting crime, Batman uncovers corruption in Gotham City that connects to his own family while facing a serial killer known as the Riddler", productionCompanies: [.init(id: 1, logoPath: "asdasd", name: "fox 20", originCountry: "en")], productionCountries: [ProductionCountry(iso3166_1: "asda", name: "en")], releaseDate: "10-02-1996", revenue: 500000, runtime: 132, tagline: "peli muy buena", title: "The Batnam", voteAverage: 8.6, voteCount: 8999, credits: Credits(cast: [], crew: []))
    static let example3 = FullMovieModel(budget: 1000, genres: [.init(id: 22, name: "Drama")], id: 3, originalLanguage: "en", popularity: 7.5, posterPath: "/74xTEgt7R36Fpooo50r9T25onhq.jpg", overview: "In his second year of fighting crime, Batman uncovers corruption in Gotham City that connects to his own family while facing a serial killer known as the Riddler. In his second year of fighting crime, Batman uncovers corruption in Gotham City that connects to his own family while facing a serial killer known as the Riddler. In his second year of fighting crime, Batman uncovers corruption in Gotham City that connects to his own family while facing a serial killer known as the Riddler. In his second year of fighting crime, Batman uncovers corruption in Gotham City that connects to his own family while facing a serial killer known as the Riddler. In his second year of fighting crime, Batman uncovers corruption in Gotham City that connects to his own family while facing a serial killer known as the Riddler", productionCompanies: [.init(id: 1, logoPath: "asdasd", name: "fox 20", originCountry: "en")], productionCountries: [ProductionCountry(iso3166_1: "asda", name: "en")], releaseDate: "10-02-1996", revenue: 500000, runtime: 132, tagline: "peli muy buena", title: "The Batnam", voteAverage: 8.6, voteCount: 8999, credits: Credits(cast: [], crew: []))
    static let example4 = FullMovieModel(budget: 1000, genres: [.init(id: 22, name: "Drama")], id: 4, originalLanguage: "en", popularity: 7.5, posterPath: "/74xTEgt7R36Fpooo50r9T25onhq.jpg", overview: "In his second year of fighting crime, Batman uncovers corruption in Gotham City that connects to his own family while facing a serial killer known as the Riddler. In his second year of fighting crime, Batman uncovers corruption in Gotham City that connects to his own family while facing a serial killer known as the Riddler. In his second year of fighting crime, Batman uncovers corruption in Gotham City that connects to his own family while facing a serial killer known as the Riddler. In his second year of fighting crime, Batman uncovers corruption in Gotham City that connects to his own family while facing a serial killer known as the Riddler. In his second year of fighting crime, Batman uncovers corruption in Gotham City that connects to his own family while facing a serial killer known as the Riddler", productionCompanies: [.init(id: 1, logoPath: "asdasd", name: "fox 20", originCountry: "en")], productionCountries: [ProductionCountry(iso3166_1: "asda", name: "en")], releaseDate: "10-02-1996", revenue: 500000, runtime: 132, tagline: "peli muy buena", title: "The Batnam", voteAverage: 8.6, voteCount: 8999, credits: Credits(cast: [], crew: []))
}

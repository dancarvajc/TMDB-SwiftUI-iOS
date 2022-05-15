//
//  UserModel.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 23-04-22.
//

import Foundation

//MARK: Modelo para el usuario que se quiera logear en TMDB através de la app
struct UserModel: Codable {
    let avatar: Avatar
    let id: Int
    let iso639_1, iso3166_1, name: String
    let includeAdult: Bool
    let username: String

    enum CodingKeys: String, CodingKey {
        case avatar, id
        case iso639_1 = "iso_639_1"
        case iso3166_1 = "iso_3166_1"
        case name
        case includeAdult = "include_adult"
        case username
    }
}

// MARK: - Avatar
struct Avatar: Codable {
    let gravatar: Gravatar
}

// MARK: - Gravatar
struct Gravatar: Codable {
    let hash: String
}

//
//  Keychain.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 02-05-22.
//

import Foundation
import KeychainAccess


//MARK: Se encarga de guardar, eliminar y obtener la sessionID del usuario de la Keychain
struct KeychainManager {
    
    private let keychain = Keychain(service: "TMDBSwiftUI")
    
    func saveSessionID(_ sessionID:String) throws  {
        
        do {
            try keychain.set(sessionID, key: "userSessionID")
        }
        catch {
            throw KeychainError.savingError
        }
    }
    
    func deleteSessionID() throws {
        do {
            try keychain.remove("userSessionID")
        } catch {
            throw KeychainError.deletingError
        }
    }
    
    func getSessionID() throws -> String {
        var token = ""
        
        do {
            token = try keychain.get("userSessionID") ?? ""
         
        } catch  {
            throw KeychainError.gettingError
        }
        return token
    }
    
}



//
//  Errors.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 24-04-22.
//

import Foundation

// MARK: Errores para las películas
enum MovieServiceError: Error, LocalizedError{
    case invalidServerResponse
    case failedDecode
    case badInternet
    case failedtoRequestNewToken
    
    var errorDescription: String?{
        switch self {
        case .invalidServerResponse:
            return NSLocalizedString("El servidor está con problemas", comment: "")
        case .failedDecode:
            return NSLocalizedString("Hubo un error al decodificar, intenta nuevamente", comment: "")
        case .badInternet:
            return NSLocalizedString("Al parecer hay problemas de conexión a Internet", comment: "ghjk")
        case .failedtoRequestNewToken:
            return NSLocalizedString("Hubo un error en la autenticación. Intenta nuevamente", comment: "")
        }
    }
}

//MARK: Otros errores
enum OthersErrors: Error, LocalizedError {
    case cantGetToken
    case cantCreateURL
    case userDeniedAuth
    case userCanceledAuth
    
    var errorDescription: String?{
        switch self {
        case .cantGetToken:
            return NSLocalizedString("No se pudo obtener el token de autorización. Intenta nuevamente", comment: "")
        case .cantCreateURL:
            return NSLocalizedString("No se pudo crear la URL", comment: "")
        case .userDeniedAuth:
            return NSLocalizedString("El usuario no autorizó a la autenticación", comment: "")
        case .userCanceledAuth:
            return NSLocalizedString("", comment: "")
        }
    }
}

//MARK: Errores de Keychain
enum KeychainError: Error, LocalizedError{
    
    case savingError, gettingError, deletingError
    
    var errorDescription: String?{
        switch self {
        case .savingError:
            return NSLocalizedString("No se pudo guardar la sessión. Intenta nuevamente", comment: "")
        case .gettingError:
            return NSLocalizedString("Hubo un errror obteniendo tu sesión", comment: "")
        case .deletingError:
            return NSLocalizedString("No se pudo borrar la sesión. Intenta nuevamente.", comment: "")
        }
    }
    
    
}

//MARK: Errores de CoreData
enum CoreDataError: Error, LocalizedError{
    
    case persistentHistoryChangeError, batchInsertError, deletingError, savingError
    
    var errorDescription: String?{
        switch self {
        case .persistentHistoryChangeError:
            return NSLocalizedString("persistentHistoryChangeError", comment: "")
        case .batchInsertError:
            return NSLocalizedString("Hubo un error en la inserción en CD", comment: "")
        case .savingError:
            return NSLocalizedString("Hubo un error en la inserción en CD", comment: "")
        case .deletingError:
            return NSLocalizedString("No se pudo borrar la sesión. Intenta nuevamente.", comment: "")
        }
    }
    
    
}

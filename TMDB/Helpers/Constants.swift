//
//  Constants.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 22-04-22.
//

import Foundation
import Nuke


//MARK: Constantes que se usan en cualquier lado de la app
struct Constants{
    
    static let gravatarURL = "https://www.gravatar.com/avatar/"
    
    struct ImageFetch {
        static let base_url      = "https://image.tmdb.org/t/p/"
        static let size92        = "w92"
        static let size154       = "w154"
        static let size185       = "w185"
        static let size342       = "w342"
        static let size500       = "w500"
        static let size780       = "w780"
        static let originalSize  = "original"
        
    }
    
    //MARK: completion (closure) que permite saber si cargó o no correctamente una imagen y gestionar el internet con ello. Es el para todas las imágenes (LazyImage) por eso lo puse como constante.
    
    static func onCompletionLazyImage(networkVM: NetworkViewModel) -> (Result<ImageResponse, Error>)->() {
        return { (result: Result<ImageResponse, Error>) in
            
            switch result {
                
            case .success(let sucess):
                
                //Si la imagen carga de caché, no hace nada (puede o no que tenga internet), sino significa que cargó desde internet
                if sucess.cacheType == .memory || sucess.cacheType == .disk {
                    
                }else{
                    networkVM.noInternet = false
                }
                
                //                if !(sucess.cacheType == .memory || sucess.cacheType == .disk) {
                //                    NetworkManager.shared.noInternet = false
                //                }
                
                case .failure(let error):
                
                //Si falla la carga de imagen, no hay internet o la URL está mala
                let error2 = error as! Nuke.ImagePipeline.Error
                
                if error2.description.contains("Response status code was unacceptable"){
                    print("Error en la URL de la imagen")
                    networkVM.noInternet = false
                    return
                }
                
                if let error2 = error2.dataLoadingError as? URLError{
                    switch error2.code{
                    case .dataNotAllowed:
                        print("NO IINTERNET POR NO DATOS??")
                        networkVM.noInternet = true
                    case .notConnectedToInternet:
                        print("NO INTERNETTTT DE URL?")
                        networkVM.noInternet = true
                    default:
                        break
                    }
                }
            }
        }
    }
}



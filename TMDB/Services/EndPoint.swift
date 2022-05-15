//
//  EndPoint.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 25-04-22.
//

import Foundation


//MARK: Enum que permite organizar las direcciones de la API y almacenar los diferentes paths
enum EndPoint {
    
    private static let baseURL = "https://api.themoviedb.org/3/"
    #warning("PONER TU API DE TMDB.ORG AQUÍ PARA LAS CONSULTAS")
    static let apiKey = "" //<---- PONER TU API DE TMDB.ORG AQUÍ PARA LAS CONSULTAS
    static let authStep2 = "https://www.themoviedb.org/authenticate/" //URL que se muestra en un navegador para la autenticación
    
    
    //MARK: Función que permite crear un URLREQUEST de cualquier tipo (enum HTTPMethod) agregando query y body
    static func createURLRequest(url: Route, method: HTTPMethod, query: [String: String]? = nil, parameters: [String: Any]? = nil) throws -> URLRequest {
        
        
        //URLs
        let urlString = EndPoint.baseURL + url.rawValue
        let URL = URL(string: urlString)!
        
        var urlRequest = URLRequest(url: URL)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type") //header
        urlRequest.httpMethod = method.rawValue
        
        
        //Si se pasan elementos en la query se agregan
        if let query = query {
            var urlComponent = URLComponents(string: urlString)
            urlComponent?.queryItems = query.map { URLQueryItem(name: $0, value: $1) }
            urlRequest.url = urlComponent?.url
        }
        
        //Si se pasan parametros para el body se agregan
        if let parameters = parameters {
            do{
                let bodyData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                //let bodyData = try JSONEncoder().encode(parameters)
                urlRequest.httpBody = bodyData
            }catch{
                throw OthersErrors.cantCreateURL
            }
        }
        return urlRequest
    }
}


enum HTTPMethod: String {
    case GET, POST, DELETE
}


//Diferentes direcciones de la API
enum Route: Equatable {
    case popularMovies
    case accountInfo
    case authStep1
    case authStep3
    case logOut
    case setfavoriteMovie(String)
    case getFavoritesMovies(String)
    case topRatedMovies
    case movie(String)
    case searchMovie
    
    
    var rawValue: String {
        switch self {
        case .setfavoriteMovie(let accID):
             return "account/\(accID)/favorite"
        case .popularMovies:
             return "movie/popular"
        case .accountInfo:
            return "account"
        case .authStep1:
            return "authentication/token/new"
        case .authStep3:
            return "authentication/session/new"
        case .logOut:
            return "authentication/session"
        case .getFavoritesMovies(let accID):
            return "account/\(accID)/favorite/movies"
        case .topRatedMovies:
            return "movie/top_rated"
        case .movie(let id):
            return "movie/\(id)"
        case .searchMovie:
            return"search/movie"
        }
    }
    
}

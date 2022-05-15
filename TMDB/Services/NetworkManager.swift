//
//  MovieService.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 22-04-22.
//

import Foundation
import AsyncCompatibilityKit
import AuthenticationServices
import Combine
import Network


//MARK: Clase que maneja la conexión a internet, peticiones HTTP y autenticación
final class NetworkManager:NSObject {
    
    @Published var noInternet: Bool = false
    @Published var noWifinoCelularData = false
    
    private let monitor = NWPathMonitor()
    
    
    override init() {
        super.init()
        detectWIFIandData() //Se empieza el escaneo de wifi y datos
    }
    
    // Sessión usada para las peiticiones HTTP
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        
        // configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.timeoutIntervalForResource = 5 // Se esperan 5 segundos para la trasnferencia de datos, sino, "no hay internet".
        
        return URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
    }()
    
    
    //MARK: Función genérica que hace un http request. Permite hacer GET POST y DELETE.
    func makeHTTPRequest<T:Decodable>(url: URLRequest) async throws-> T {
        
        var data: Data
        var response: URLResponse
        
        // Se consume la API. Se hace un DO-Catch para personalizar el error a uno de MovieServiceError
        do {
            (data, response) = try await session.data(for: url)
            
        } catch {
            throw MovieServiceError.badInternet
        }
        
        //Se verifica la respuesta HTTP
        guard (response as? HTTPURLResponse)?.statusCode == 200 || (response as? HTTPURLResponse)?.statusCode == 201 else {
            
            throw MovieServiceError.invalidServerResponse
        }
        
        //Se convierten los datos de JSON a objetos MovieModel, sino tira un error
        do {
            let dataDecoded = try JSONDecoder().decode(T.self, from: data)
            
            return dataDecoded
        } catch  {
            throw MovieServiceError.failedDecode
        }
        
    }
}

// MARK: Servicio de Autentication
extension NetworkManager{
    
    //MARK: Versión asincrónica (async) de función que hace autenticación mostrando un navegador
    func signInAsync(requestToken: String) async throws -> String {
        
        try await withCheckedThrowingContinuation { (continuation:CheckedContinuation<String, Error>) in
            
            self.webAuth(requestToken: requestToken) { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    //MARK: Función para la autenticación mostrando el navegador
    private func webAuth(requestToken: String,completion: @escaping (Result<String, Error>) -> Void) {
        
        let scheme = "exampleauth" //scheme para que vuelva a la app después que el ingerso ha sido con éxito o fail ??
        
        //Se genera la sessión de autenticación (Se muestra el navegador con la web TMDB)
        let sessionAuth = ASWebAuthenticationSession(url: URL(string: EndPoint.authStep2+requestToken+"?redirect_to=exampleauth://auth")!, callbackURLScheme: scheme)
        { callbackURL, error in
            
            guard error == nil, let callbackURL = callbackURL else {
                completion(.failure(OthersErrors.userCanceledAuth))
                return
            }
            
            //Si puso sus datos y autorizó o denegó el permiso, esta función entrega como resultado una URL con un token y la autorización (permitió o denegó)
            let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
            
            //Se asegura que no se denegó el login
            guard ((queryItems?.filter({ $0.name == "denied" }).first?.value) != nil) == false else{
                completion(.failure(OthersErrors.userDeniedAuth))
                return
            }
            
            //Se obtiene el token de autorización
            let token:String? = queryItems?.filter({ $0.name == "request_token" }).first?.value
            guard let token = token else{
                completion(.failure(OthersErrors.cantGetToken))
                return
            }
            completion(.success(token))
        }
        sessionAuth.presentationContextProvider = self
        // sessionAuth.prefersEphemeralWebBrowserSession = true
        sessionAuth.start() //Se inicia la autenticación (muestra la web)
    }
    
}

// MARK: Extension para ASWebAuthenticationSession
extension NetworkManager: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}

//MARK: Detector de wifi y datos con NWPathMonitor
extension NetworkManager {
    
    private func detectWIFIandData() {
        
        monitor.start(queue: .main)
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied{
                print("TENEMOS WIFI/DATA")
                self.noWifinoCelularData = false
                self.noInternet = false
            }else{
                print("NO HAY WIFI/DATA")
                self.noWifinoCelularData = true
                self.noInternet = true
            }
        }
    }
}

//MARK: Delegado para la detección de conexión a Internet
extension NetworkManager: URLSessionTaskDelegate, URLSessionDataDelegate {
    
    //Permite saber cuando no hay internet
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        print("SIN INTERNET")
        
        noInternet = true
        
    }
    
    //Permite saber de dónde obtuvo (caché, server, etc) la petición HTTP. Con esto se puede cambiar el estado de si tiene Internet o no el usuario
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        
        //Si hubo un error en alguna petición http, no hay internet
        guard task.error == nil, let metric = metrics.transactionMetrics.first?.resourceFetchType else {
            print("HUBO UN TASK ERROR QUE NO ES NIL")
            noInternet = true
            return
        }
        
        
        switch metric{
        case .unknown:
            print("RECURSO OBTENIDO DE UNKNOW")
            break
        case .networkLoad, .serverPush:
            print("RECURSO OBTENIDO DE NEWORKLOAD, SERVERPUSH")
            noInternet = false
        case .localCache:
            print("RECURSO OBTENIDO DE CACHE")
            break
        @unknown default:
            print("RECURSO OBTENIDO DE DEFAULT")
            break
        }
        
    }
    
}

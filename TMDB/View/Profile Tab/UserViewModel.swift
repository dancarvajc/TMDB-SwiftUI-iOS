//
//  UserViewModel.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 25-04-22.
//

import Foundation
import SwiftUI
import AuthenticationServices

final class UserViewModel: ObservableObject {
    
    @Published var user: UserModel?
    @Published var isLoading: Bool = false
    @Published var alertMessage:String = ""
    @Published var showAlert = false
    
    private let service: NetworkManager
    let keychainM: KeychainManager //no se deja privado para acceder en algunas views
    
    init(service: NetworkManager, keychainM: KeychainManager) {
        
        self.service = service
        self.keychainM = keychainM
    }
    
    @MainActor func getUserInfo() async  {

        isLoading = true
        
        do {
            let urlRequest = try EndPoint.createURLRequest(url: .accountInfo, method: .GET, query: ["api_key" : EndPoint.apiKey, "session_id":keychainM.getSessionID()])
            let user: UserModel = try await service.makeHTTPRequest(url: urlRequest)
        
                isLoading = false
                self.user = user
            
        } catch  {
            loadError(error)
        }
    }

    @MainActor func LogIn() async throws {
        
            isLoading = true

        do {
            //Se solicita un nuevo token para el login (STEP 1)
            let urlRequestSTEP1 = try EndPoint.createURLRequest(url: .authStep1, method: .GET, query: ["api_key" : EndPoint.apiKey])
            let tokenRequest: AuthModel = try await service.makeHTTPRequest(url: urlRequestSTEP1)
            
            //Se muestra la web para que el user haga el login y autorize la app (STEP 2)
            let token = try await service.signInAsync(requestToken: tokenRequest.requestToken)
            
            //Se obtiene la sessionID (STEP 3) y se guarda en UserDefault (mala idea, hay que cambiar esto)
            let urlRequest = try EndPoint.createURLRequest(url: .authStep3, method: .POST, query: ["api_key": EndPoint.apiKey],parameters: ["request_token":token])
            let sessionID: AuthSessionModel = try await service.makeHTTPRequest(url: urlRequest)
            
            try keychainM.saveSessionID(sessionID.sessionID)
            
           // userSessionID = sessionID.sessionID
            await getUserInfo()
            isLoading = false
            
        }
        
        catch let error as OthersErrors where error == .userCanceledAuth {
            print("Se canceló el login")
            isLoading = false
        }
        catch{
            loadError(error)
        }
        
    }
    
    @MainActor func logOut() async {
       
        isLoading = true
        
   

        do {
            let sessionID = try keychainM.getSessionID()
            let urlRequest = try EndPoint.createURLRequest(url: .logOut,
                method: .DELETE,
                query: ["api_key" : EndPoint.apiKey], parameters: ["session_id":sessionID])
            
            let resp: logOut = try await service.makeHTTPRequest(url: urlRequest)
            print(resp)
            if resp.success{
            
                    //userSessionID = ""
                try keychainM.deleteSessionID()
                    self.user = nil
                    isLoading = false
                   
                
  
            }else{
                //MEJOR MANEJO PARA DESAUTORIZACON
                isLoading = false
            }
            
        } catch  {
            loadError(error)
        }
        
    }
    
    @MainActor private func loadError(_ error: Error){

         isLoading = false
         alertMessage = error.localizedDescription
         showAlert = true
     }

}

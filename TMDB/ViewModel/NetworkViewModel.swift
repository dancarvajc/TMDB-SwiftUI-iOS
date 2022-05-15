//
//  NetworkViewModel.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 02-05-22.
//

import Foundation

//MARK: Se encarga de entregar los estados del internet a las Views
final class NetworkViewModel: ObservableObject{
    @Published var noInternet: Bool = false
    @Published var noWifinoCelularData: Bool = false

    //Se suscribe y publican los estados de NetworkManager
    init(networkMg: NetworkManager) {
        
        networkMg.$noInternet
            .assign(to: &$noInternet)
        
        networkMg.$noWifinoCelularData
            .assign(to: &$noWifinoCelularData)

    }
    
}

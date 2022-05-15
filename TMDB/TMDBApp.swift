//
//  ChallengeAlkemyApp.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 22-04-22.
//

import SwiftUI
import NukeUI

@main
struct ChallengeAlkemyApp: App {

    @StateObject private var movieVM: MoviesViewModel
    @StateObject private var userVM: UserViewModel
    @StateObject private var networkViewModel: NetworkViewModel

    //Se crea 1 instancia de keychain y network manager y se inyecta a los viewModels (dependency injection)
    init() {
       let keychainManager = KeychainManager()
       let networkManager = NetworkManager()
        
        _movieVM = StateObject(wrappedValue: MoviesViewModel(service: networkManager, keychainM: keychainManager))
        _userVM = StateObject(wrappedValue: UserViewModel(service: networkManager, keychainM: keychainManager))
        _networkViewModel = StateObject(wrappedValue: NetworkViewModel(networkMg: networkManager))
        
        ImagePipeline.shared = ImagePipeline(configuration: .withDataCache) //Se ajusta para una caché en disco e ignorar la caché de las peticiones HTTP, con lo que respecta a las imágenes
    }

    var body: some Scene {
        WindowGroup {
//            ImageZoomView(url: "https://image.tmdb.org/t/p/w1280/aOxexquz0bKIxBkhAvn4Y9TIxpo.jpg")
                ContentView()
                    .environmentObject(movieVM)
                    .environmentObject(userVM)
                    .environmentObject(networkViewModel)
                    .environment(\.managedObjectContext, PersistenceController2.shared.container.viewContext)
        }
    }
}

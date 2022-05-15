//
//  ContentView.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 22-04-22.
//

import SwiftUI

enum Tab: String {
    case Home
    case Profile
    case search
}

//MARK: Pantalla principal, contiene la tabview y las 2 secciones principales: películas y perfil
struct ContentView: View {
    
    @EnvironmentObject private var movieVM: MoviesViewModel
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var networkVM: NetworkViewModel
    @AppStorage("selectedTab") private var selectedTab: Tab = .Home
    
    @AppStorage("firsTimeInApp") private var firsTimeInApp: Bool = true
    
    
    @State private var noInternet = false
    
    var body: some View {
        GeometryReader{ g in
            TabView(selection: $selectedTab){
                        MovieView()
                    .tabItem {
                        Image(systemName: "film")
                        Text("Películas")
                    }
                    .tag(Tab.Home)
                    .alert(isPresented: $movieVM.showAlert) {
                        Alert(title: Text("Información"),
                              message: Text(movieVM.alertMessage)
                        )
                    }
                SearchView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Buscar")
                    }
                    .tag(Tab.search)
                    .alert(isPresented: $movieVM.showAlert) {
                        Alert(title: Text("Información"), message: Text(movieVM.alertMessage))
                    }
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Perfil")
                    }
                    .tag(Tab.Profile)
                    .alert(isPresented: $userVM.showAlert) {
                        Alert(title: Text("Información"), message: Text(userVM.alertMessage))
                    }
               
            }
            .isPortrait(g.size.height > g.size.width)
            .onAppear {
                //try? userVM.keychainM.deleteSessionID()
                if firsTimeInApp {
                    Task{
                         await firstTask()
                         firsTimeInApp = false
                     }
                }else{
                    Task {
                        await getUser()
                    }

                }

            }
            .offset(y: noInternet ? -30 : 0)
            
            NoInternetBannerView(status: noInternet, geometryProxy: g)
            
        }
        .onReceive(networkVM.$noInternet){ int in
            withAnimation {
                noInternet = int
            }
        }
    }
}


//MARK: Extensión de funciones para esta vista
extension ContentView{
    
    //MARK: Primera función que se ejecuta al inicio de la app, recopila las películas e info del usuario logeado si lo está
    private func firstTask() async {
        if networkVM.noWifinoCelularData == false {
    
            print("Primera vez en la APP")
          
              //Se hacen las llamadas a las api en paralelo de las peliculas top y popular y la información de usuario si está logeado
            _ =  await withTaskGroup(of: Void.self, body: { taskgroup in
                taskgroup.addTask {
                    await movieVM.fetchMovies(of: .popularMovies)
                }
                taskgroup.addTask {
                    await movieVM.fetchMovies(of: .topRatedMovies)
                }
                taskgroup.addTask {
                    await getUser()
                }
            })
        }else{
            //Recursión para ejecutar la función al inicio de la app si o si
            try? await Task.sleep(nanoseconds: 1_000_000_000) //suspende 1 seg
            await firstTask()
        }
    }
    
    //MARK: Función para obtener al usuario y sus favoritas
    func getUser() async {
            let isUserLoggedIn = try?  userVM.keychainM.getSessionID() != ""
            //Se asegura que haya una session activa e internet
            guard isUserLoggedIn != nil, networkVM.noInternet == false else{return}
            
            // Se obtiene el usuario si está logeado junto a las pelis favoritas de éste
            if  userVM.user == nil && isUserLoggedIn!  {
                    await userVM.getUserInfo()
                    guard userVM.user != nil else {return}
                    await movieVM.fetchFavoritesMovies(accID: "\(userVM.user!.id)")
            }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserViewModel(service: NetworkManager(), keychainM: KeychainManager()))
            .environmentObject(MoviesViewModel(service: NetworkManager(), keychainM: KeychainManager()))
            .environmentObject(NetworkViewModel(networkMg: NetworkManager()))
        
    }
}

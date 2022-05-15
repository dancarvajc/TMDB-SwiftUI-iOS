//
//  ProfileView.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 22-04-22.
//

import SwiftUI


//MARK: Vista contenedora de perfil
struct ProfileView: View {
    
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var movieVM: MoviesViewModel
    @EnvironmentObject private var networkVM: NetworkViewModel
    
    @State var noUserLogged: Bool = true
    
    var body: some View {
        ZStack{
            
            switch noUserLogged{
                
            case true:
                if networkVM.noWifinoCelularData{
                    VStack{
                        Text("Activa los datos móviles o Wifi")
                            .multilineTextAlignment(.center)
                        ProgressView()
                            .padding()
                }
                } else if userVM.isLoading{
                    ProgressView("Cargando...")
                        .progressViewStyle(CustomProgressViewStyle())
                }else {
                    LoginView()
                }
                
            case false:
                if userVM.isLoading{
                    ProgressView("Cargando usuario...")
                        .progressViewStyle(CustomProgressViewStyle())
                    
                } else if userVM.user != nil {
                    UserView(user: userVM.user!)
                        .onAppear {
                            Task{
                                await movieVM.fetchFavoritesMovies(accID: "\(userVM.user!.id)")
                            }
                        }

                }else{
                    VStack{
                        Text("No se pudo cargar tu usuario")
                            .padding()
                        Button("Recargar"){
                            Task{
                                await userVM.getUserInfo()
                                guard userVM.user != nil else {return}
                                await movieVM.fetchFavoritesMovies(accID: "\(userVM.user!.id)")
                                
                            }
                        }.disabled(userVM.isLoading)
                    }
                }
            }
            
//            if userVM.isLoading{
//                ProgressView("Cargando...")
//                    .progressViewStyle(CustomProgressViewStyle())
//                    .zIndex(1)
//            }
//            //Si no se tiene una session (user no está logeado) se muestra el login, sino, el perfil.
//            if noUserLogged {
//                LoginView()
//
//            }else{
//                if userVM.user != nil {
//                    UserView(user: userVM.user!)
//                        .onAppear {
//                            Task{
//                                await movieVM.fetchFavoritesMovies(accID: "\(userVM.user!.id)")
//                            }
//                        }
//                }else if networkVM.noInternet {
//
//                    VStack{
//                        Text("No se pudo cargar tu usuario")
//                            .padding()
//                        Button("Recargar"){
//                            Task{
//                                await userVM.getUserInfo()
//                                guard userVM.user != nil else {return}
//                                await movieVM.fetchFavoritesMovies(accID: "\(userVM.user!.id)")
//
//                            }
//                        }.disabled(userVM.isLoading)
//                    }
//
//                }
////                else{
////                    VStack{
////                        Text("Al parecer hubo una desautorización desde la web de TMDB")
////                        Button("Vuelve a iniciar sesión"){
////                             try? userVM.keychainM.deleteSessionID()
////                               userVM.user = nil
////                        }
////
////                            .padding()
////                    }.animation(nil)
////
////
////                }
//            }

        }
        
        //Comprueba que haya alguna session en Keychain. Se hizo de esta forma para no forzar el try! en la función getSessionID
        .onAppear(perform: {
            let newValue = try? userVM.keychainM.getSessionID() == ""
            if newValue != nil{
                noUserLogged = newValue!
            }

        })
        .onChange(of: try? userVM.keychainM.getSessionID() == "", perform: { newValue in

            if newValue != nil{
                withAnimation {
                    noUserLogged = newValue!
                }
             
            }
        })
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(UserViewModel(service: NetworkManager(), keychainM: KeychainManager()))
    }
}

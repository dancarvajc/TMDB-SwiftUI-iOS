//
//  UserView.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 25-04-22.
//

import SwiftUI
import NukeUI

//MARK: Vista de usuario logeado
struct UserView: View {
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var movieVM: MoviesViewModel
    @EnvironmentObject private var networkVM: NetworkViewModel
    let user: UserModel
    
    var body: some View {
        
        GeometryReader { g in
            VStack{
                VStack{
                    //MARK: Foto de perfil del user
                    LazyImage(source: Constants.gravatarURL + user.avatar.gravatar.hash, resizingMode: .aspectFit)
                        .onCompletion(Constants.onCompletionLazyImage(networkVM: networkVM))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white, lineWidth: 4))
                        .shadow(radius: 5)
                        .frame(width: 100, height: 100)
                    //MARK: Bienvenida
                    Text("Bienvenido, \(user.username)")
                        .padding(.top,5)
                    //MARK: Botón para cerrar sesión
                    Button("Cerrar sesión"){
                        Task{
                            await userVM.logOut()
                        }
                    }.padding(5)
                    Divider()
                    Text("Películas favoritas")
                        .font(.title)
                        .bold()
                    
                }.frame(width: g.size.width, height: g.size.height*0.4)
                
                //MARK: Lista de pélículas favoritas
                if movieVM.favoritesMovies.count != 0 {
                    List(movieVM.favoritesMovies){ movie in
                        HStack{
                            Text(movie.title)
                        }.frame(maxWidth:.infinity, maxHeight:.infinity, alignment: .center)
                        
                    }.padding(.top,5)
                        .frame(width: g.size.width, height: g.size.height*0.6)
                        .listStyle(.plain)
                }else if movieVM.isLoading {
                    ProgressView()
                        .padding()
                }else{
                    //Si falla la carga por alguna razón, se muestra un botón para intentarlo de nuevo
                    if movieVM.isLoading {
                        ProgressView()
                            .padding()
                    }
                    Button("Recargar lista"){
                        Task{
                            await movieVM.fetchFavoritesMovies(accID: "\(userVM.user!.id)")
                        }
                        
                    }.padding()
                        .disabled(movieVM.isLoading)
                }
                
            }
        }.animation(.default)
        .padding()
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView(user: UserModel(avatar: .init(gravatar: .init(hash: "asdasdasdas")), id: 6595, iso639_1: "asdasdas", iso3166_1: "asdasd", name: "Danny", includeAdult: true, username: "Danny CC"))
            .environmentObject(UserViewModel(service: NetworkManager(), keychainM: KeychainManager()))
            .environmentObject(MoviesViewModel(service: NetworkManager(), keychainM: KeychainManager()))
            .environmentObject(NetworkViewModel(networkMg: NetworkManager()))
    }
}

//
//  HomeView.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 22-04-22.
//

import SwiftUI


//MARK: Vista contenedora de las películas (la más populares y más votadas)
struct MovieView: View {
    
    @EnvironmentObject private var movieVM: MoviesViewModel
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var networkVM: NetworkViewModel
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "voteAverage", ascending: false)],predicate: NSPredicate(format: "category_ == %@", MovieCategory.popular.rawValue) ) private var popularMovies: FetchedResults<MovieModelCD>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "voteAverage", ascending: false)],predicate: NSPredicate(format: "category_ == %@", MovieCategory.topRated.rawValue)) private var topRatedMovies: FetchedResults<MovieModelCD>
 
    
    @State private var noWifinoCelularData: Bool = false
    @State private var noInternet: Bool = false
    @State private var isMoviesEmpty: Bool = true
    
    var body: some View {
        
        NavigationView{
//            ZStack{
//                List(movies2){ movie in
//                    Text(movie.title ?? "Desconocido")
//                    Text("\(movie.runtime)")
//                }
//
//                if movieVM.isLoading{
//                    ProgressView("Cargando películas...")
//                        .progressViewStyle(CustomProgressViewStyle())
//                }
//            }         .alert(isPresented: $movieVM.showAlert) {
//                Alert(title: Text("Información"),
//                      message: Text(movieVM.alertMessage)
//                )
//
//            }

            
//            switch isMoviesEmpty{
//            case true:
//               if noWifinoCelularData{
//                    VStack{
//                        Text("Activa los datos móviles o Wifi para recopilar las películas")
//                            .multilineTextAlignment(.center)
//                        ProgressView()
//                            .padding()
//                }
//                } else if movieVM.isLoading{
//                    ProgressView("Cargando películas...")
//
//                }else {
//                    reloadMoviesView
//
//                }
//            case false:
           
                MoviesView(popularMovies: popularMovies, topRatedMovies: topRatedMovies)

                    .navigationTitle("The Movie DB")
//                .navigationBarTitleDisplayMode(.inline)
//                if movieVM.isLoading{
//                    ProgressView("Cargando...")
//                        .progressViewStyle(CustomProgressViewStyle())
//                }
            


            //}
            
//            if noWifinoCelularData{
//                VStack{
//                    Text("Activa los datos móviles o Wifi para recopilar las películas")
//                        .multilineTextAlignment(.center)
//                    ProgressView()
//                        .padding()
//            }
//            }else if noInternet{
//                        reloadMoviesView
//
//            }else if movieVM.isLoading{
//                ProgressView("Cargando películas...")
//
//            }
//            else if movieVM.movies.isEmpty == false{
//
//                MoviesView(popularMovies: movieVM.movies, topRatedMovies: movieVM.topRatedMovies)
//                    .navigationTitle("The Movie DB")
//                    .navigationBarTitleDisplayMode(.inline)
//            }else{
//                reloadMoviesView
//            }
            
        }.navigationViewStyle(.stack)
        
    
        .onReceive(networkVM.$noWifinoCelularData) { element in
            withAnimation {
                noWifinoCelularData = element
                
            }
            
        }
        .onReceive(networkVM.$noInternet) { element in
            withAnimation {
                noInternet = element
                
            }
            
        }
        .onReceive(movieVM.$movies) { element in
            withAnimation {
                isMoviesEmpty = element.isEmpty
                
            }
            
        }
    }
}

extension MovieView{
    
    private var reloadMoviesView:some View{
        VStack{
            if movieVM.isLoading{
                ProgressView().padding()
            }
            Text("No se pudo obtener las películas de Internet")
            Button("Volver a intentar"){
                Task {
                    _ =  await withTaskGroup(of: Void.self, body: { taskgroup in
                        taskgroup.addTask {
                            await movieVM.fetchMovies(of: .popularMovies)
                        }
                        taskgroup.addTask {
                            await movieVM.fetchMovies(of: .topRatedMovies)
                        }
                    })

                }
            }.padding()
                .disabled(movieVM.isLoading)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        MovieView()
            .environmentObject(MoviesViewModel(service: NetworkManager(), keychainM: KeychainManager()))
            .environmentObject(UserViewModel(service: NetworkManager(), keychainM: KeychainManager()))
    }
}

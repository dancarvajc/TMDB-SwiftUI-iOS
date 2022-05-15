//
//  SearchView.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 03-05-22.
//

import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject private var movieVM: MoviesViewModel
    @State private var isLoading: Bool = false
    @State private var searchText: String = ""
    @State private var enableDismissKeyboard:Bool = false
    @State private var searchedMovies: [FullMovieModel] = []
    var body: some View {
        NavigationView {
            
            List {
                SearchBarUIKit(text: $searchText, placeholder: "Película", search: {
                    Task{
                        await movieVM.fetchMovies(of:.searchMovie, search:searchText)
                    }
                })
                if movieVM.isLoading{
                    ProgressView("Buscando...")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                ForEach(searchedMovies){ movie in
                    
                    NavigationLink(movie.title, destination: DetailMovieView(movie: movie))
                    
                    
                }
            }
            .delayedAnimation()
            .listStyle(.insetGrouped)
            .navigationTitle("Buscar")
            
        }
                .gesture(
                    //Gesto para minimizar el teclado al tocar cualquier parte de la pantalla
                    TapGesture()
                        .onEnded({ _ in
                            guard enableDismissKeyboard else{return}
                            UIApplication.shared.endEditing()
                        }),
                    including: enableDismissKeyboard ? .gesture : .subviews
                )
        .onReceive(NotificationCenter.default.publisher(for: UIWindow.keyboardWillShowNotification), perform: { _ in
            enableDismissKeyboard = true
        })
        .onReceive(NotificationCenter.default.publisher(for: UIWindow.keyboardWillHideNotification), perform: { _ in
            enableDismissKeyboard = false
        })
        .onReceive(movieVM.$isLoading.dropFirst(3)) { isloading in
            isLoading = isloading
            
        }
        .onReceive(movieVM.$searchedMovies) { movies in
            searchedMovies = movies
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(MoviesViewModel(service: NetworkManager(), keychainM: KeychainManager()))
    }
}

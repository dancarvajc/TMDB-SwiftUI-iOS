//
//  DetailMovieView.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 22-04-22.
//

import SwiftUI
import NukeUI
import CoreData

//MARK: Es el sheet que se muestra cuando se presiona una película. Muestra los detalles de la misma.

//TODO: Mejorar opcionales!

struct DetailMovieView: View{
    @EnvironmentObject private var movieVM: MoviesViewModel
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var networkVM: NetworkViewModel
    @State private var isFavorite: Bool = false
    @State private var noInternet: Bool = false
    @State private var showZoomedImage: Bool = false
    let movie: Any
    
    var movie2:FullMovieModel? {
        movie as? FullMovieModel
    }
    var movie3: MovieModelCD?{
        movie as? MovieModelCD
    }
    
    let sizeScreen = (width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    
    var body: some View {
        
        VStack(spacing:0) {
            //MARK: Header (título y botón para cerrar)
            
            if movie3 != nil {
                HStack(alignment: .top){
                    Text((movie2?.title ?? movie3?.title) ?? "Desconocido" )
                        .font(.title)
                        .bold()
                        .padding(.leading,(sizeScreen.width)*0.15)
                        .frame(width: (sizeScreen.width)*0.85-10)
                    
                    // .padding(.leading, g.size.width*0.15)
                    SheetCloseButton()
                        .frame(width: (sizeScreen.width)*0.15-10)
                    
                }.padding(.horizontal, 10)
                    .padding(.top)
                    .padding(.bottom,5)
                
            }

            ScrollView(showsIndicators: false) {
                //MARK: Portada
                
                //ARREGLAR unwrapping
                LazyImage(source: Constants.ImageFetch.base_url+Constants.ImageFetch.size500+(movie2?.posterPath ?? movie3?.posterPath ?? "No tiene imagen"), resizingMode: .aspectFit)
                    .onCompletion(Constants.onCompletionLazyImage(networkVM: networkVM))
                    .frame(width: 250, height: 250)
                    .onTapGesture {
                        showZoomedImage = true
                    }
                
                //MARK: Botón añadir a fav
                HStack {
                    Image(systemName: isFavorite ? "star.fill": "star")
                        .foregroundColor(.yellow)
                    
                    Button(isFavorite ? "Sacar de favoritas":"Añadir a favoritas"){
                        Task{
                            // guard userVM.user != nil else{return}
                            isFavorite.toggle()
                            let result = await movieVM.setFavoriteMovie(accID: "\(userVM.user!.id)", idMovie: Int(movie2?.id ?? Int(movie3?.id ?? 0)), favorite: !isFavorite ? false : true)
                            
                            if !result {
                                isFavorite.toggle()
                            }
                            
                        }
                        
                    }
                }.disabled(userVM.user == nil)
                    .padding(5)
                Divider()
                //MARK: Información de la movie
                VStack(alignment: .leading) {
                    
                    Text("Género: ").bold()
                    + Text(( ( movie2?.genres.first?.name ?? movie3?.genres) ?? "Desconocido"))
                    Text("Duración: ").bold() +
                    
                    Text(Double(movie2?.runtime ?? Int(movie3?.runtime ?? 0) ?? 0).asString(style: .abbreviated) )
                    
                    Text("Estreno: ").bold() + Text(movie2?.releaseDate ?? movie3?.releaseDate ?? "Fecha desconocida")
                    
                    
//                    HStack{
//                        Text("País:").bold()
//
//                        ForEach(movie.productionCountries) { prod in
//                            Text(prod.iso3166_1.toEmojiFlag())
//                                .font(.body)
//                        }
//                    }
                    Text("Valoración: " ).bold() +
                    Text(String(format: "%g", movie2?.voteAverage ?? Double(movie3?.voteAverage ?? 0))+"/10 " + "(\(movie2?.voteCount ?? Int(movie3?.voteCount ?? 0) ?? 0) votos)")
                    
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical,5)
                
                Divider()
                
                //MARK: Actores, directores y productores
                CreditsView(directors: movie2?.directors ?? movie3?.directors ?? [], producers: movie2?.producers ?? movie3?.producers ?? [], cast: movie2?.credits.cast ?? movie3?.cast ?? [])
                
                Divider()
                
                //MARK: Resumen
                Text("Resumen")
                    .font(.title3)
                    .bold()
                    .padding(.vertical,5)
                //  TextView(text: movie.overview)
                
                Text(movie2?.overview ?? movie3?.overview != "" && movie2?.overview ?? movie3?.overview != nil ? (movie2?.overview ?? movie3?.overview)! : String("No disponible"))
                    .italic()
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 10)
                
            }
            .padding(.horizontal)
            .onReceive(movieVM.$favoritesMovies){ fM in
                print("CAPTURANDO FAVORITAS")
                isFavorite = (fM.first{ $0.id == movie2?.id ?? Int(movie3?.id ?? 0) } != nil)
                print(isFavorite)
            }
            .onReceive(networkVM.$noInternet){ int in
                print("RECIVIENDO \(int) EN ONRECEIVE")
                noInternet = int
            }
        }.navigationBarTitle(movie2?.title ?? "")
            .fullScreenCover(isPresented: $showZoomedImage) {
                ZoomedImage(url: Constants.ImageFetch.base_url+Constants.ImageFetch.size500+(movie2?.posterPath ?? movie3?.posterPath ?? "No tiene imagen"))
            }
    }
}



struct SheetCloseButton:View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View{
        
        Button("\(Image(systemName: "xmark.circle"))"){
            presentationMode.wrappedValue.dismiss()
        }.font(.system(size: 27))
        
    }
}

struct DetailMovieView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailMovieView(movie: FullMovieModel.example1)
                .environmentObject(UserViewModel(service: NetworkManager(), keychainM: KeychainManager()))
                .environmentObject(MoviesViewModel(service: NetworkManager(), keychainM: KeychainManager()))
            .environmentObject(NetworkViewModel(networkMg: NetworkManager()))
            .ignoresSafeArea()
        }
    }
}




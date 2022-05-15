//
//  MoviesView.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 28-04-22.
//

import SwiftUI


//MARK: Vista que contiene las 2 carriles horizontales para las 2 categorias de películas
struct MoviesView: View {
    @EnvironmentObject private var movieVM: MoviesViewModel
    let popularMovies: FetchedResults<MovieModelCD>
    let topRatedMovies:FetchedResults<MovieModelCD>
    var body: some View {
        
        GeometryReader { g in
            ScrollView {
                VStack(spacing:0) {
                    VStack(spacing:10) {
                        Text("Lo más popular")
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        MoviesCarrouselView(movies: popularMovies, alto: g.size.height)
                        
                        
                    }.padding()
                    
                    
                    VStack(spacing:10){
                        Text("Películas mejores valoradas")
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        MoviesCarrouselView(movies: topRatedMovies, alto: g.size.height)
                        
                    }.padding()
                }
                .pullToRefresh {
                    await movieVM.fetchMovies(of: .popularMovies)
                    await movieVM.fetchMovies(of: .topRatedMovies)
                }
            }
        }
        
        
    }
}

//struct MoviesView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            MoviesView(popularMovies: MoviesViewModel.previewMovies, topRatedMovies: MoviesViewModel.previewMovies)
//        }
//    }
//}

//
//  MoviesCarrouselView.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 28-04-22.
//

import SwiftUI

struct MoviesCarrouselView<Result: RandomAccessCollection>: View where Result.Element == MovieModelCD {
    let movies: Result
    
    @EnvironmentObject private var movieVM: MoviesViewModel
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var networkVM: NetworkViewModel
    let alto: CGFloat
    @State private var movieSelected: MovieModelCD?
    
    @Environment(\.isPortrait) var isPortrait: Bool
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal, showsIndicators: false){
                LazyHStack(spacing:0) {
                    ForEach(movies, id:\.id){ movie in
                        MovieCardView(with: movie)
                     
                            .frame(width: isPortrait ? proxy.size.width*0.5 : proxy.size.width*0.25)
                            .padding()
                            .onTapGesture {
                                movieSelected = movie
                            }
    //                        .onAppear {
    //                            print("Movie \(i) appear")
    //                        }
    //                        .onDisappear {
    //                            print("Movie \(i) disappear")
    //                        }
                    }
                }.animation(.default)
            }.frame(height: proxy.size.height)

            
//            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
//                guard let scene = UIApplication.shared.windows.first?.windowScene else { return }
//                self.isPortrait = scene.interfaceOrientation.isPortrait
//            }
            .sheet(item: $movieSelected){ m in
                DetailMovieView(movie: m)
                   
                    .alert(isPresented: $movieVM.showAlert) {
                        Alert(title: Text("Información"),
                              message: Text(movieVM.alertMessage)
                        )
                    }
                    .environmentObject(userVM)
                    .environmentObject(movieVM)
                    .environmentObject(networkVM)
        }
        }.frame(height:alto/2)
    }
}

//struct MoviesCarrouselView_Previews: PreviewProvider {
//    static var previews: some View {
//        MoviesCarrouselView(movies: MoviesViewModel.previewMovies)
//            .environmentObject(UserViewModel(service: NetworkManager(), keychainM: KeychainManager()))
//            .environmentObject(MoviesViewModel(service: NetworkManager(), keychainM: KeychainManager()))
//            .environmentObject(NetworkViewModel(networkMg: NetworkManager()))
//    }
//}

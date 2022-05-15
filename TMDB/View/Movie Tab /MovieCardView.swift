//
//  MovieCardView.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 28-04-22.
//

import SwiftUI
import NukeUI

struct MovieCardView: View {
    @EnvironmentObject private var networkVM: NetworkViewModel
    let movie: MovieModelCD
    
    init(with movie: MovieModelCD) {
        self.movie = movie
    }
    var body: some View {
        LazyImage(source: Constants.ImageFetch.base_url+Constants.ImageFetch.size500+movie.posterPath!, resizingMode: .aspectFill)
            .onCompletion(Constants.onCompletionLazyImage(networkVM: networkVM))
            //.frame(width: 130, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 3)
            .animation(nil)
        
        
    }
}

//struct MovieCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        MovieCardView(with: MovieModel.example2)
//    }
//}

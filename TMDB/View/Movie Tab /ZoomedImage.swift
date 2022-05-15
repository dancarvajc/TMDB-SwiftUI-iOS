//
//  ZoomedImage.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 15-05-22.
//

import SwiftUI
import NukeUI

struct ZoomedImage: View {
    let url: String
    var body: some View {
        ZStack{
            Color.black.ignoresSafeArea()
            LazyImage(source: url, resizingMode: .aspectFit)
                .zoomable()
            SheetCloseButton()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding()
        }
        
    }
}

struct ZoomedImage_Previews: PreviewProvider {
    static var previews: some View {
        ZoomedImage(url: "https://image.tmdb.org/t/p/w1280/aOxexquz0bKIxBkhAvn4Y9TIxpo.jpg")
    }
}

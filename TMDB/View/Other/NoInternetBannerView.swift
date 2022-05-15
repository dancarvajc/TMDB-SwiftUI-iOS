//
//  NoInternetBannerView.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 07-05-22.
//

import SwiftUI
//MARK: Barra inferior que informa que no hay Internet al estilo Youtube
struct NoInternetBannerView: View {
    let status:Bool
    let geometryProxy: GeometryProxy
    var body: some View{
        HStack{
            Image(systemName: "wifi.slash")
            Text("No hay Internet")
                .font(.footnote)
                .bold()
        }
        .frame(width:geometryProxy.size.width,height: geometryProxy.safeAreaInsets.bottom+30)
        .background(Color.orange)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .offset(y: status ? geometryProxy.safeAreaInsets.bottom : (geometryProxy.safeAreaInsets.bottom+30)*2)
        
    }
}

//
//  LoginView.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 25-04-22.
//

import SwiftUI


//MARK: Vista para el login
struct LoginView: View {
    @EnvironmentObject private var userVM: UserViewModel
    var body: some View {
        VStack{
            Text("Ingresa a tu cuenta de TMDB")
                .padding()
            Button("Iniciar sesión") {
                
                Task{
                    try await  userVM.LogIn()
                }
                
            }.disabled(userVM.isLoading)
            
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

//
//  CastCrewView.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 30-04-22.
//

import SwiftUI
import NukeUI


//MARK: Vista que muestra a los directores, productores y actores
struct CreditsView: View {
    let directors: [Cast2]
    let producers: [Cast2]
    let cast: [Cast2]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                LazyHStack(alignment:.top){
                    
                    //MARK: Directores
                    PeopleView(people: directors, type: .Director)
                    //MARK: Productores
                    PeopleView(people: producers, type: .Producer)
                }
                //MARK: Actores y actrices
                LazyHStack(alignment: .top){
                    PeopleView(people: cast, type: .Cast)
                    
                }
                
            }.padding(.vertical)
        }
    }
}

//MARK:View reutilizable de ayuda para la generación de carril de actores, directores, productores
struct PeopleView: View {
    
    let people: [Cast2]
    let type: TypePerson
    @EnvironmentObject private var networkVM: NetworkViewModel
    var body: some View{
        ForEach(people, id:\.identy){ person in
            VStack{
                LazyImage(source: Constants.ImageFetch.base_url+Constants.ImageFetch.size500+(person.profilePath ?? "https://www.gravatar.com/avatar/"), resizingMode: .aspectFill)
                    .onCompletion(Constants.onCompletionLazyImage(networkVM: networkVM))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.white, lineWidth: 4))
                    .shadow(radius: 5)
                    .frame(width: 100, height: 100)
                Text(person.name).italic()
                if type == .Cast{
                    Text(person.gender == 1 ? "Actriz" : "Actor").bold()
                    Text("(\(person.character ?? "Desconocido"))").bold().italic()
                }else if type == .Director{
                    Text(person.gender == 1 ? "Directora" : "Director").bold()
                }else{
                    Text(person.gender == 1 ? "Productora" : "Productor").bold()
                }
                
            }
            .frame(width: 150)
            
        }
    }
    
}

enum TypePerson: Equatable {
    case Director, Producer, Cast
}

//struct CastCrewView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreditsView()
//    }
//}

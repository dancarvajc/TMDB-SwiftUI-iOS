//
//  SearchBar(UIKit).swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 03-05-22.
//

import SwiftUI

//MARK: Se importa la barra de búsqueda desde UIKIT
struct SearchBarUIKit: UIViewRepresentable {
    
    @Binding var text: String
    let placeholder: String
    var search: ()-> Void
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.placeholder = placeholder
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

class Coordinator: NSObject, UISearchBarDelegate {
     var parent: SearchBarUIKit

     init(_ searchBar: SearchBarUIKit) {
         parent = searchBar
     }

     func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
         parent.text = searchText
     }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        parent.search()
        UIApplication.shared.endEditing()
    }
 }

struct SearchBarUIKit_Previews: PreviewProvider {
    static var previews: some View {
        
        SearchBarUIKit(text: .constant("sada"), placeholder: "Placeholder", search: {})
    }
}

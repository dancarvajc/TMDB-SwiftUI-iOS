//
//  Extensions.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 22-04-22.
//

import Foundation
import UIKit
import SwiftUI

//Obtenido de https://stackoverflow.com/a/30403199
extension String{
    func toEmojiFlag()->String{
        let base : UInt32 = 127397
        var s = ""
        for v in self.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }
}


//Obtenido de https://stackoverflow.com/a/49069866
extension Double {
  func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.unitsStyle = style
    return formatter.string(from: self*60) ?? "" //*60 porque se obtienen en minutos desde la API
  }
}

//Para bajar el teclado
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// Environment para tener el valor de si está en vertical u horizontal el dispositivo en todas las views decendientes

private struct isPortraitEnvironment: EnvironmentKey {
    static let defaultValue: Bool = true
}

extension EnvironmentValues {
    var isPortrait: Bool {
        get { self[isPortraitEnvironment.self] }
        set { self[isPortraitEnvironment.self] = newValue }
    }
}

extension View {
    func isPortrait(_ isPortrait: Bool) -> some View {
        environment(\.isPortrait, isPortrait)
    }
}

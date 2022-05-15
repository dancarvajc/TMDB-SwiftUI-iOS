//
//  ViewExtensions.swift
//  ChallengeAlkemy
//
//  Created by Daniel Carvajal on 22-04-22.
//

import Foundation
import SwiftUI

//UI de progressView
struct CustomProgressViewStyle: ProgressViewStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemBackground))
            )
            .shadow(radius: 3)
           // .frame(width: 50, height: 50)
    }
    
    
}



//Obtenido de https://stackoverflow.com/a/63892518/19040271
//MARK: Ayuda con bug de animación en las listas donde anima todo al aparecer la view.
struct DelayedAnimation: ViewModifier {
  var delay: Double
  var animation: Animation

  @State private var animating = false

  func delayAnimation() {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
      self.animating = true
    }
  }

  func body(content: Content) -> some View {
    content
      .animation(animating ? animation : nil)
      .onAppear(perform: delayAnimation)
  }
}

extension View {
  func delayedAnimation(delay: Double = 1.0, animation: Animation = .default) -> some View {
    self.modifier(DelayedAnimation(delay: delay, animation: animation))
  }
}

//MARK: Modifier that can be used like refreshable() on iOS 14
struct PullToRefreshModifier<CustomProgressView: View>: ViewModifier {
    
    @State private var initialPosition: CGFloat = -777
    @State private var task: Task<Void, Never>?
    @State private var isStartingDragging: Bool = false
    @State private var isAbleToRunningTask: Bool = false
    @State private var firstAppear:Bool =  true
    @State private var isRefreshing: Bool = false
    @State private var isThresholdPassed: Bool = false
    @State private var offset: CGFloat = 0
    let action: () async -> Void
    let customProgressView: CustomProgressView
    private let progressViewSize: CGFloat = 50  //You can change this
    
    init(action: @escaping () async -> Void,  @ViewBuilder content: () -> CustomProgressView) {
     self.customProgressView = content()
     self.action = action
 }
    
    func body(content: Content) -> some View {
        ZStack(alignment:.top) {
            
            //MARK: ProgressView Area
            if isRefreshing{
                Group{
                    if CustomProgressView.self != EmptyView.self {
                        customProgressView
                    }else{
                        ProgressView()
                            .progressViewStyle(CustomProgressViewStyle())
                    }
                }
                
                //Don't change below
                    .frame(width: progressViewSize, height: progressViewSize)
                    .offset(y:  isRefreshing ? 0 : -progressViewSize + offset)
                    .zIndex(1)
                    .onAppear {
                        task = Task {
                            await action()
                            withAnimation {
                                isAbleToRunningTask = false
                                isRefreshing = false
                                offset = 0
                            }
                        }
                    }
                    .onDisappear {
                        task?.cancel()
                        task = nil
                    }
            }else{
                //You can modify this
                Image(systemName: "arrow.down")
                    .resizable() //--> Keep this if you are using Image
                    .foregroundColor(isAbleToRunningTask ? .orange : Color(.label))
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemBackground)))
                    .shadow(radius: 3)
                
                //Don't change below
                    .frame(width: progressViewSize, height: progressViewSize)
                    .opacity(isStartingDragging ? 1 : 0)                       .rotationEffect(.degrees(isAbleToRunningTask ? 180: 0))
                    .offset(y:isStartingDragging ? (-progressViewSize + offset) : -progressViewSize)
                    .zIndex(1)
            }
            
            //MARK: Wrapped View
            //Where the magic happens. Get the position of the wrapped view and calculates the height scrolled, executes the async task and show a ProgressView
            content
                .offset(y: isRefreshing ? progressViewSize : offset > 0 ? offset : 0)
                .zIndex(0)
                .background(
                    GeometryReader{ proxy in
                        let localFrame = proxy.frame(in: .global)
                        
                        Color.clear
                            .onChange(of: localFrame.minY) { newValue in
                                if firstAppear {
                                    //Save the initial position of the wrapped view 0.5 sec after (to get the correct value)
                                    firstAppear = false
                                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5){
                                        initialPosition = proxy.frame(in: .global).minY
                                    }
                                }
                                
                                //Ensures initialPosition is saved
                                guard initialPosition != -777 else{return}
                                
                                //Space scrollView has been scrolled
                                offset = newValue - initialPosition
                                
                                withAnimation {
                                    isStartingDragging = newValue > initialPosition // When start to drag the View
                                }
                                
                                isThresholdPassed = newValue > initialPosition + progressViewSize //Passed the threshold (height of progressview)
                                
                                withAnimation {
                                    if isThresholdPassed {
                                        isAbleToRunningTask = true
                                    }
                                    
                                    //Show the progressView to execute the task when the dragging is under the threshold (when user ends dragging)
                                    if isThresholdPassed == false && isAbleToRunningTask{
                                        isRefreshing = true
                                    }
                                }
                            }
                    })
            
        }
        
    }
    
}

//MARK: Custom init used when user doesn't provees a custom loading view
extension PullToRefreshModifier where CustomProgressView == EmptyView{
    init(action: @escaping () async -> Void) {
        self.init(action: action,content: {EmptyView()})
    }
}

//MARK: extensions for usability
extension View{
  
    func pullToRefresh<Content:View>(action: @escaping () async -> Void, @ViewBuilder loadingView: () -> Content) -> some View  {

            modifier(PullToRefreshModifier(action: action,content: loadingView))

        
    }
    func pullToRefresh(action: @escaping () async -> Void) -> some View  {

            modifier(PullToRefreshModifier(action: action))

        
    }
}
//MARK: Modificador para hacer zoomeable las imágenes.
struct ZoomModifier: ViewModifier{
    
    @GestureState private var startLocation: CGPoint? = nil
    
    @State private var magnifyBy: CGFloat = 1.0
    @State private var finalMagnify:CGFloat = 1
    @State private var dobleTaped: Bool = false
    @State private var location: CGPoint = CGPoint(x: UIScreen.main.bounds.midX,
                                                   y: UIScreen.main.bounds.midY)
    @State private var startFingerPosition: CGPoint = .zero
    @State private var isZoomed: Bool = false
    
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 5.0
    
    func body(content: Content) -> some View {
        ZStack{
            if isZoomed {
                
                Text("Toca dos veces para hacer zoom")
                    .font(.callout)
                    .bold()
                    .foregroundColor(Color.blue)
                    .padding(15)
                    .background(Color(.systemBackground))
                    .zIndex(1)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                            withAnimation {
                                isZoomed = false
                            }
                        }
                    }
            }
            content
                .zIndex(0)
                .scaleEffect(magnifyBy, anchor: UnitPoint(x: startFingerPosition.x/(UIScreen.main.bounds.width), y: startFingerPosition.y/(UIScreen.main.bounds.height)))
                .position(location)
                .simultaneousGesture(dragGesture)
                .simultaneousGesture(magnification)
                .simultaneousGesture(doubleTapGesture)
        }
        
        
    }
    
    
}

//MARK: Gestos usados en el modificador
extension ZoomModifier{
    private var doubleTapGesture: some Gesture {
        
        TapGesture(count: 2)
            .onEnded { _ in
                withAnimation(.interpolatingSpring(stiffness: 170, damping: 15)) {
                    if magnifyBy != 1 {
                        location = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
                        magnifyBy = 1
                        dobleTaped = false
                    }else{
                        dobleTaped = true
                        isZoomed = false
                        magnifyBy = 2
                    }
                }
            }
    }
    
    private var dragGesture: some Gesture {
        
        //Se cambia el valor de minimumDistance de acuerdo a si está en zoom o no la imagen. Se asigna 0 para detectar la posición del tap.
        DragGesture(minimumDistance: magnifyBy == 1 ? 0 : 10)
            .onChanged { value in
                
                if magnifyBy == 1 {
                    //Para saber la posición del tap
                    startFingerPosition = value.startLocation
                }else{
                    var newLocation = startLocation ?? location
                    
                    
                    //Se asegura que no exceda el ancho y alto de las imagenes.
                    //Eje X
                    guard (UIScreen.main.bounds.width*0.2...UIScreen.main.bounds.width-UIScreen.main.bounds.width*0.2).contains(value.location.x) else{return}
                    //Eje Y
                    guard (UIScreen.main.bounds.height*0.2...UIScreen.main.bounds.height-UIScreen.main.bounds.height*0.2).contains(value.location.y) else{return}
                    newLocation.x += value.translation.width*1.5
                    newLocation.y += value.translation.height*1.5
                    
                    withAnimation {
                        self.location = newLocation
                    }
                }
                
            }.updating($startLocation) { (value, startLocation, transaction) in
                startLocation = startLocation ?? location
                
            }
            .onEnded { value in
                guard magnifyBy == 1 else{return}
                startFingerPosition = value.startLocation
            }
    }
    
    private var magnification: some Gesture {
        MagnificationGesture()
        
            .onChanged({ value in
          
                guard magnifyBy != 1 else {
                    withAnimation {isZoomed = true}
                    return
                }
                
                var realValue = value/finalMagnify
                realValue *= magnifyBy
                if realValue > maxScale{
                    magnifyBy = maxScale
                }else if realValue < minScale{
                    magnifyBy = minScale
                }else{
                    withAnimation {
                        magnifyBy = realValue
                        finalMagnify = value
                    }
                }
            })
            .onEnded { value in
                finalMagnify = 1.0
            }
    }
}

//MARK: extension for usability
extension View{
  
    func zoomable() -> some View{
        modifier(ZoomModifier())
    }
}



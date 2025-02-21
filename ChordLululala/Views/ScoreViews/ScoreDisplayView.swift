

import SwiftUI


struct ScoreDisplayView : View {
    let images = ["pencil", "square.and.arrow.up.circle.fill",  "figure.walk","sun.min","sunrise"]
    
    @StateObject var viewModel = MemoGestureViewModel()
    
    
    var body: some View {
        ZStack{
            Color.init(#colorLiteral(red: 0.6470588446, green: 0.6470588446, blue: 0.6470588446, alpha: 1)).edgesIgnoringSafeArea(.all)
            TabView {
                ForEach(images, id: \.self) { imageName in
                    Image(systemName: imageName)
                        .resizable()
                        .scaledToFit()
                        .background(Color.white)
                        .scaleEffect(viewModel.magnifyBy)
                        .gesture(viewModel.magnification)
                    
                }
            }
                .tabViewStyle(PageTabViewStyle())
            
        }
    }
}

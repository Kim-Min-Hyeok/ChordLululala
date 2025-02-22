import SwiftUI

struct ScoreDoubleDisplayView: View {
    let images = ["pencil", "square.and.arrow.up.circle.fill", "figure.walk", "sun.min", "sunrise"]
    
    @StateObject var viewModel = MemoGestureViewModel()
    
    var body: some View {
        ZStack {
            Color.gray.edgesIgnoringSafeArea(.all)
            
            TabView {
                ForEach(Array(stride(from: 0, to: images.count, by: 2)), id: \.self) { index in
                    HStack(spacing: 10){
                        Image(systemName: images[index])
                            .resizable()
                            .scaledToFit()
                        
                    
                        if index + 1 < images.count {
                            Image(systemName: images[index + 1])
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .background(Color.white)
                    .scaleEffect(viewModel.magnifyBy)
                    .gesture(viewModel.magnification)
                }
            }
            .tabViewStyle(PageTabViewStyle())
        }
    }
}

#Preview {
    ScoreDisplayView()
}


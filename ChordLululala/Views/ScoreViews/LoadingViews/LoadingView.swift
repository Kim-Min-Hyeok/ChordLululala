import SwiftUI

struct LoadingView: View {
    @State private var isLoading = true
    var loadingMessage : String = "3장의 악보에 대해 인식하고 있어요."
    var body: some View {
        VStack(spacing: 20) {
            
            Text(loadingMessage)
                .font(.system(size: 16))
                .bold()
                .foregroundColor(.black)
                .padding()
            
            CustomCircularProgressView()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isLoading = false
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


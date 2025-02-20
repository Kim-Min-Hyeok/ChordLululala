

import SwiftUI


struct ScoreView : View {
    @State private var isPencilActive: Bool = false
    
    var body: some View {
        
        VStack{
            ScoreHeaderView(isPencilActive: $isPencilActive)
            Divider()
            
            
            if isPencilActive {
                PencilToolsView(isPencilActive: $isPencilActive)
            }
            Spacer()
        }
        
    }
}


#Preview {
    ScoreView()
}




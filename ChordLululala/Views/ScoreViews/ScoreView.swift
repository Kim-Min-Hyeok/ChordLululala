

import SwiftUI


struct ScoreView : View {
    @State private var isPencilActive: Bool = false
    @State private var isMemoActive: Bool = false
    
    var body: some View {
        
        VStack{
            ScoreHeaderView(isPencilActive: $isPencilActive, isMemoActive: $isMemoActive)
            Divider()
            
            
            if isPencilActive {
                PencilToolsView(isPencilActive: $isPencilActive)
            }
            Spacer()
            
            if isMemoActive {
                MemoView(isMemoActive: $isMemoActive)
            }
            
            Spacer()
            
            
            
        }
        
    }
}


#Preview {
    ScoreView()
}




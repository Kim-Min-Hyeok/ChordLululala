

import SwiftUI



struct ScoreView : View {
    @EnvironmentObject var router: NavigationRouter
    @StateObject private var viewModel: ScoreViewModel
    
    init(content: ContentModel?) {
        _viewModel = StateObject(wrappedValue: ScoreViewModel(content: content))
    }
    
    var body: some View{
        
        VStack{
            ScoreHeaderView(viewModel: viewModel.headerViewModel)
            ScoreMainBodyView()
                .environmentObject(viewModel)
            
            Spacer()
        }
        .navigationBarHidden(true)
        
    }
    
}





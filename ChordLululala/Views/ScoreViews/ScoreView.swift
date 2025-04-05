

import SwiftUI



struct ScoreView : View {
    @EnvironmentObject var router: NavigationRouter
    @StateObject private var viewModel: ScoreViewModel
    
    init(content: ContentModel?) {
        _viewModel = StateObject(wrappedValue: ScoreViewModel(content: content))
    }
    
    var body: some View{
        
        VStack{
            ScoreHeaderView(title: viewModel.content?.name ?? "제목없음")
            ScoreMainBodyView()
                .environmentObject(viewModel)
            
            Spacer()
        }
        .navigationBarHidden(true)
        
    }
    
}





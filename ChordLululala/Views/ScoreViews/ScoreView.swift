

import SwiftUI



struct ScoreView : View {
    @EnvironmentObject var router: NavigationRouter
    @StateObject private var viewModel: ScoreViewModel
    
    init(content: ContentModel?) {
        _viewModel = StateObject(wrappedValue: ScoreViewModel(content: content))
    }
    
    var body: some View{
        
        VStack{
            /// 악보 헤더부분
            ScoreHeaderView(viewModel: viewModel.headerViewModel)
                
            /// 악보 바디 뷰
            ScoreMainBodyView(pdfViewModel: viewModel.pdfViewModel, currentPage: $viewModel.currentPage)
        
            
            Spacer()
        }
        .navigationBarHidden(true)
        
    }
    
}





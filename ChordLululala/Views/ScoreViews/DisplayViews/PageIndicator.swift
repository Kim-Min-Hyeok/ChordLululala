

import SwiftUI

struct PageIndicatorView: View {
    
    var currentPage : Int
    var totalPages : Int
    
    var body: some View {
        
        Text("\(currentPage) / \(totalPages)")
            .font(.caption)
            .padding(8)
            .background(Color.black.opacity(0.6))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.trailing, 16)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        
    }
}



#Preview {
    PageIndicatorView(currentPage: 1, totalPages: 4)
}

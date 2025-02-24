import SwiftUI

struct TransposeSupportView : View {
    
    @State var flatBefore : String = "0"
    @State var sharpBefore : String = "0"
    @State var sharpAfter : String = "0"
    @State var flatAfter : String = "0"
    
    
    var body: some View {
        VStack {
            Text("악보 인식 결과")
                .padding()
                .bold()
            
            Text("조표")
                .padding()
                .bold()
            
            HStack{
                    VStack{
                        Text("b :")
                            .font(.system(size: 15))
                            .fontWeight(.bold)
                            .padding()
                        
                        Text("# :")
                            .font(.system(size: 15))
                            .fontWeight(.bold)
                    }
                    
                    
                    VStack {
                        KeyNumberTextField(text: $flatBefore)
                        KeyNumberTextField(text: $sharpBefore)
                    }
                    
                    Image(systemName: "arrow.right")
                        .font(.title2)
                    
                    
                    VStack {
                        KeyNumberTextField(text: $flatAfter)
                        KeyNumberTextField(text: $sharpAfter)
                    }
                
            } // h
            
            HStack(spacing: 65){
                Text("현재 키 :")
                    .font(.headline)
                
                Text("바꾼 키 :")
                    .font(.headline)
            }
            
          
            
        }
    }
}


#Preview {
    TransposeSupportView()
}


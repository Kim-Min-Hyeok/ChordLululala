//import SwiftUI
//import Combine
//
//class PageControlViewModel: ObservableObject {
//    @Published var currentPage: Int = 1
//    @Published var images: [String]
//    @Published var layout: ScoreLayout {
//           didSet {
//               if layout == .double {
//                   currentPage = (currentPage + 1) / 2
//               } else {
//                   currentPage = (currentPage * 2) - 1
//               }
//           }
//       }
//    
//    init(images: [String] = [], layout: ScoreLayout = .single) {
//        self.images = images
//        self.layout = layout
//    }
//    
//    // 전체 페이지 계산
//    var totalPages: Int {
//        switch layout {
//        case .single:
//            return images.count
//        case .double:
//            return (images.count+1)/2 
//        }
//    }
//    
//    // 현재 페이지 계산
//    var displayPage: Int {
//          switch layout {
//          case .single:
//              return currentPage
//          case .double:
//              return (currentPage / 2) + 1
//          }
//      }
//    
//}

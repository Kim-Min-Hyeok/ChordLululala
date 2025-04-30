import Combine

final class ScoreHeaderViewModel : ObservableObject{
    @Published var title: String
    
    // 10글자까지만 보여주고 넘으면 ... 붙여줌
    var truncatedTitle: String {
        let limit = 10
        return title.count > limit
        ? "\(title.prefix(limit))…"
        : title
    }
    
    init(title: String) {
        self.title = title
    }
}

import SwiftUI
import PencilKit

enum DrawingTool {
    case pencil
    case marker
    case eraser
    case lasso
}

class PencilToolsViewModel: ObservableObject {
    @Published var canvasViews: [PKCanvasView] = []
    @Published var isPencilActive = false
    @Published var currentPageIndex: Int = 0
    @Published var selectedTool: DrawingTool? = nil

    init(pageCount : Int){
        for _ in 0..<pageCount {
            canvasViews.append(PKCanvasView())
        }
    }
    
    func selectTool(_ toolType: DrawingTool){
        isPencilActive = true
        selectedTool  = toolType
        for canvasView in canvasViews {
            canvasView.drawingPolicy = .anyInput
            
            switch toolType {
            case .pencil:
                canvasView.tool = PKInkingTool(.pencil, color: .black, width: 1)
            case .marker:
                canvasView.tool = PKInkingTool(.marker, color: .yellow.withAlphaComponent(0.3), width: 30)
            case .eraser:
                canvasView.tool = PKEraserTool(.vector)
            case .lasso:
                canvasView.tool = PKLassoTool()
                
            }
        }
        
    }
    
    func undo(){
        guard currentPageIndex < canvasViews.count else { return }
        canvasViews[currentPageIndex].undoManager?.undo()
        
        
    }
    
    func redo(){
        guard currentPageIndex < canvasViews.count else { return }
        canvasViews[currentPageIndex].undoManager?.redo()
    }
    
    func closeToolbar(){
        selectedTool = nil
        isPencilActive = false
        for canvasView in canvasViews {
            canvasView.drawingPolicy = .pencilOnly
        }
    }
    
    
    // 페이지 변경 시 호출할 함수 추가
    func updateCurrentPage(_ index: Int) {
        guard index >= 0 && index < canvasViews.count else { return }
        currentPageIndex = index
    }
}

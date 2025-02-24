import SwiftUI
import PencilKit

enum DrawingTool {
    case pencil
    case marker
    case eraser
    case lasso
}

class PencilToolsViewModel: ObservableObject {
    @Published var canvasView = PKCanvasView()
    @Published var isPencilActive = false
    
    func selectTool(_ toolType: DrawingTool){
        switch toolType {
        case .pencil:
            canvasView.tool = PKInkingTool(.pencil, color: .black, width: 1)
        case .marker:
            canvasView.tool = PKInkingTool(.marker, color: .yellow.withAlphaComponent(0.3), width: 10)
        case .eraser:
            canvasView.tool = PKEraserTool(.vector)
        case .lasso:
            canvasView.tool = PKLassoTool()
            
        }
    }
    
    func undo(){
        canvasView.undoManager?.undo()
    }
    
    func redo(){
        canvasView.undoManager?.redo()
    }
    
    func closeToolbar(){
        isPencilActive.toggle()
    }
}

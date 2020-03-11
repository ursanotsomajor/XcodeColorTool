import SwiftUI

struct FileListView: View
{
    var onReplaceColorsPressed: ((ColorReplacementOperation) -> Void)?
    
    @ObservedObject var operation: ColorReplacementOperation
    
    var body: some View
    {
        HStack {
            
            list()
            
            controls()
                .padding(.bottom, 16)
                .padding(.trailing, 8)
        }
    }
    
    private func list() -> AnyView
    {
        return AnyView(List(operation.files) { item -> FileListItemView in
            var view = FileListItemView(model: item, checked: self.operation.selectedFileIDs.contains(item.id))
            
            view.onCheckStatusUpdated = { model, checked in
                if self.operation.selectedFileIDs.contains(model.id) {
                    self.operation.selectedFileIDs.remove(model.id)
                }
                else {
                    self.operation.selectedFileIDs.insert(model.id)
                }
            }
            
            return view
        })
    }
    
    private func controls() -> AnyView
    {
        var view = FileListControls(operation: operation)
        
        view.onReplaceColorsPressed = {
            self.onReplaceColorsPressed?(self.operation)
        }
        
        return AnyView(view)
    }
}

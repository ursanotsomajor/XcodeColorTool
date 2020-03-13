import SwiftUI

struct FileListView: View
{
    @ObservedObject var manager: XMLManager
    
    @State private var dropEntered = false
    
    var body: some View
    {
        content()
    }
    
    private func content() -> AnyView
    {
        return AnyView(
            
            HStack {
                list()
                
                if dropEntered
                {
                    DragAndDropView(text: "Drag a folder containing\na color palette", dropActive: true)
                }
                else
                {
                    controls()
                        .padding(.bottom, 16)
                        .padding(.trailing, 8)
                }
            }
            .onDrop(of: [(kUTTypeFileURL as String)], delegate: self)
        )
    }
    
    private func list() -> AnyView
    {
        guard case .presenting(let operation) = manager.state else { return AnyView(EmptyView()) }
        
        return AnyView(List(operation.files) { item -> FileListItemView in
            var view = FileListItemView(model: item, checked: operation.selectedFileIDs.contains(item.id))

            view.onCheckStatusUpdated = { model, checked in
                if operation.selectedFileIDs.contains(model.id)
                {
                    operation.selectedFileIDs.remove(model.id)
                }
                else {
                    operation.selectedFileIDs.insert(model.id)
                }
            }
            
            return view
        })
    }
    
    private func controls() -> AnyView
    {
        guard case .presenting(let operation) = manager.state else { return AnyView(EmptyView()) }
        
        var view = FileListControls(operation: operation)

        view.onReplaceColorsPressed = {
            self.manager.replaceColors(operation: operation)
        }
        
        return AnyView(view)
    }
}

extension FileListView: DropDelegate
{
    func performDrop(info: DropInfo) -> Bool
    {
        return manager.onDrop(info: info, type: .palette)
    }
    
    func dropEntered(info: DropInfo)
    {
        dropEntered = true
    }
    
    func dropExited(info: DropInfo)
    {
        dropEntered = false
    }
}

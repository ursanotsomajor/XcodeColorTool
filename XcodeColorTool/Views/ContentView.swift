import SwiftUI

struct ContentView: View
{
    @ObservedObject private var manager = XMLManager()
    
    @State private var dropActive = false
    
    
    var body: some View
    {
        contentView()
            .onDrop(of: [(kUTTypeFileURL as String)], delegate: self)
    }
    
    private func contentView() -> AnyView
    {        
        if dropActive {
            return AnyView(DragAndDropView(state: manager.state, dropActive: dropActive))
        }
        
        switch manager.state
        {
        case .waiting, .loading:
            return AnyView(DragAndDropView(state: manager.state, dropActive: dropActive))

        case .presenting(let operation):
            var view = FileListView(operation: operation)
            
            view.onReplaceColorsPressed = { operation in
                self.manager.replaceColors(operation: operation)
            }
            
            return AnyView(view)
        }
    }
}

extension ContentView: DropDelegate
{
    func performDrop(info: DropInfo) -> Bool
    {
        return manager.onDrop(info: info)
    }
    
    func dropEntered(info: DropInfo)
    {
        dropActive = true
    }
    
    func dropExited(info: DropInfo)
    {
        dropActive = false
    }
}

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ContentView()
    }
}

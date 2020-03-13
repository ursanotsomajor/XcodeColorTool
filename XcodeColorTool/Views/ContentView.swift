import SwiftUI

struct ContentView: View
{
    @ObservedObject private var manager = XMLManager()
    
    @State private var dropActive = false
    
    
    var body: some View
    {
        contentView()
    }
    
    private func contentView() -> AnyView
    {
        let defaultText = "Drag a folder with XIBs and Storyboards"

        switch manager.state
        {
        case .waiting:
            return AnyView(
                DragAndDropView(text: defaultText, dropActive: dropActive)
                    .onDrop(of: [(kUTTypeFileURL as String)], delegate: self)
            )

        case .presenting:
            return AnyView(FileListView(manager: manager))
            
        case .loading(let foundXibs, let foundStoryboards):
            let text = "Found xibs: \(foundXibs), storyboards: \(foundStoryboards)"
            return AnyView(DragAndDropView(text: text, dropActive: dropActive))
        }
    }
}

extension ContentView: DropDelegate
{
    func performDrop(info: DropInfo) -> Bool
    {
        return manager.onDrop(info: info, type: .interface)
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

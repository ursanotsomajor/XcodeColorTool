import SwiftUI

struct DragAndDropView: View
{
    let state: XMLManagerState

    let dropActive: Bool
    
    var body: some View
    {
        contentView()
            .font(.headline)
            .foregroundColor(dropActive ? .green : .accentColor)
            .padding(24)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [8]))
                    .foregroundColor(dropActive ? .green : .accentColor))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func contentView() -> AnyView
    {
        switch state
        {
        case .waiting, .presenting:
            return AnyView(Text("Drag a folder with XIBs and Storyboards"))
        
        case .loading(let foundXibs, let foundStoryboards):
            return AnyView(Text("Found xibs: \(foundXibs), storyboards: \(foundStoryboards)"))
        }
    }
}



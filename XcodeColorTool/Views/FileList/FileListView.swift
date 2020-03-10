import SwiftUI

struct FileListView: View
{
    var onReplaceColorsPressed: ((_ files: [FileModel], _ replacements: [ColorReplacementModel]) -> Void)?
    
    @State var list: [FileModel]
    
    var body: some View
    {
        HStack {
            
            List(list) { item in
                FileListItemView(model: item)
            }
            
            controls()
        }
    }
    
    private func controls() -> AnyView
    {
        var view = FileListControls(list: list)
        view.onReplaceColorsPressed = onReplaceColorsPressed
        return AnyView(view)
    }
}

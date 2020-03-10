import SwiftUI

struct FileListControls: View
{
    var onReplaceColorsPressed: ((_ files: [FileModel], _ replacements: [ColorReplacementModel]) -> Void)?
    
    @State var list: [FileModel]
    
    @State private var addingColor = false
    
    @State private var colorPairs = [ColorReplacementModel]()
    @State private var selectedPair: ColorReplacementModel?
    
    var body: some View
    {
        VStack(spacing: 16) {
            
            if addingColor
            {
                colorInputView()
            }
            else {
                colorReplaceList()
                controlsView()
            }
        }
        .padding(32)
    }
    
    private func colorInputView() -> AnyView
    {
        var view = ColorInputView()
        
        view.onCancelPressed = {
            self.addingColor = false
        }
        
        view.onColorAdded = { pair in
            self.colorPairs.append(pair)
            self.addingColor = false
        }
        
        return AnyView(view)
    }
    
    private func colorReplaceList() -> AnyView
    {
        return AnyView(
            
            VStack {

                List(colorPairs) { pair in
                    FileListColorItemView(colorPair: pair, selected: pair == self.selectedPair)
                        .onTapGesture { self.selectedPair = pair }
                }
                
                HStack {
                    
                    Button(action: {
                        self.colorPairs.removeAll(where: { $0.id == self.selectedPair?.id })
                    }) {
                        Text("-")
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.addingColor = true
                    }) {
                        Text("+")
                    }
                }
            }
        )
    }
    
    private func controlsView() -> AnyView
    {
        return AnyView(
            VStack {
                Text("Selected \(list.filter({ !$0.checked }).count) files out of \(list.count)")
                
                Button(action: {
                    self.onReplaceColorsPressed?(self.list.filter({ $0.checked }), self.colorPairs)
                }, label: {
                    Text("Replace colors")
                        .foregroundColor(Color.black)
                        .font(.subheadline)
                })
            }
        )
    }
}

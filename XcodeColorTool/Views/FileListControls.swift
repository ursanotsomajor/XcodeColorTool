import SwiftUI

struct FileListControls: View
{
    var onReplaceColorsPressed: CompletionBlock?
    
    @ObservedObject var operation: ColorReplacementOperation
    
    @State private var selectedColorReplacement: ColorReplacementModel?
    @State private var addingColor = false
    
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
    }
    
    private func colorInputView() -> AnyView
    {
        var view = ColorInputView()
        
        view.onCancelPressed = {
            self.addingColor = false
        }
        
        view.onColorAdded = { pair in
            self.operation.replacements.append(pair)
            self.addingColor = false
        }
        
        return AnyView(view)
    }
    
    private func colorReplaceList() -> AnyView
    {
        return AnyView(
            
            VStack {
                
                List(operation.replacements) { replacement in
                    FileListColorItemView(replacement: replacement, selected: replacement == self.selectedColorReplacement)
                        .onTapGesture {
                            if self.selectedColorReplacement == replacement { self.selectedColorReplacement = nil }
                            else { self.selectedColorReplacement = replacement }
                    }
                }
                
                HStack {
                    
                    Button(action: {
                        self.operation.replacements.removeAll(where: { $0.id == self.selectedColorReplacement?.id })
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
            VStack(spacing: 12) {
                Text("Selected: \(operation.selectedFiles.count) / \(operation.files.count)")

                HStack(spacing: 12) {
                    TextField("Color delta", text: $operation.colorDelta)

                    Button(action: {
                        self.onReplaceColorsPressed?()
                    }) {
                        Text("Replace colors")
                    }
                }
            }
        )
    }
}

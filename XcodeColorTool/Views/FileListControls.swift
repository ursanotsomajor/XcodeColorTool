import SwiftUI

struct FileListControls: View
{
    var onReplaceColorsPressed: CompletionBlock?
    
    @ObservedObject var operation: ColorReplacementOperation
    
    @State private var selectedColorReplacement: ColorReplacementModel?
    @State private var addingColor = false
    @State private var colorDeltaString = ""
    
    
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
        
        view.onColorAdded = { replacement in
            self.operation.colorReplacements.append(replacement)
            self.addingColor = false
        }
        
        return AnyView(view)
    }
    
    private func colorReplaceList() -> AnyView
    {
        return AnyView(
            
            VStack {
                
                List(operation.colorReplacements) { replacement in
                    FileListColorItemView(replacement: replacement, selected: replacement.id == self.selectedColorReplacement?.id)
                        .onTapGesture {
                            if self.selectedColorReplacement?.id == replacement.id { self.selectedColorReplacement = nil }
                            else { self.selectedColorReplacement = replacement }
                    }
                }
                
                HStack {
                    
                    Button(action: {
                        self.operation.colorReplacements.removeAll(where: { $0.id == self.selectedColorReplacement?.id })
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
                    TextField("Color delta", text: $colorDeltaString)

                    Spacer()
                    
                    Button(action: {
                        if !self.colorDeltaString.isEmpty, let delta = Double(self.colorDeltaString) {
                            self.operation.colorDelta = delta
                        }
                        
                        self.onReplaceColorsPressed?()
                    }) {
                        Text("Replace colors")
                    }
                }
            }
        )
    }
}

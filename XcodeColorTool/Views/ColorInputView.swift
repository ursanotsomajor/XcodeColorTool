import SwiftUI

struct ColorInputView: View
{
    var onCancelPressed: CompletionBlock?
    var onColorAdded: ((_ colorPair: ColorReplacementModel) -> Void)?
    
    @State var color: String = ""
    @State var name: String = ""

    var body: some View
    {
        VStack(spacing: 12) {
            
            TextField("Custom color hash", text: $color)
                
            TextField("Color name from palette", text: $name)
            
            HStack(spacing: 12) {
                Button(action: {
                    self.onCancelPressed?()
                }) {
                    Text("Cancel")
                }
                
                Button(action: {
                    self.saveColor()
                }) {
                    Text("Done")
                }
            }
        }
    }
    
    private func saveColor()
    {
        guard let color = CustomColor(hex: color) else { return }
        
        self.onColorAdded?(ColorReplacementModel(customColor: color, name: name))
    }
}

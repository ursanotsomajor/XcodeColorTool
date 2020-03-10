import SwiftUI

struct ColorInputView: View
{
    var onCancelPressed: CompletionBlock?
    var onColorAdded: ((_ colorPair: ColorReplacementModel) -> Void)?
    
    @State var color: String = ""
    @State var name: String = ""
    
    private var colorModel: ColorReplacementModel {
        return ColorReplacementModel(color: Color(hex: "color"), name: name)
    }
    
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
                    self.onColorAdded?(self.colorModel)
                }) {
                    Text("Done")
                }
            }
        }
    }
}

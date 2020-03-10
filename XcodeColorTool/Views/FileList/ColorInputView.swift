import SwiftUI

struct ColorInputView: View
{
    var onCancelPressed: CompletionBlock?
    var onColorAdded: ((_ colorPair: ColorReplacementModel) -> Void)?
    
    @State var fromColor: String = ""
    @State var toColor: String = ""
    
    var body: some View
    {
        VStack(spacing: 12) {
            
            TextField("From color", text: $fromColor)
            
            TextField("To color", text: $toColor)
            
            HStack(spacing: 12) {
                Button(action: {
                    self.onCancelPressed?()
                }) {
                    Text("Cancel")
                }
                
                Button(action: {
                    let pair = ColorReplacementModel(fromColor: CustomColor(color: Color(hex: self.fromColor)),
                                               toColor: CustomColor(color: Color(hex: self.toColor)))
                    self.onColorAdded?(pair)
                }) {
                    Text("Done")
                }
            }
        }
    }
}

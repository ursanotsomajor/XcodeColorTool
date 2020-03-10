import SwiftUI

struct RadioButton: View
{
    let onToggle: ((_ on: Bool) -> Void)
    
    @State var accentColor: Color = .gray
    
    @Binding var checked: Bool
    
    var body: some View
    {
        Group {
            if checked
            {
                ZStack {
                    Circle()
                        .fill(accentColor)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                }
            }
            else
            {
                Circle()
                    .fill(Color.white)
                    .overlay(Circle().stroke(accentColor, lineWidth: 1))
            }
        }
        .onTapGesture {
            withAnimation {
                self.checked.toggle()
            }
            self.onToggle(self.checked)
        }
    }
}

import SwiftUI

struct FileListColorItemView: View
{
    let replacement: ColorReplacementModel
    let selected: Bool
    
    var body: some View
    {
        HStack(alignment: .center, spacing: 6) {
            
            Text(replacement.customColor.hex)
            
            Rectangle()
                .foregroundColor(replacement.customColor.color)
                .frame(width: 16, height: nil, alignment: .center)
                .border(Color.black, width: 1)
            
            Text(" —> ")
            
            Text(replacement.name)
            
            Spacer()
        }
        .background(selected ? Color.black.opacity(0.1) : Color.clear)
    }
}

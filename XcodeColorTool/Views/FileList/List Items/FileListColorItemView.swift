import SwiftUI

struct FileListColorItemView: View
{
    let colorPair: ColorReplacementModel
    let selected: Bool
    
    var body: some View
    {
        HStack(alignment: .center, spacing: 6) {
            Text(colorPair.fromColor.textRepresentation)
            
            Rectangle()
                .foregroundColor(colorPair.fromColor.color)
                .frame(width: 16, height: nil, alignment: .center)
            
            Text(" —> ")
            
            Text(colorPair.toColor.textRepresentation)
            
            Rectangle()
                .foregroundColor(colorPair.toColor.color)
                .frame(width: 16, height: nil, alignment: .center)
            
            Spacer()
        }
        .background(selected ? Color.black.opacity(0.1) : Color.clear)
    }
}

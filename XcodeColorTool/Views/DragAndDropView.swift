import SwiftUI

struct DragAndDropView: View
{
    let text: String
    let dropActive: Bool
    
    var body: some View
    {
        Text(text)
            .font(.headline)
            .foregroundColor(dropActive ? .green : .accentColor)
            .padding(24)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(style: StrokeStyle(lineWidth: 3, dash: [8]))
                    .foregroundColor(dropActive ? .green : .accentColor))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}



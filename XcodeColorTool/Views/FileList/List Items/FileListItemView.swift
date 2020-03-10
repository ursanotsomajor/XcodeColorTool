import SwiftUI

struct FileListItemView: View
{
    let model: FileModel
    
    var body: some View
    {
        HStack(spacing: 10) {
            
            Circle()
                .fill(model.checked ? Color.green : Color.red)
                .frame(width: 20, height: 20, alignment: .center)
                .onTapGesture { self.model.checked.toggle() }
            
            Text(model.name)
                .lineLimit(nil)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding(.top, 6)
        .padding(.bottom, 6)
    }
}

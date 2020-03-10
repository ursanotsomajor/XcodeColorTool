import SwiftUI

struct FileListItemView: View
{
    var onCheckStatusUpdated: ((_ model: FileModel, _ checked: Bool) -> Void)?
    
    let model: FileModel
    
    @State var checked: Bool
    
    var body: some View
    {
        HStack(spacing: 10) {
            
            RadioButton(onToggle: { toggled in
                self.onCheckStatusUpdated?(self.model, toggled)
            }, checked: $checked).frame(width: 20, height: 20, alignment: .center)
            
            Text(model.name)
                .lineLimit(nil)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding(.top, 6)
        .padding(.bottom, 6)
    }
}

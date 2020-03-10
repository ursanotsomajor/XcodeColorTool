import SwiftUI

class ColorReplacementOperation: ObservableObject
{
    @Published var files: [FileModel]
    @Published var selectedFiles: Set<UUID>
    
    @Published var replacements: [ColorReplacementModel]
    
    @Published var colorDelta: String
    
    init(files: [FileModel])
    {
        self.files = files
        
        self.selectedFiles = Set(files.map({ $0.id }))
        self.replacements = []
        self.colorDelta = ""
    }
}

import SwiftUI

class ColorReplacementOperation: ObservableObject
{
    @Published var files: [FileModel]
    @Published var selectedFileIDs: Set<UUID>
    
    @Published var replacements: [ColorReplacementModel]
    
    @Published var colorDelta: String
    
    var selectedFiles: [FileModel] {
        return files.filter({ selectedFileIDs.contains($0.id) })
    }
    
    init(files: [FileModel])
    {
        self.files = files
        
        self.selectedFileIDs = Set(files.map({ $0.id }))
        self.replacements = []
        self.colorDelta = ""
    }
}

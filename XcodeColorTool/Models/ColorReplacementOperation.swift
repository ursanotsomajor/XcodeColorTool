import SwiftUI

class ColorReplacementOperation: ObservableObject
{
    @Published var files: [FileModel]
    @Published var selectedFileIDs: Set<UUID>
    
    @Published var colorReplacements: [ColorReplacementModel]
    
    @Published var colorDelta: Double
    
    var selectedFiles: [FileModel] {
        return files.filter({ selectedFileIDs.contains($0.id) })
    }
    
    
    init(files: [FileModel])
    {
        self.files = files
        
        self.selectedFileIDs = Set(files.map({ $0.id }))
        self.colorReplacements = [ColorReplacementModel(customColor: CustomColor(hex: "FF7E7E")!, name: "PalePink"),
                                  ColorReplacementModel(customColor: CustomColor(hex: "484848")!, name: "Dark")]
        self.colorDelta = 0.1
    }
}

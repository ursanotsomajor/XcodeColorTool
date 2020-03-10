import SwiftUI

class FileModel: Identifiable, ObservableObject
{
    var id = UUID()
    
    let url: URL
    let name: String
    let isStoryboard: Bool
    
    @Published var checked: Bool = true
    
    init(url: URL, name: String, isStoryboard: Bool)
    {
        self.url = url
        self.name = name
        self.isStoryboard = isStoryboard
    }
}

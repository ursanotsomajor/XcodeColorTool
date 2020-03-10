import SwiftUI

struct FileModel: Identifiable
{
    var id = UUID()
    
    let url: URL
    let name: String
    let isStoryboard: Bool

    init(url: URL, name: String, isStoryboard: Bool)
    {
        self.url = url
        self.name = name
        self.isStoryboard = isStoryboard
    }
}

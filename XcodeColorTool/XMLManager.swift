import SwiftUI

enum XMLManagerState
{
    case waiting, loading(foundXIBs: Int, foundStoryboards: Int), presenting(operation: ColorReplacementOperation)
}

class XMLManager: NSObject, ObservableObject
{
    @Published var state = XMLManagerState.waiting
    
    func load(url: URL)
    {
        print("Reading files at: \(url.path)\n")
        
        DispatchQueue.main.async {
            self.state = .loading(foundXIBs: 0, foundStoryboards: 0)
        }
        
        listFiles(url: url)
    }
    
    func onDrop(info: DropInfo) -> Bool
    {
        let id = kUTTypeFileURL as String
        
        guard let itemProvider = info.itemProviders(for: [id]).first else { return false }

        itemProvider.loadItem(forTypeIdentifier: id, options: nil) { item, error in
            guard let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
            self.load(url: url)
        }
        
        return true
    }
    
    private func listFiles(url: URL)
    {
        let fileManager = FileManager.default
        var models = [FileModel]()
        
        var xibs = 0
        var storyboards = 0
        
        if let enumerator = fileManager.enumerator(atPath: url.path)
        {
            for item in enumerator
            {
                if let str = item as? String
                {
                    let url = URL(fileURLWithPath: str, relativeTo: url)
                    let name = url.lastPathComponent
                    
                    if url.pathExtension == "xib"
                    {
                        xibs += 1
                        models.append(FileModel(url: url, name: name, isStoryboard: false))
                    }
                    else if url.pathExtension == "storyboard"
                    {
                        storyboards += 1
                        models.append(FileModel(url: url, name: name, isStoryboard: true))
                    }
                    
                    DispatchQueue.main.async {
                        self.state = .loading(foundXIBs: xibs, foundStoryboards: storyboards)
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.state = .presenting(operation: ColorReplacementOperation(files: models))
        }
    }
    
    func replaceColors(operation: ColorReplacementOperation)
    {
        for file in operation.selectedFiles
        {
            rewrite(file: file, replacements: operation.replacements)
        }
    }
}

extension XMLManager: XMLParserDelegate
{
    private func rewrite(file: FileModel, replacements: [ColorReplacementModel])
    {
        do {
            let data = try Data(contentsOf: file.url)
            let xmlDoc = try AEXMLDocument(xml: data, options: AEXMLOptions())
            print(xmlDoc.xml)
        }
        catch {
            print(error)
        }
    }
}

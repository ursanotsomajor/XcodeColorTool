import SwiftUI

enum XMLManagerState
{
    case waiting, loading(foundXIBs: Int, foundStoryboards: Int), presenting(operation: ColorReplacementOperation)
}

class XMLManager: NSObject, ObservableObject
{
    @Published var state = XMLManagerState.waiting
    
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
    
    func replaceColors(operation: ColorReplacementOperation)
    {
        for file in operation.selectedFiles
        {
            parse(file: file, replacements: operation.colorReplacements, delta: operation.colorDelta)
        }
    }
}

// MARK: Files
extension XMLManager
{
    private func load(url: URL)
    {
        print("Reading files at: \(url.path)\n")
        
        DispatchQueue.main.async {
            self.state = .loading(foundXIBs: 0, foundStoryboards: 0)
        }
        
        readInterfaceFiles(url: url)
    }
    
    private func readInterfaceFiles(url: URL)
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
    
    private func readColorPalette(url: URL)
    {
        guard case .presenting(let operation) = state else { return }
        
        
        
        DispatchQueue.main.async {
            operation.colorReplacements = []
        }
    }
}


// MARK: Parsing
extension XMLManager
{
    private func parse(file: FileModel, replacements: [ColorReplacementModel], delta: Double)
    {
        do {
            let data = try Data(contentsOf: file.url)
            let xmlDocument = try AEXMLDocument(xml: data, options: AEXMLOptions())
            
            print("\n—————————————————— Parsing: \(file.name) ——————————————————\n")
            
            
            // Adding Named Colors dependency if there is none
            let dependencies = xmlDocument.root["dependencies"]
            
            if !dependencies.children.contains(where: { $0.attributes["name"] == "Named colors" })
            {
                let attributes = ["name": "Named colors", "minToolsVersion": "9.0"]
                dependencies.addChild(AEXMLElement(name: "capability", value: nil, attributes: attributes))
            }
            
            
            //Replacing all exact or similar colors within delta
            let colorElements = extractColorElements(in: xmlDocument.root["objects"])
            
            for item in colorElements
            {
                replaceColor(in: item, with: replacements, delta: delta)
            }
            
            
            // Adding color resources
            let resources: AEXMLElement
            
            if let error = xmlDocument.root["resources"].error, error == .elementNotFound
            {
                resources = AEXMLElement(name: "resources")
                xmlDocument.root.addChild(resources)
            }
            else {
                resources = xmlDocument.root["resources"]
            }
            
            for (color, name) in replacements.map({ ($0.customColor, $0.name) })
            {
                resources.children.removeAll(where: { $0.attributes["name"] == name })
                
                let namedColor = AEXMLElement(name: "namedColor", value: nil, attributes: ["name": name])
                let colorAttributes = ["red": "\(color.r)", "green": "\(color.g)", "blue": "\(color.b)", "alpha": "\(color.a)", "colorSpace": "custom", "customColorSpace": "sRGB"]
                namedColor.addChild(name: "color", value: nil, attributes: colorAttributes)
                resources.addChild(namedColor)
            }
            
            do {
                try xmlDocument.xml.write(to: file.url, atomically: false, encoding: .utf8)
            }
            catch {
                print("Error rewriting \(file.name): \(error)")
            }
        }
        catch {
            print("Couldn't extract XML from \(file.name) — \(file.url)")
        }
    }
    
    private func extractColorElements(in element: AEXMLElement) -> [AEXMLElement]
    {
        var colorElements = [AEXMLElement]()
        
        for item in element.children
        {
            if item.children.isEmpty
            {
                if item.name == "color"
                {
                    colorElements.append(item)
                }
            }
            else
            {
                colorElements.append(contentsOf: extractColorElements(in: item))
            }
        }
        
        return colorElements
    }
    
    private func replaceColor(in element: AEXMLElement,
                              with replacements: [ColorReplacementModel], delta: Double)
    {
        let attributes = element.attributes
        
        guard let key = attributes["key"] else { return }
        
        if let redString = attributes["red"], let red = Double(redString),
            let greenString = attributes["green"], let green = Double(greenString),
            let blueString = attributes["blue"], let blue = Double(blueString)
        {
            if let replacement = replacements.first(where: { $0.isSimilar(r: red, g: green, b: blue, delta: delta) })
            {
                element.attributes = ["key": key, "name": replacement.name]
            }
            else
            {
                print("Couldn't find custom color")
                print(element.xml)
            }
        }
//        else if let whiteString = attributes["white"], let white = Double(whiteString)
//        {
//
//        }
//        else if let cocoaTouchSystemColor = attributes["cocoaTouchSystemColor"]
//        {
//        }
//        else let name = attributes["name"]
//        {
//            return // Named color
//        }
//        else
//        {
//
//        }
//
//        if let c = color, let replacement = replacements.first(where: { $0.isSimilar(to: c) })
//        {
//            element.attributes = ["key": key, "name": replacement.name]
//        }
    }
}

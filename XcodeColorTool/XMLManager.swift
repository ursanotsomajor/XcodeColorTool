import SwiftUI

enum XMLManagerState
{
    case waiting, loading(foundXIBs: Int, foundStoryboards: Int), presenting(operation: ColorReplacementOperation)
}

enum XMLManagerDropType
{
    case interface, palette
}

class XMLManager: NSObject, ObservableObject
{
    private var log = [String]()
    
    @Published var state = XMLManagerState.waiting
    
    func onDrop(info: DropInfo, type: XMLManagerDropType) -> Bool
    {
        let id = kUTTypeFileURL as String
        
        guard let itemProvider = info.itemProviders(for: [id]).first else { return false }
        
        itemProvider.loadItem(forTypeIdentifier: id, options: nil) { item, error in
            
            guard let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
            
            switch type
            {
            case .interface:
                self.readInterfaceFiles(url: url)
            case .palette:
                self.readColorPalette(url: url)
            }
        }
        
        return true
    }
    
    func replaceColors(operation: ColorReplacementOperation)
    {
        log.removeAll()
        
        for file in operation.selectedFiles
        {
            parse(file: file, replacements: operation.colorReplacements, delta: operation.colorDelta)
        }
        
        if let url = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first
        {
            do {
                print(url)
                try log.joined(separator: "\n").write(to: url, atomically: true, encoding: .utf8)
            }
            catch {
                print("Error writing log: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: Files
extension XMLManager
{
    private func readInterfaceFiles(url: URL)
    {
        print("Looking for Xibs and Storyboards at: \(url.path)\n")
        
        DispatchQueue.main.async {
            self.state = .loading(foundXIBs: 0, foundStoryboards: 0)
        }
        
        var models = [FileModel]()
        
        var xibs = 0
        var storyboards = 0
        
        if let enumerator = FileManager.default.enumerator(atPath: url.path)
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
        
        print("Looking for colors at: \(url.path)\n")
        
        var replacements = [ColorReplacementModel]()
        
        if let enumerator = FileManager.default.enumerator(atPath: url.path)
        {
            for item in enumerator
            {
                guard let str = item as? String else { continue }
                
                let fileURL = URL(fileURLWithPath: str, relativeTo: url)
                let fileName = fileURL.lastPathComponent
                
                let folderURL = fileURL.deletingLastPathComponent()
                let folderName = folderURL.lastPathComponent
                
                if fileURL.pathExtension == "json", let colorName = folderName.components(separatedBy: ".").first
                {
                    do {
                        let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                        
                        if let dict = json as? [String: AnyObject],
                            let colors = dict["colors"] as? [[String: AnyObject]],
                            let color = colors.first?["color"] as? [String: AnyObject],
                            let components = color["components"] as? [String: String],
                            let rString = components["red"], let gString = components["green"],
                            let bString = components["blue"], let aString = components["alpha"],
                            let alpha = Double(aString)
                        {
                            if let rHex = rString.components(separatedBy: "x").last,
                                let gHex = gString.components(separatedBy: "x").last,
                                let bHex = bString.components(separatedBy: "x").last,
                                let color = CustomColor(hex: rHex + gHex + bHex)
                            {
                                replacements.append(ColorReplacementModel(customColor: color, name: colorName))
                            }
                            else if let r = Double(rString), let g = Double(gString), let b = Double(bString)
                            {
                                let color = CustomColor(r: r, g: g, b: b, a: alpha)
                                replacements.append(ColorReplacementModel(customColor: color, name: colorName))
                            }
                            else
                            {
                                print("Couldn't extract \(print(colorName)) color from \(components)")
                            }
                        }
                    }
                    catch
                    {
                        print(colorName)
                        print(fileName)
                        print()
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            operation.colorReplacements = replacements
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
            
            log.append("\n—————————————————— Parsing: \(file.name) ——————————————————\n")
            
            // Adding Named Colors dependency if there is none
            let dependencies = xmlDocument.root["dependencies"]
            
            if !dependencies.children.contains(where: { $0.attributes["name"] == "Named colors" })
            {
                let attributes = ["name": "Named colors", "minToolsVersion": "9.0"]
                dependencies.addChild(AEXMLElement(name: "capability", value: nil, attributes: attributes))
            }
            
            
            //Replacing all exact or similar colors within delta
            let colorElements = extractColorElements(in: xmlDocument.root["objects"])
            var replacedColors = Set<ColorReplacementModel>()
            
            for item in colorElements
            {
                if let replaced = replaceColor(in: item, with: replacements, delta: delta)
                {
                    replacedColors.insert(replaced)
                }
            }
            
            if replacedColors.isEmpty { return }
            
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
            
            for (color, name) in replacedColors.map({ ($0.customColor, $0.name) })
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
                log.append("Error rewriting \(file.name): \(error)")
            }
        }
        catch {
            log.append("Couldn't extract XML from \(file.name) — \(file.url)")
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
    
    private func replaceColor(in element: AEXMLElement, with replacements: [ColorReplacementModel],
                              delta: Double) -> ColorReplacementModel?
    {
        let attributes = element.attributes
        
        guard let key = attributes["key"] else { return nil }
        
        if let redString = attributes["red"], let red = Double(redString),
            let greenString = attributes["green"], let green = Double(greenString),
            let blueString = attributes["blue"], let blue = Double(blueString)
        {
            if let replacement = replacements.first(where: { $0.isSimilar(r: red, g: green, b: blue, delta: delta) })
            {
                element.attributes = ["key": key, "name": replacement.name]
                
                return replacement
            }
            else
            {
                log.append("Couldn't find replacement for custom color: \(attributes)")
            }
        }
//        else if let whiteString = attributes["white"], let white = Double(whiteString)
//        {
//
//        }
//        else if let cocoaTouchSystemColor = attributes["cocoaTouchSystemColor"]
//        {
//
//        }
//        else let name = attributes["name"]
//        {
//            return // Named color
//        }
//        else
//        {
//
//        }
        
        return nil
    }
}

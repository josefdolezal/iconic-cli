//
// SwiftGen
// Created by Ignacio Romero on 5/23/16.
// Copyright (c) 2015 Olivier Halligon
// MIT Licence
//

import Commander
import PathKit
import SwiftGenKit
import Stencil

let iconsCommand = command(
    outputOption,
    templateOption(prefix: "icons"),
    templatePathOption,
    Option<String>("enumName", "Icon", flag: "e", description: "The name of the enum to generate"),
    Argument<Path>("FILE", description: "Icons.ttf|otf|json file to parse.", validator: fileExists)
) { output, templateName, templatePath, enumName, path in
    
    let filePath = String(describing: path)
    
    let parser: IconsFileParser
    switch path.`extension` {
    case "ttf"?:
        let textParser = IconsFontFileParser()
        try textParser.parseFile(path: filePath)
        parser = textParser
    case "otf"?:
        let textParser = IconsFontFileParser()
        try textParser.parseFile(path: filePath)
        parser = textParser
    case "json"?:
        let textParser = IconsJSONFileParser()
        try textParser.parseFile(path: filePath)
        parser = textParser
    default:
        throw ArgumentError.invalidType(value: filePath, type: "TTF, OTF or JSON file", argument: nil)
    }
    
    do {
        let templateRealPath = try findTemplate(prefix: "icons", templateShortName: templateName, templateFullPath: templatePath)
        let template = try Template(path: templateRealPath)
        let context = parser.stencilContext(enumName: enumName, familyName: parser.familyName)
        let rendered = try template.render(context)
        output.write(content: rendered, onlyIfChanged: true)
        
        func writeJSONData(data: Data) {
            if let jsonString = String(data: data, encoding: String.Encoding.ascii) {
                switch output {
                case .Console: return
                case .File(let path):
                    do {
                        guard let jsonPath = ((path.description as NSString).deletingPathExtension as NSString).appendingPathExtension("json") else {
                            return print("Not writing the file as content is unchanged")
                        }
                        let jsonOutput = Path(jsonPath)
                        try jsonOutput.write(jsonString)
                        print("File written: \(jsonPath)")
                    } catch let e as NSError {
                        print("Error: \(e)")
                    }
                }
            }
        }
        
        var unicodes = [String: String]()
        
        for key in Array(parser.icons.keys) {
            let name = try! StringFilters.snakeToCamelCase(value: key) as? String
            
            if let name = name {
                unicodes[name] = parser.icons[key]
            }
        }
        
        let dict:[String: Any] = ["filename": path.lastComponent,
                                        "name": path.lastComponentWithoutExtension,
                                        "unicodes": unicodes]
        
        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        writeJSONData(data: jsonData)
    }
    catch {
        print("Failed to render template \(error)")
    }
}

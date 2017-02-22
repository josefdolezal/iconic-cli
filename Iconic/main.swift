//
//  main.swift
//  Iconic-CLI
//
//  Created by Josef Dolezal on 12/02/2017.
//  Copyright © 2017 Josef Dolezal. All rights reserved.
//

import PathKit
import Commander
import Stencil

func templateOption(prefix: String) -> Option<String> {
    return Option<String>(
        "template", "default", flag: "t",
        description: "The name of the template to use for code generation (without the \"\(prefix)\" prefix nor extension).")
}

let templatesRelativePath = "../templates"

let templatePathOption = Option<String>(
    "templatePath", "", flag: "p",
    description: "The path of the template to use for code generation. Overrides -t.")

let outputOption = Option(
    "output", OutputDestination.Console, flag: "o",
    description: "The path to the file to generate (Omit to generate to stdout)")

let main = command(
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

main.run()

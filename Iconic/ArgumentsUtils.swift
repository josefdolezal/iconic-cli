//
// SwiftGen
// Copyright (c) 2015 Olivier Halligon
// MIT Licence
//

import Commander
import PathKit

// MARK: Validators

func checkPath(type: String, assertion: @escaping (Path) -> Bool) -> ((Path) throws -> Path) {
  return { (path: Path) throws -> Path in
    guard assertion(path) else { throw ArgumentError.invalidType(value: path.description, type: type, argument: nil) }
    return path
  }
}

let pathExists = checkPath(type: "path") { $0.exists }
let fileExists = checkPath(type: "file") { $0.isFile }
let dirExists  = checkPath(type: "directory") { $0.isDirectory }

// MARK: Path as Input Argument

extension Path : ArgumentConvertible {
  public init(parser: ArgumentParser) throws {
    guard let path = parser.shift() else {
      throw ArgumentError.missingValue(argument: nil)
    }
    self = Path(path)
  }
}

// MARK: Output (Path or Console) Argument

enum OutputDestination: ArgumentConvertible {
  case Console
  case File(Path)

  init(parser: ArgumentParser) throws {
    guard let path = parser.shift() else {
      throw ArgumentError.missingValue(argument: nil)
    }
    self = .File(Path(path))
  }
  var description: String {
    switch self {
    case .Console: return "(stdout)"
    case .File(let path): return path.description
    }
  }

  func write(content: String, onlyIfChanged: Bool = false) {
    switch self {
    case .Console:
      print(content)
    case .File(let path):
      do {
        if try onlyIfChanged && path.exists && path.read(String.Encoding.utf8) == content {
          return print("Not writing the file as content is unchanged")
        }
        try path.write(content)
        print("File written: \(path)")
      } catch let e as NSError {
        print("Error: \(e)")
      }
    }
  }
}

// MARK: Template Arguments

enum TemplateError: Error, CustomStringConvertible {
  case NamedTemplateNotFound(name: String)
  case TemplatePathNotFound(path: Path)

  var description: String {
    switch self {
    case .NamedTemplateNotFound(let name):
      return "Template named \(name) not found. Use `swiftgen template` to list available named templates or use --templatePath to specify a template by its full path."
    case .TemplatePathNotFound(let path):
      return "Template not found at path \(path.description)."
    }
  }
}

extension Path {
  static let applicationSupport = Path(NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!)
}

let appSupportTemplatesPath = Path.applicationSupport + "Iconic/templates"
let bundledTemplatesPath = Path(ProcessInfo.processInfo.arguments[0]).parent() + templatesRelativePath

func findTemplate(prefix: String, templateShortName: String, templateFullPath: String) throws -> Path {
  guard templateFullPath.isEmpty else {
    let fullPath = Path(templateFullPath)
    guard fullPath.isFile else {
      throw TemplateError.TemplatePathNotFound(path: fullPath)
    }
    return fullPath
  }

  var path = appSupportTemplatesPath + "\(prefix)-\(templateShortName).stencil"
  if !path.isFile {
    path = bundledTemplatesPath + "\(prefix)-\(templateShortName).stencil"
  }
  guard path.isFile else {
    throw TemplateError.NamedTemplateNotFound(name: templateShortName)
  }
  return path
}

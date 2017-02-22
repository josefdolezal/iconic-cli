//
// GenumKit
// Copyright (c) 2015 Olivier Halligon
// MIT Licence
//

import Stencil

enum FilterError: Error {
    case InvalidInputType
}

public struct StringFilters {
    public static func stringToSwiftIdentifier(value: Any?) throws -> Any? {
        guard let value = value as? String else { throw FilterError.InvalidInputType }
        return swiftIdentifier(fromString: value, replaceWithUnderscores: true)
    }

    /* - If the string starts with only one uppercase letter, lowercase that first letter
     * - If the string starts with multiple uppercase letters, lowercase those first letters up to the one before the last uppercase one
     * e.g. "PeoplePicker" gives "peoplePicker" but "URLChooser" gives "urlChooser"
     */
    public static func lowerFirstWord(value: Any?) throws -> Any? {
        guard let string = value as? String else { throw FilterError.InvalidInputType }


        let cs = NSMutableCharacterSet.uppercaseLetter()
        let scalars = string.unicodeScalars
        let start = scalars.startIndex
        var idx = start

        while cs.longCharacterIsMember(scalars[idx].value) && idx <= scalars.endIndex {
            idx = scalars.index(after: idx)
        }

        if idx > scalars.index(after: start) && idx < scalars.endIndex {
            idx = scalars.index(before: idx)
        }

        let transformed = String(scalars[start..<idx]).lowercased() + String(scalars[idx..<scalars.endIndex])

        return transformed
    }

    public static func titlecase(value: Any?) throws -> Any? {
        guard let string = value as? String else { throw FilterError.InvalidInputType }
        return try titlecase(value: string)
    }

    public static func snakeToCamelCase(value: Any?) throws -> Any? {
        guard let string = value as? String else { throw FilterError.InvalidInputType }

        var prefixUnderscores = ""
        for scalar in string.unicodeScalars {
            guard scalar == "_" else { break }
            prefixUnderscores += "_"
        }

        let comps = string.components(separatedBy: "_")
        return prefixUnderscores + comps.map { titlecase(string: $0) }.joined(separator: "")
    }

    /**
     This returns the string with its first parameter uppercased.
     - note: This is quite similar to `capitalise` except that this filter doesn't lowercase
     the rest of the string but keep it untouched.

     - parameter string: The string to titleCase

     - returns: The string with its first character uppercased, and the rest of the string unchanged.
     */
    private static func titlecase(string: String) -> String {
        guard let first = string.unicodeScalars.first else { return string }
        return String(first).uppercased() + String(string.unicodeScalars.dropFirst())
    }

    static func unicodeCase(value: Any?) throws -> Any? {
        guard let string = value as? String else { throw FilterError.InvalidInputType }
        return unicodeCase(string: string)
    }

    private static func unicodeCase(string: String) -> String {
        let escapingCharacterSet = CharacterSet(charactersIn: "\\")
        let unicode = string.trimmingCharacters(in: escapingCharacterSet)

        let newString = "\\u{" + unicode + "}"

        return newString
    }
}

struct ArrayFilters {
    static func join(value: Any?) throws -> Any? {
        guard let array = value as? [Any] else { throw FilterError.InvalidInputType }
        let strings = array.flatMap { $0 as? String }
        guard array.count == strings.count else { throw FilterError.InvalidInputType }

        return strings.joined(separator: ", ")
    }
}

struct NumFilters {
    static func hexToInt(value: Any?) throws -> Any? {
        guard let value = value as? String else { throw FilterError.InvalidInputType }
        return Int(value, radix:  16)
    }

    static func int255toFloat(value: Any?) throws -> Any? {
        guard let value = value as? Int else { throw FilterError.InvalidInputType }
        return Float(value) / Float(255.0)
    }
    
    static func percent(value: Any?) throws -> Any? {
        guard let value = value as? Float else { throw FilterError.InvalidInputType }
        
        let percent = Int(value * 100.0)
        return "\(percent)%"
    }
}

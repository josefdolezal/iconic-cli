//
//  StringFilters.swift
//  Iconic-CLI
//
//  Created by Josef Dolezal on 12/02/2017.
//  Copyright © 2017 Josef Dolezal. All rights reserved.
//

import Stencil

enum FilterError: Error {
    case invalidInputType
}

public struct StringFilters {
    public static func snakeToCamelCase(value: Any?) throws -> Any? {
        guard let string = value as? String else { throw FilterError.invalidInputType }

        var prefixUnderscores = ""
        for scalar in string.unicodeScalars {
            guard scalar == "_" else { break }
            prefixUnderscores += "_"
        }

        let components = string.components(separatedBy: "_").map{ titlecase($0) }

        return prefixUnderscores + components.joined(separator: "")
    }

    private static func titlecase(_ string: String) -> String {
        guard let first = string.unicodeScalars.first else { return string }
        return String(first).uppercased() + String(string.unicodeScalars.dropFirst())
    }
}

//
//  IconsFileParser+Context.swift
//  Iconic-CLI
//
//  Created by Josef Dolezal on 12/02/2017.
//  Copyright © 2017 Josef Dolezal. All rights reserved.
//

import Stencil

extension IconsFileParser {
    public func stencilContext(enumName: String = "Icon", familyName: String?) -> Context {
        let namespace = Namespace()
        let iconMap = icons.sorted { $0.key < $1.key }

        var dictionary:[String:Any] = ["enumName": enumName, "icons" : iconMap]

        if let familyName = familyName {
            dictionary["familyName"] = familyName
        }
        namespace.registerFilter("swiftIdentifier", filter: StringFilters.stringToSwiftIdentifier)
        namespace.registerFilter("join", filter: ArrayFilters.join)
        namespace.registerFilter("lowerFirstWord", filter: StringFilters.lowerFirstWord)
        namespace.registerFilter("snakeToCamelCase", filter: StringFilters.snakeToCamelCase)
        namespace.registerFilter("titlecase", filter: StringFilters.titlecase)
        namespace.registerFilter("unicodeCase", filter: StringFilters.unicodeCase)
        namespace.registerFilter("hexToInt", filter: NumFilters.hexToInt)
        namespace.registerFilter("int255toFloat", filter: NumFilters.int255toFloat)
        namespace.registerFilter("percent", filter: NumFilters.percent)

        return Context(dictionary: dictionary, namespace: namespace)
    }
}

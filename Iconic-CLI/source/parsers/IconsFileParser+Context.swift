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
        let iconMap = icons.sorted { $0.key < $1.key }

        var dictionary:[String:Any] = ["enumName": enumName, "icons" : iconMap]

        if let familyName = familyName {
            dictionary["familyName"] = familyName
        }

        return Context(dictionary: dictionary)
    }
}

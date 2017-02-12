//
//  main.swift
//  Iconic-CLI
//
//  Created by Josef Dolezal on 12/02/2017.
//  Copyright © 2017 Josef Dolezal. All rights reserved.
//

import PathKit
import Commander

let TEMPLATES_RELATIVE_PATH = "../templates"

func templateOption(prefix: String) -> Option<String> {
    return Option<String>("template", "default", flag: "t", description: "The name of the template to use for code generation (without the \"\(prefix)\" prefix nor extension).")
}

let templatePathOption = Option<String>("templatePath", "", flag: "p", description: "The path of the template to use for code generation. Overrides -t.")

let outputOption = Option("output", OutputDestination.Console, flag: "o", description: "The path to the file to generate (Omit to generate to stdout)")

print("Iconic")

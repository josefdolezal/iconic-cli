# Iconic CLI _proof of concept_

This repository is proof of concept for CLI support in [Iconic](https://github.com/dzenbot/Iconic) iOS framework.

## Installation

```bash
pod install   // Download all dependencies
rake install  // Build & link dependencies to Iconic binary
```

Once the installation is finished, Iconic is installed in `./build/iconic`. App
can not be build with XCode because embedded frameworks are not bundled
automatically.

## Run the demo

For now, CLI has the very same API as v1.2 (older version of icons parser).
Ideally, the whole logic from bash script `Iconizer` should be moved to swift,
but it is not done yet. Run the demo with following command:

```
./build/iconic/bin/iconic "$PWD/fonts/FontAwesome/FontAwesome.ttf" --templatePath "$PWD/build/iconic/templates/iconic-default.stencil" --output Icons.Generated.swift --enumName FontAwesomeIcons
```

Which is really heavy, could be something like:

```
./build/iconic/bin/iconic fonts/FontAwesome/FontAwesome.ttf --output Icons.Generated.swift
```

## Things to point out
Main difference from current version is that `SwiftGen` dependency is completely removed.
Iconic is now standalone app, all dependencies are managed with CocoaPods so
Iconic may keep track with latest version of dependencies.

Unfortunately, not everything was removed. Following files are originally from SwiftGen:

* [ArgumentsUtils.swift](Iconic/ArgumentsUtils.swift)
* Stencil [Filters.swift](Iconic/Filters.swift)
* [SwiftIdentifiers.swift](Iconic/SwiftIdentifiers.swift)

The only change is that files are converted to swift 3 API.

[Rakefile](Rakefile) is taken from SwiftGen, but shortened and updated to
compile Iconic correctly.

Also, binary now only generates the Icons enum, `IconDrawable.swift` and Catalog are
either not copied to destination folder.

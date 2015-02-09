# Giraff

## One Tap Curated Gifs

This is a product being built by the Assembly community. You can help push this idea forward by visiting [https://assembly.com/giraff](https://assembly.com/giraff).

**Quick Start**: Install Xcode, cocoapods, `pod install`, `cp configuration.plist.example configuration.plist`

### Getting started

To get started download Xcode from from [here](https://developer.apple.com/xcode/downloads/).

Before opening the project, run cocoapods.

Cocoapods can be installed from the command-line with:
```
gem install cocoapods
```

[More info on Cocoapods.](https://developer.apple.com/xcode/downloads/)

After installing CocoaPods, clone the source repository.
On the commandline CD into the directory containing the Podfile.

Then run:
```
pod install
```

You should see a message indicating the fact that things were installed successfully and that you should use the workspace file.

Now you want to create a configuration.plist file. You can copy the example provided:

`cp configuration.plist.example configuration.plist`

Open the workspace file from the commandline with or open using the Finder.
```
open Giraff.xcworkspace
```

Build and run... Happy coding.

If you encounter a build error, try cleaning your project.

```
Xcode -> Window -> Organizer -> Projects, select your project, and press the "Delete..." button next to "Derived data".

If this doesn't work, try Product->Clean (Cmd+Shift+k).
```

### How Assembly Works

Assembly products are like open-source and made with contributions from the community. Assembly handles the boring stuff like hosting, support, financing, legal, etc. Once the product launches we collect the revenue and split the profits amongst the contributors.

Visit [https://assembly.com](https://assembly.com) to learn more.

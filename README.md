<p align="center">
  <a href="https://ibb.co/MkmNV8cm">
    <img src="https://i.ibb.co/zVzfR8Xz/Skyliner-Light.png" alt="Skyliner-Light" width="150" />
  </a>
</p>

<h1 align="center"><strong>Skyliner</strong></h1>

<div align="center">

![](https://img.shields.io/badge/-@skyliner.app-informational?style=flat&logo=bluesky&logoColor=white&color=007AFF)
![](https://img.shields.io/badge/-Swift-informational?style=flat&logo=swift&logoColor=white&color=007AFF)
![](https://img.shields.io/badge/-SwiftUI-informational?style=flat&logo=swift&logoColor=white&color=007AFF)
![](https://img.shields.io/badge/-ATProtoKit-informational?style=flat&logo=swift&logoColor=white&color=007AFF)
![](https://img.shields.io/badge/-iOS-informational?style=flat&logo=apple&logoColor=white&color=007AFF)
  
</div>

> [!CAUTION]
> ***Skyliner is very early on in its development and is subject to large scale refactors including complete reorganization of the project structure.***

<img width="1500" height="250" alt="Banner from Figma" src="https://github.com/user-attachments/assets/f6ee93ad-53dc-45b9-8b90-b8737786cb08" />

## Overview

**Skyliner** is a native iOS client for [Bluesky](https://blueskyweb.xyz), built with Swift and SwiftUI. It utilizes the [ATProtoKit](https://github.com/MasterJ93/ATProtoKit) framework to connect to Bluesky’s AT Protocol network. The app focuses on a refined user interface and smooth user experience, with an emphasis on minimalistic and maintainable code. Skyliner demonstrates a modern SwiftUI architecture and provides a solid foundation for further customization and new features.

<img width="1489" height="750" alt="Templify App Store Template" src="https://github.com/user-attachments/assets/2e7827f7-7bb9-4091-bc16-dfcef75c417d" />

## Features

* **Native SwiftUI App:** Written entirely in Swift and SwiftUI for a fully native iOS experience.
* **Bluesky Integration:** Connects to the decentralized Bluesky social network via ATProtoKit, handling authentication and feed data through the AT Protocol.
* **UI/UX Focus:** Polished interface elements and animations (custom components, icons, and backgrounds) for an engaging user experience.
* **Extensible Foundation:** The codebase is organized for easy refactoring and addition of new features without breaking existing functionality.

## Setup Instructions

### Prerequisites

* **Xcode 26.0 or later** – Required to build and run the app.
* **iOS 26.0 or later** – Deployment target for the Skyliner app.
* **Swift 6.0 or later** – The project is written in Swift 6.

### Building and Running

1. **Clone the Repository:** Download or clone the Skyliner project source to your local machine.
2. **Open in Xcode:** Double-click `Skyliner.xcodeproj` to open the project in Xcode.
3. **Fetch Dependencies:** Xcode will automatically retrieve Swift Package Manager dependencies (ATProtoKit, KeychainSwift, etc.) as defined in the project. Ensure you have an internet connection on first build so packages can resolve.
4. **Select a Target:** Choose the *Skyliner* app scheme and an iOS Simulator (or physical device) running iOS 26.0+.
5. **Build & Run:** Press **Run** (⌘R) in Xcode. The app should build and launch in the simulator, showing the Skyliner splash screen and then the app interface.

## Dependencies

Skyliner uses Swift Package Manager (SPM) to manage its external libraries. Key dependencies include:

* **ATProtoKit (v0.30.0):** A Swift client library for Bluesky’s AT Protocol – handles networking and data models for Bluesky integration.
* **KeychainSwift (v24.0.0):** Used for securely storing sensitive data (e.g. authentication tokens) in the iOS Keychain.
* **SwiftLog (Apple Swift Logging API v1.6.3):** Provides a flexible logging mechanism used by the app for debug and error logging.
* **SwiftSyntax (v600.0.1):** Swift syntax parsing library (included as a dependency, potentially for future development needs or as a transient dependency of other packages).

These packages are defined in the project’s SwiftPM configuration. The exact versions are pinned in **`Skyliner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`**, and they will be auto-fetched on project build.

## Project Structure

The project is organized into logical groups, with each top-level folder numbered (`1` through `5`) followed by a space and the folder name. This naming convention enforces a linear, intentional order in Xcode’s project navigator (making the flow of the app easier to follow). For example, **`1 Documents`** contains documentation, **`2 Resources`** contains app assets, **`3 Managers`** contains the data/business logic layer, and so on. This structure improves searchability and logical flow at the expense of some rigidity (renaming these folders would require updating references in Xcode settings, e.g. if the Resources folder name changes, it must be updated in build settings).

All SwiftUI view files (in **Components** and **Views**) include live Preview providers to allow interface testing and iteration in Xcode’s canvas. The codebase is intended to be clean and straightforward – refactoring a component should be localized (avoiding cascade changes across many files).

## Development Notes

### SwiftUI Previews and UI Development

All custom views and components in Skyliner are expected to have working **SwiftUI previews**. This means files in **Components** and **Views** include a `PreviewProvider` struct (usually at the bottom of the file) that renders the view with sample data. This allows developers to open the file and get an immediate live preview of the UI component in Xcode’s canvas. It’s a helpful practice for UI development: you can tweak the view’s code and see updates in real time, and ensure that each component can be instantiated in isolation.

When adding new Views or Components, developers should follow this convention (add a preview), as it was a noted project standard. The preview should provide any required dummy data or use `.environmentObject` with test instances of managers as needed, so that it builds in canvas without the full app running.

### Code Style and Maintenance

The Skyliner codebase is kept intentionally **minimalistic and modular**:

* Each Swift file typically has a single primary struct/class or a focused set of extensions, to keep things easy to find.
* The folder structure (with numeric prefixes) reflects an ordered thought process – for instance, **Documents (1)** and **Resources (2)** are high-level and mostly static, while **Managers (3)** handle dynamic data, **Components (4)** build UI pieces, and **Views (5)** assemble the UI for display.
* This linear structure also mirrors the app’s flow: e.g., Managers prepare data, Components render pieces of UI, and Views bring it all together for the user.
* Comments and MARKs (sections within files) are used to denote important parts of the code (such as `// MARK: - Imports` or `// MARK: - Authentication Functions` in the managers).

The combination of clear structure, logging conventions, and SwiftUI previews makes it easier for any developer to onboard onto the project or navigate the code. The emphasis is on **clarity** – so if a change needs to be made (say, altering how a post is displayed), the developer can find `PostComponent.swift` quickly and modify it, without unexpected side-effects in unrelated parts of the app.

### License

The legalities pertaining to this repository and whatever it may contain are detailed in LICENSE.MD.

---

*Skyliner’s README is intended to provide both high-level guidance and low-level detail. By following this documentation, developers should be able to understand the project layout, set up the development environment, and adhere to the established patterns when contributing to Skyliner.*

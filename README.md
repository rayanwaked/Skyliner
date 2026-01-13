<p align="center">
  <a href="https://ibb.co/MkmNV8cm">
    <img src="https://i.ibb.co/zVzfR8Xz/Skyliner-Light.png" alt="Skyliner Light Icon" width="125" />
  </a>
</p>

<h2 align="center"><strong>Skyliner</strong></h2>

<div align="center">

![](https://img.shields.io/badge/-@skyliner.app-informational?style=flat&logo=bluesky&logoColor=white&color=007AFF)
![](https://img.shields.io/badge/-Swift-informational?style=flat&logo=swift&logoColor=white&color=007AFF)
![](https://img.shields.io/badge/-SwiftUI-informational?style=flat&logo=swift&logoColor=white&color=007AFF)
![](https://img.shields.io/badge/-ATProtoKit-informational?style=flat&logo=swift&logoColor=white&color=007AFF)
![](https://img.shields.io/badge/-iOS-informational?style=flat&logo=apple&logoColor=white&color=007AFF)
  
</div>

> ⚠️ **Caution**
> 
> This repository represents an early‑stage project. The codebase is evolving rapidly and major refactors are expected. APIs, folder names and internal structures may change without notice. If you build on top of Skyliner today, be prepared to rebase often.
> 
<img width="1500" height="250" alt="Skyliner Blue Sky with Clouds Banner" src="https://github.com/user-attachments/assets/89cedce6-e967-4d01-b586-0169b8dd4329" />


## Overview

**Skyliner** is a native iOS client for [Bluesky](https://blueskyweb.xyz), built with Swift and SwiftUI. It utilizes the [ATProtoKit](https://github.com/MasterJ93/ATProtoKit) framework to connect to Bluesky’s AT Protocol. The app focuses on a refined user interface and smooth user experience, with an emphasis on minimalistic and maintainable code. 

This is done with an **MVVM‑C** (Model‑View‑ViewModel‑Coordinator) architecture with a centralized `AppState` for dependency injection and global state. The goal is a refined, elegant user experience built on a clean, maintainable codebase. Development experience matters just as much as user experience.

<img width="5550" height="2796" alt="Skyliner iOS App Store Images" src="https://github.com/user-attachments/assets/562ed463-cda8-430a-b01d-3f079c7a1ce2" />

### Key Architectural Highlights

- **Centralised state management** via `AppState`, which instantiates managers on demand and coordinates authentication and data loading
- **Protocol‑oriented design** for post interactions and view models; shared behaviours such as liking or reposting are defined once and reused across managers
- **Reactive authentication flow** using `AsyncStream` to propagate a new `ClientManager` to all managers when a session is restored or a user logs in
- **Feature‑first modularity** – features like Post, Notification, Banner, Header and TabBar live in their own folders under `4 Features` with their own views and managers, making it easy to reason about and extend individual areas of the app
- **Modern iOS UI elements** such as SwiftUI's glass effect, backport helpers for iOS 18+ and asynchronous image loading with NukeUI

> 📖 A more detailed description of the architecture can be found in `2 Managers/1 ARCHITECTURE.md`. That document explains the MVVM‑C approach, the manager patterns and how post interactions are handled uniformly across the app.

## Features

Current functionality includes:

- **Home feed and timeline** – display posts from your followed accounts with pagination and offline caching. Interaction support includes liking, reposting, replying and sharing
- **Explore** – search for people or posts with debounced queries and scrolling results. Top trends and hashtags are also available
- **Notifications** – view recent mentions, replies and other alerts in a dedicated tab. Tapping a notification navigates to the relevant post or profile
- **Profile management** – display and edit your own profile and view other users' profiles. A banner feature allows custom header images with a parallax scroll effect
- **Composer** – create a new post or reply via a modal sheet. Compose views present as sheets with rounded corners and respect keyboard safe areas
- **Analytics** – page and interaction events are tracked via PostHog for user‑behaviour insight (requires a valid API key; see configuration below)

Additional features such as threaded conversations, banner effects and reply flows are implemented as dedicated modules in the Features directory. Because of the modular structure, adding a new feature typically involves adding a new manager and a SwiftUI view without touching other parts of the codebase.

## Prerequisites

This project targets cutting‑edge Apple platforms and requires recent tooling:

- **Xcode 26.0 or later** – the project uses SwiftUI features only available in Xcode 26
- **iOS 26.0 or later** – while backports exist for some APIs, many views depend on iOS 26 glass effects and tab bar behaviours
- **Swift 6.0 or later** – asynchronous functions, `@Observable` and other Swift 6 features are heavily used

> ⚠️ Earlier versions of Xcode or iOS might compile parts of the code, but you will lose animations, glass effects and other modern UI elements. Be aware that running on older devices is not a project goal at this time.

## Setup & Running

1. **Clone this repository:**
   ```bash
   git clone https://github.com/rayanwaked/Skyliner.git
   ```

2. **Open the project:** double‑click `Skyliner.xcodeproj` or open the `.xcworkspace` if you prefer to manage packages through Xcode's workspace

3. **Fetch dependencies:** on first build Xcode will automatically resolve Swift Package Manager dependencies. Ensure you have an active internet connection

4. **Provide configuration keys:** the app relies on a PostHog API key for analytics. The development key is stored in `1 Resources/Keys.xcconfig`, but for production you should replace the `POSTHOG_API_KEY` environment variable with your own. Without a valid key the app will still run, but analytics will be disabled

5. **Select a run target:** choose the Skyliner scheme and select an iOS 26 simulator or an iPhone/iPad device running iOS 26.0 or later

6. **Run:** press Run (⌘R) in Xcode. The app will launch and show the authentication screens. After signing in, you will see the home feed

> 💡 If you run into build issues due to package resolution, try **File → Packages → Resolve Package Versions** in Xcode. On machines with older Xcode versions you may need to manually update Swift toolchains.

## Dependencies

Skyliner uses Swift Package Manager (SPM) to pull in external libraries. These packages and their versions are pinned in `Package.resolved` (generated by Xcode). Notable dependencies include:

| Package | Purpose |
|---------|---------|
| **ATProtoKit** | Networking and models for the Bluesky AT protocol. All API calls go through a `ClientManager` wrapper |
| **KeychainSwift** | Lightweight wrapper for storing credentials securely in the iOS keychain |
| **NukeUI** | Asynchronous image loading for SwiftUI with `LazyImage` |
| **BezelKit** | Device bezel measurements for consistent radii in glass effects |
| **Glur** | GPU‑efficient blur effects with configurable radius and direction |
| **PostHog** | Analytics library for event metrics capture |
| **Combine** | Apple's reactive framework for authentication and data streams |

All dependencies are resolved automatically by SPM. If you wish to upgrade or pin different versions, edit the `Package.swift` manifest or the project's package configuration in Xcode.


## Project Structure

<img width="4727" height="3138" alt="Skyliner Xcode Project Screeenshot" src="https://github.com/user-attachments/assets/95bd3a89-6c7b-4e93-a7e2-8adcb530a421" />

Skyliner uses a **numbered directory scheme** to convey logical and chronological order. Each top‑level folder begins with a numeral followed by its name:

### 📁 1 Resources
Static assets and support files:
- **Designs:** reusable layout styles and backgrounds
- **Assets.xcassets:** images, icons and colours
- **Standards:** constants, helpers, modifiers and backport wrappers
- **Backports.swift:** compatibility helpers for older OS versions
- **Keys.xcconfig:** environment variables such as your PostHog key

### 📁 2 Managers
The business logic layer. Managers encapsulate networking, data caching and state handling:

- **AuthManager:** handles login, logout and session restoration
- **ClientManager:** wrapper around ATProtoKit
- **UserManager, PostManager, SearchManager, ProfileManager, etc.:** domain-specific data management
- **DataCoordinator:** orchestrates data loading across managers at app start

> 📖 The `1 ARCHITECTURE.md` file in this folder contains an in‑depth explanation of the MVVM‑C approach and design patterns.

### 📁 3 Components
Reusable SwiftUI building blocks such as buttons, input fields, profile pictures and web views. These encapsulate styling and behaviour for composition in multiple contexts.

### 📁 4 Features
Self‑contained feature modules. Each feature exposes a SwiftUI view and, if necessary, its own manager(s):

- **Post:** renders individual posts, embed previews and actions
- **Thread:** displays conversation threads
- **Reply:** provides compose sheets for replies
- **Banner and Header:** profile header images with blur and parallax effects
- **Notification:** lists user notifications
- **Weather:** simple weather card demonstration
- **TabBar:** bottom navigation and sheet presentation

### 📁 5 Views
Top‑level screens composed from components and features:

- **1 Tabs:** home, explore, notifications and user profile tabs
- **2 Sheets:** modals such as compose, profile and settings
- **3 Screens:** navigation flows for authentication and onboarding
- **RouterView.swift:** central router for screen selection based on app state

> 💡 The numbering convention ensures foundational files appear first in Xcode's navigator. While renaming is possible, it requires adjusting target settings in Xcode.

## Development Notes

- **SwiftUI previews:** every view includes `#Preview` with representative dummy data
- **Clean, modular files:** each Swift file defines a single type or cohesive extensions. Use `// MARK:` comments for section separation
- **Asynchronous patterns:** managers use `async/await`, `Task` and `AsyncStream` without blocking the main thread
- **Error handling:** API calls use `do/catch` with user feedback and haptic signals, degrading gracefully
- **Analytics opt‑in:** PostHog tracking enabled by default if key is provided. Ensure privacy policy compliance

## Roadmap and Known Issues

Skyliner is under active development. Planned improvements include:

- **Improved thread rendering** – performance and UX improvements for conversation threads
- **Cross‑platform support** – iPad‑optimised layouts
- **UI evolution** — design changes to afford Skyliner a more brand-specific identity

> ⚡️ Track issues and contribute via the project's issue tracker. The API surface is unstable and may change.

## License

This project is released under a dual license-policy framework. See `LICENSE.md` and `POLICY.md` for full details.

---

Skyliner aims to be a polished, native client for the Bluesky social network. Its modular architecture, modern SwiftUI patterns and strong emphasis on maintainability make it a solid foundation for future growth. However, it is still very early in its life cycle – expect things to break and evolve. If you decide to explore the project or contribute, tread carefully and be prepared for changes.

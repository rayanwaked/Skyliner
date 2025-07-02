# Skyliner ✈️

&#x20;*Skyliner app icon concept (airplane logo) used in the app’s branding.*

## Overview

**Skyliner** is a native iOS client for [BlueSky](https://blueskyweb.xyz), built with Swift and SwiftUI. It utilizes the [ATProtoKit](https://github.com/MasterJ93/ATProtoKit) framework to connect to BlueSky’s AT Protocol network. The app focuses on a refined user interface and smooth user experience, with an emphasis on minimalistic and maintainable code. Skyliner demonstrates a modern SwiftUI architecture and provides a solid foundation for further customization and new features.

## Features

* **Native SwiftUI App:** Written entirely in Swift and SwiftUI for a fully native iOS experience.
* **BlueSky Integration:** Connects to the decentralized BlueSky social network via ATProtoKit, handling authentication and feed data through the AT Protocol.
* **Modern Architecture:** Uses a scalable MVVM-like architecture with managers and view models, making the code easy to understand and extend.
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

* **ATProtoKit (v0.30.0):** A Swift client library for Bluesky’s AT Protocol – handles networking and data models for BlueSky integration.
* **KeychainSwift (v24.0.0):** Used for securely storing sensitive data (e.g. authentication tokens) in the iOS Keychain.
* **SwiftLog (Apple Swift Logging API v1.6.3):** Provides a flexible logging mechanism used by the app for debug and error logging.
* **SwiftSyntax (v600.0.1):** Swift syntax parsing library (included as a dependency, potentially for future development needs or as a transient dependency of other packages).

These packages are defined in the project’s SwiftPM configuration. The exact versions are pinned in **`Skyliner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`**, and they will be auto-fetched on project build.

## Project Structure

The project is organized into logical groups, with each top-level folder numbered (`1` through `5`) followed by an em dash and the folder name. This naming convention enforces a linear, intentional order in Xcode’s project navigator (making the flow of the app easier to follow). For example, **`1 — Documents`** contains documentation, **`2 — Resources`** contains app assets, **`3 — Managers`** contains the data/business logic layer, and so on. This structure improves searchability and logical flow at the expense of some rigidity (renaming these folders would require updating references in Xcode settings, e.g. if the Resources folder name changes, it must be updated in build settings).

All SwiftUI view files (in **Components** and **Views**) include live Preview providers to allow interface testing and iteration in Xcode’s canvas. The codebase is intended to be clean and straightforward – refactoring a component should be localized (avoiding cascade changes across many files).

Below is a **detailed listing** of every file and directory in the project, with the structure preserved (including hidden files):

```plaintext
Skyliner/                                               (Project root directory)
├── App/                                               (Application source code)
├── 1 — Documents/                                       (Project documentation)
│   ├── README.md           (Project README with overview, features, guidelines)
│   └── LICENSE.md                                             (Project license)
├── 2 — Resources/                                    (App resources and assets)
│   ├── Assets.xcassets/                    (Asset catalog for images and icons)
│   │   ├── AppIcon.appiconset/                    
│   │   ├── AccentColor.colorset/                  
│   │   └── Images/                                    (Additional image assets)
│   │       ├── GradientBackground.imageset/      
│   │       ├── SkylinerIcon.imageset/                     
│   │       └── CloudIcon.imageset/                         
│   ├── Entitlements.entitlements               (App entitlements configuration)
│   └── Launch.storyboard                             (Launch screen storyboard)
├── 3 — Managers/                              (Logic and data management layer)
│   ├── AppState.swift                             (Global app state management)
│   ├── ClientManager.swift                  (Networking/ATProto client manager)
│   ├── A — Authentication/                     (Authentication domain managers)
│   │   ├── AuthenticationManager.swift
│   │   └── AuthenticationFunctions.swift
│   ├── B — Profile/                              (User profile domain managers)
│   │   ├── ProfileManager.swift
│   │   └── ProfileModel.swift
│   ├── C — Post/                                         (Post domain managers)
│   │   ├── PostManager.swift
│   │   └── PostModel.swift
│   ├── D — Feed/                                         (Feed domain managers)
│   │   ├── FeedManager.swift
│   │   └── FeedModel.swift
│   └── E — Trend/                                   (Trending content managers)
│       ├── TrendManager.swift
│       └── TrendModel.swift
├── 4 — Components/                                     (Reusable UI components)
│   ├── A — Buttons/
│   │   ├── ButtonComponent.swift
│   │   └── CompactButtonComponent.swift
│   ├── B — TextFields/
│   │   └── InputFieldComponent.swift
│   ├── E — Cells/
│   │   └── PostComponent.swift
│   ├── G — Lists/
│   │   └── FeedComponent.swift
│   ├── I — Navigation/
│   │   ├── HeaderComponent.swift
│   │   └── TabBarComponent.swift
│   ├── K — Animations/
│   │   ├── BackgroundComponent.swift
│   │   └── SplashComponent.swift
│   ├── L — Seperators/
│   │   └── SeperatorComponent.swift
│   └── M — Shared/
│       ├── Constants.swift
│       ├── Helpers.swift
│       ├── Haptics.swift
│       └── Modifiers.swift
└── 5 — Views/                                          (Screens and main views)
       ├── SkylinerApp.swift                                   (App entry point)
       ├── RouterView.swift                             (Navigation router view)
       ├── Tabs/                                                (Main tab views)
       │   ├── HomeView.swift
       │   ├── SearchView.swift
       │   ├── NotificationsView.swift
       │   └── ProfileView.swift
       └── Authentication/                                  (Login/Signup views)
           ├── AuthenticationView.swift
           ├── AuthenticationViewModel.swift
           └── AuthenticationExtension.swift
```

## File Descriptions

Below is a breakdown of each major file and directory, along with a brief description of its purpose or contents:

* **App/1 — Documents/**

  * **README.md:** The project’s README (this document) containing the overview, features, setup instructions, and development notes.
  * **LICENSE.md:** The open-source license for Skyliner. (The project is released under the **GNU Affero General Public License v3**, detailing terms for copying, modification, and distribution.)

* **App/2 — Resources/**

  * **Assets.xcassets/** – Xcode asset catalog containing images and colors used by the app (detailed in the [Assets](#assets) section below). This includes the app icon sets, accent color, and other image assets (like background, logo, etc.).
  * **Entitlements.entitlements** – iOS application entitlements file. Contains privileges the app is enabled for. In Skyliner, this includes at least the `aps-environment` key set to “development” (enabling development push notifications).
  * **Launch.storyboard** – The launch screen storyboard displayed while the app is launching. It’s likely a simple storyboard (possibly just a background color or logo) that iOS shows momentarily on app startup.

* **App/3 — Managers/** (Global controllers and data managers for app logic)

  * **AppState.swift:** Manages global app state and settings (for example, tracking whether a user is logged in, theme preferences, or other high-level state accessible throughout the app).
  * **ClientManager.swift:** Handles networking and API client setup for BlueSky. This likely uses ATProtoKit to perform network calls (such as fetching feeds, posting content, authentication requests) and might manage API endpoints or client configuration.
  * **A — Authentication/** *(Authentication domain)*

    * **AuthenticationManager.swift:** Logic for user authentication flows – signing in, signing out, and refreshing credentials. Likely coordinates with `KeychainSwift` to store tokens and uses ATProtoKit for auth network calls.
    * **AuthenticationFunctions.swift:** Supplementary helper functions related to authentication. Could include utility methods for validating input, handling OAuth/ATP session details, or parsing responses. This file separates supportive auth logic from the main manager for clarity.
  * **B — Profile/** *(User profile domain)*

    * **ProfileManager.swift:** Manages retrieval and updating of user profile information. It might handle fetching profile details from BlueSky, editing profile data, or caching profile info in the app.
    * **ProfileModel.swift:** Data model representing a user profile. Likely a `struct` or `class` defining properties like username, display name, avatar URL, etc., corresponding to BlueSky’s user schema.
  * **C — Post/** *(Social post domain)*

    * **PostManager.swift:** Manages operations related to posts (also known as “skeets” in BlueSky). This may include creating a new post, deleting a post, fetching a specific post or thread, etc., using ATProtoKit.
    * **PostModel.swift:** Data model for a post. Defines properties such as content text, author, timestamp, and any metadata needed to render a post in the UI.
  * **D — Feed/** *(Main feed/timeline domain)*

    * **FeedManager.swift:** Handles fetching and updating the feed (timeline) data. It likely pulls the aggregated list of posts for the home feed and may support pagination or real-time updates.
    * **FeedModel.swift:** Data model for the feed or a feed item. It could represent a collection of PostModels or include info like feed last updated time. This helps pass feed data to views in a structured way.
  * **E — Trend/** *(Trending topics/posts domain)*

    * **TrendManager.swift:** Manages retrieval of trending content (popular posts or topics on BlueSky). It might fetch trending feeds or hashtags via the BlueSky API.
    * **TrendModel.swift:** Data model for a trending topic or trending posts. Likely contains properties to represent trending items (could be similar to FeedModel or something like a list of PostModels marked as trending).

* **App/4 — Components/** (Reusable UI components and utilities, often used across multiple screens)

  * **A — Buttons/** – *Button UI elements*

    * **ButtonComponent.swift:** A reusable SwiftUI **Button** style or view component used throughout the app for consistent button appearance. It might wrap a `Button` with custom styling (colors, corners) for standard buttons.
    * **CompactButtonComponent.swift:** A variation of the button component for more compact UI contexts. Perhaps used for smaller buttons or icon-only buttons with the same styling as ButtonComponent.
  * **B — TextFields/** – *Text input elements*

    * **InputFieldComponent.swift:** A SwiftUI view encapsulating a text field with custom styling. For example, used for login form fields or search bars, providing a consistent text input design (with icons, padding, etc.).
  * **E — Cells/** – *Composite views to display a single item (e.g., a post)*

    * **PostComponent.swift:** A SwiftUI view representing a single post cell in a list or feed. It likely composes a PostModel’s data (author, content, timestamp, etc.) into a styled view. Used by feed or profile pages to show individual posts.
  * **G — Lists/** – *Composite views for list structures*

    * **FeedComponent.swift:** A SwiftUI view that lays out a list of posts (perhaps using a `List` or `ScrollView`). It might aggregate multiple PostComponents to display an entire feed. This could be the UI for the Home feed or a generic list component.
  * **I — Navigation/** – *Navigation bars, headers, tab bars*

    * **HeaderComponent.swift:** A SwiftUI view for a screen header or navigation bar. Possibly includes a title and optional action buttons (e.g., for the top of a feed or profile screen).
    * **TabBarComponent.swift:** A SwiftUI view implementing a custom **Tab Bar** for the app. Since SwiftUI’s TabView could be used, this might be a customized tab bar UI with icons (Home, Search, Notifications, Profile). It handles switching between main sections of the app.
  * **K — Animations/** – *Animated backgrounds or splash screens*

    * **BackgroundComponent.swift:** A SwiftUI view that provides an animated or dynamic background. This could render a gradient animation or some moving background (possibly using the GradientBackground asset).
    * **SplashComponent.swift:** The splash screen view displayed when the app launches or during initialization. It might show the app logo (airplane and cloud) with a brief animation. This would be the SwiftUI alternative or companion to Launch.storyboard, potentially used once the app is running (for instance, to handle any loading tasks).
  * **L — Seperators/** (likely meant to be *Separators*) – *Divider or separator elements*

    * **SeperatorComponent.swift:** A custom separator view, probably a styled `Divider` (with certain color or padding). Might be used to separate sections in lists or between UI components in the app.
  * **M — Shared/** – *Shared utilities and constants*

    * **Constants.swift:** Defines constant values used across the app (for example, static strings, keys, or layout metrics). Centralizing constants here helps avoid magic numbers/strings scattered in code.
    * **Helpers.swift:** General utility functions and extensions that don’t belong to a specific model or view. For instance, date formatters, string utilities, or convenience functions used in multiple places.
    * **Haptics.swift:** Provides a simple interface to iOS haptic feedback. Likely wraps **UIFeedbackGenerator** or similar to trigger haptic vibrations on certain user actions (e.g., on button press or successful operations).
    * **Modifiers.swift:** Collection of SwiftUI **ViewModifiers** for common styling or behavior. For example, a modifier for standard shadow or corner radius that can be reused, or conditional modifiers for debugging visuals.

* **App/5 — Views/** (Primary app screens and view models)

  * **SkylinerApp.swift:** The main application entry point. This file contains the `@main` struct (e.g., `SkylinerApp: App`) which sets up the SwiftUI app lifecycle. It likely configures the window and root view (probably a `RouterView` or a Tab view) and sets up any global app environment objects (such as instances of managers as `@StateObject`).
  * **RouterView\.swift:** A container view responsible for determining which screen to show first. For example, `RouterView` might check if the user is authenticated (perhaps via `AppState`) and then present either the Authentication flow or the Main Tab view. It handles high-level navigation logic, such as switching the root view based on login state.
  * **Tabs/** – *Main application tab views (accessible after login)*

    * **HomeView\.swift:** The Home feed screen (one of the main tabs). It shows the global feed or personalized feed of posts. Likely uses `FeedComponent` internally to list posts and may integrate `FeedManager` to load data.
    * **SearchView\.swift:** The Search or Discover screen. Could allow searching for other users or posts. It might display trending topics or a search bar to query content. This is another main tab.
    * **NotificationsView\.swift:** The Notifications screen, listing user mentions, replies, or other notifications. It would display a list of notifications and possibly use icons like the cloud or airplane to represent BlueSky-specific alerts.
    * **ProfileView\.swift:** The user’s Profile screen (for the logged-in account). Displays profile details and the user’s posts, with options to edit profile or view follower/following lists. It likely uses `ProfileManager` to fetch the profile data and the user’s posts (possibly reusing PostComponents for the post list).
  * **Authentication/** – *Login/Signup flow views*

    * **AuthenticationView\.swift:** The login/sign-up screen UI. This view presents text fields (using InputFieldComponent) for username/password, and a sign-in button (using ButtonComponent). It interfaces with `AuthenticationViewModel` to perform the login action.
    * **AuthenticationViewModel.swift:** The view model (likely an `ObservableObject`) for the AuthenticationView. It holds form state (entered username/password), performs validation, and calls `AuthenticationManager` to execute the login. It updates published properties to reflect loading state or login errors for the view to display.
    * **AuthenticationExtension.swift:** An extension file providing additional helpers or SwiftUI view extensions for the authentication module. It might include modifiers or helper views specific to the AuthenticationView (for instance, form field styling or an extension to dismiss keyboard, etc.), or even an extension on some data model for convenience in the auth context.

* **Skyliner.xcodeproj/** (Xcode project bundle)
  *This directory contains configuration for the Xcode project. It’s generated by Xcode and generally not edited manually, but key parts are:*

  * **project.xcworkspace/contents.xcworkspacedata:** XML file that defines the workspace (which projects are part of it). For a single-app project, this just ensures the Skyliner project is in the workspace.
  * **xcshareddata/xcschemes/Skyliner.xcscheme:** Xcode scheme for building/running the app. This is shared, meaning it’s included in version control so any contributor sees the same run configuration. It defines which target to build, run configurations, etc.
  * **xcshareddata/swiftpm/Package.resolved:** Records the exact resolved versions of Swift Package Manager dependencies. This ensures consistent dependency versions (ATProtoKit 0.30.0, KeychainSwift 24.0.0, etc.) across machines. It’s updated when packages are added/updated.
  * **xcuserdata/rayanwaked.xcuserdatad/** – Developer-specific Xcode user data (in this case, user **rayanwaked** who last edited the project). This includes:

    * **xcschemes/xcschememanagement.plist:** Tracks which schemes are visible or hidden for that user.
    * **UserInterfaceState.xcuserstate:** A binary file storing the last UI state of Xcode (which files were open, cursor positions, window layouts). Not relevant to the project’s functionality – it’s just a snapshot of the IDE state.

* **SkylinerIcon/** (Design assets for app icon/logo)
  This folder contains raw design images used for creating the Skyliner app icon and related graphics. These are not part of the app bundle but serve as resources for developers/designers:

  * **Skyliner.icon/Assets/06-22-2025\_X-Design.png:** An image of a white fluffy **cloud** on a transparent background. This appears to be a concept or asset related to BlueSky’s theme (a cloud icon). It might have been used in designing the app’s icon or as a logo element (BlueSky’s motif is often a cloud).
  * **Skyliner.icon/Assets/Plane Design with Body Paint.png:** An image of an **airplane** (top-down view with blue and white coloring). This is likely the primary icon graphic for Skyliner (as seen in the embedded image above). It was used to create the app’s actual icon. The “body paint” refers to the blue accent coloring on the plane’s body.
  * **.DS\_Store:** A hidden file created by macOS Finder to store folder display metadata. It has no effect on the project and can be ignored or removed.

* **Hidden Files: .DS\_Store, .git/**

  * **.DS\_Store:** This file appears in the root (and in the SkylinerIcon folder). These are macOS system files that record folder view preferences (icon positions, etc.) in Finder. They are not used by the app and are safe to ignore or delete in a non-macOS context.
  * **.git/** – The Git repository data directory. It contains version control history for the project. Notable contents:

    * **config:** Git configuration for this repository.

    * **description:** (Typically used in bare repos; can be ignored for a normal repo).

    * **HEAD:** Reference to the current branch (e.g., `refs/heads/main`).

    * **objects/** and **pack/**: The Git object database storing all commits, blobs (file contents), etc., often in pack files for efficiency.

    * **refs/**: Pointers to commit references. In this project, you’ll see `refs/heads/main` (the main branch pointer) and `refs/remotes/origin/main` (tracking the origin’s main branch).

    * **logs/**: History of changes to branch heads (useful for `git reflog`). Contains logs for HEAD and each ref (e.g., commit history for `main`).

    * **hooks/**: Sample Git hook scripts (e.g., pre-commit, pre-push) provided by Git – none are active by default unless configured.

    * **info/**: Contains global exclude patterns (in `info/exclude`) which is like a local .gitignore.

  > **Note:** The `.git` folder is only relevant if you are working with the project’s Git repository. If you obtained the code via a zip download (as in this case), the presence of this folder indicates it was included in the archive, but it may not be needed unless you plan to use Git for version control on this project.

* **\_\_MACOSX/** (Zip archive artifact)
  If you see a folder named `__MACOSX` in the archive, note that this is an artifact of how macOS zips files. It contains **resource forks and metadata** for the files in the archive (with filenames like `._Filename`). For example, `__MACOSX/Skyliner/App/4 — Components/._ButtonComponent.swift` is a hidden file storing extended attributes for `ButtonComponent.swift`. These `__MACOSX` files are **not part of the actual project** and can be ignored or deleted after unzipping. They do not affect the iOS app’s code or functionality.

## Assets

The app’s visual assets are managed in **Assets.xcassets** (within **App/2 — Resources/**). Here’s a summary of the asset catalog contents and the role of each asset:

* **AppIcon.appiconset:** Contains the application’s icons in various resolutions. Skyliner’s icon features the airplane graphic with a blue/white color scheme. In this set:

  * *Skyliner Light.png* – The primary app icon image (1024×1024) for light mode or default appearance.
  * *Skyliner Dark.png* – An alternate app icon image used when the device is in Dark Mode (the asset catalog is configured to switch to this image for dark appearance).
  * *Plane.png* – An additional plane graphic used within the app icon set (marked with “tinted” appearance in the Contents.json). This is likely a template image of the airplane used for perhaps notification icon or as a separate layer in the icon. It might also be used elsewhere in the app’s UI for a consistent symbol.
  * *Contents.json* – The JSON configuration mapping the images to iOS icon roles (size, scale, idiom, and appearances).
* **AccentColor.colorset:** Defines the app’s global **accent color**. In SwiftUI, the accent color controls the tint for controls like buttons, toggles, etc., across the app. Skyliner likely defines a custom accent (possibly a shade of blue matching the BlueSky theme). The Contents.json in this set references the color value.
* **Images.xcassets/Images/** – Additional image assets used in the app’s UI:

  * **GradientBackground.imageset:** Contains images for a gradient background design. This set likely includes vector graphics (`Gradient Background.svg` and `Gradient Background 1.svg`) and rasterized images for specific devices (`iPad Mini 8.3.png`, `iPad Pro 12.9.png`). The gradient background is probably used in the **SplashComponent** or as a backdrop in certain views to give a sky-like gradient effect.
  * **SkylinerIcon.imageset:** Contains the **Plane.png** asset (with a corresponding Contents.json). This is an airplane icon graphic, presumably the same or similar image as used in the app icon, but provided here for use inside the app UI (for example, as a logo in the login screen or navigation bar).
  * **CloudIcon.imageset:** Contains **Cloud.png** (with Contents.json). This is the cloud graphic used in the app’s design (as seen in the SkylinerIcon folder). The cloud icon might be used within the app’s interface or illustrations, perhaps to represent the network or background elements (e.g., behind the airplane in the splash screen or as an icon for posting to the “sky”).

Developers can update these assets as needed by replacing the images in the asset catalog. If the **resource folder name or structure** is changed, remember to update the Xcode project’s asset references accordingly (as noted, the numbered folder naming is expected by the project).

## Development Notes

### Debug Logging Convention

To make debugging easier and log output more readable, Skyliner uses a unique convention: **each log/print statement is prefixed with an emoji** to indicate its source category. This way, when reading Xcode’s console output, you can quickly filter and identify logs by the emoji. The categories are:

* 🌸 **Views:** Logged from SwiftUI Views (UI layer).
  *Example:* `print("🌸 AuthenticationView: Sign in button pressed")` – Emitted when a user taps the sign-in button in the AuthenticationView.

* 🌺 **Components:** Logged from UI Components (reusable views or controls).
  *Example:* `print("🌺⛔️ Failed to create haptic engine")` – A component (here perhaps the Haptics helper) failed to initialize, indicated by the ⛔️ alongside the flower emoji.

* 🍄 **Managers/Functions:** Logged from manager classes or other functions (business logic layer).
  *Example:* `print("🍄 AuthenticationManager: Sign in function called")` when an authentication attempt begins.
  Additionally, the mushroom emoji is combined with **✅** or **⛔️** to denote success or failure outcomes in managers:
  – `print("🍄✅ AuthenticationManager: Sign in successful")` upon a successful login.
  – `print("🍄⛔️ AuthenticationManager: Sign in failed")` if credentials were incorrect or network failed.

* ☘️ **Models:** Logged from model objects or data layer.
  *Example:* `print("☘️ AuthenticationModel: User account model populated")` – indicating that a data model (like user profile or account) was successfully loaded or updated.

Using these prefixes, a developer can quickly scan logs: e.g., looking for all 🌸 entries to see user interaction events, or 🍄 to trace the flow in managers. This structured logging aids in debugging by providing context at a glance.

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

---

*Skyliner’s README is intended to provide both high-level guidance and low-level detail. By following this documentation, developers should be able to understand the project layout, set up the development environment, and adhere to the established patterns when contributing to Skyliner.*

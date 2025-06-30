# Skyliner ✈️

### **Skyliner** is a native iOS client for BlueSky, written in Swift and SwiftUI, utilizing [ATProtoKit](https://github.com/MasterJ93/ATProtoKit).
### The app's main focus is to achieve a high degree of interface and expercience refinement
### The code base should be minimalistic, easy to understand, simple to maintain, and fluid (e.g. refactoring a simple component should not result in a complex cascade of changes across various places in the codebase)

---

## Project Features
- Native iOS app written in Swift & SwiftUI
- Connects to BlueSky via the ATProtoKit
- Modern UI with scalable architecture
- Foundation for further customization and features

## Getting Started
### Prerequisites
- Xcode 26.0 or later
— Swift 6.0 or later
- iOS 26.0 or later

## Debugging Standards
### All print statements should include an identifier emoji at the beginning of the statmement
### This makes it easy to search, filter, and find logs, errors, bugs, etc, as well as increases the line height of the log statement itself
- 🌸 Views (e.g. print("🌸 AuthenticationView: Sign in button pressed"))
- 🌺 Components (e.g. print("🌺⛔️ Failed to create haptic engine"))
- 🍄 Managers/Functions (e.g. print("🍄 AuthenticationManager: Sign in function called"))
    - 🍄 Managers/Functions (e.g. print("🍄✅ AuthenticationManager: Sign in successful"))
    - 🍄 Managers/Functions (e.g. print("🍄⛔️ AuthenticationManager: Sign in failed"))
- ☘️ Models (e.g. print("☘️ AuthenticationModel: User account model populated"))

## File Structure
### For the sake of linear organization, each folder is labeled 1 through (X) follwed by an em dash and then the folder name
- Remember to update the project build settings if changing the resources file name
- Structure causes some rigitity, but the tradeoff is ease of search and resemeblence of logic flow
- Components and Views must have working previews

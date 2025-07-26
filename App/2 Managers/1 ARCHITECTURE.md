# Skyliner iOS App Architecture Documentation

## Overview

The app follows an **MVVM-C** (Model-View-ViewModel-Coordinator) pattern with the following key characteristics:

- **Centralized State Management** via `AppState`
- **Protocol-Based Interactions** for code reusability
- **Reactive Authentication** using AsyncStream
- **Clean API Abstraction** through managers
- **Consistent Data Models** across all features

## Core Components

### 1. AppState (Central Coordinator)

**File:** `AppState.swift`  
**Role:** Central state coordinator and dependency container

```swift
@MainActor @Observable
class AppState {
    var clientManager: ClientManager?
    let authManager = AuthManager()
    let userManager = UserManager()
    // ... other managers
}
```

**Responsibilities:**
- Manages global app state
- Distributes `ClientManager` to all managers when authentication succeeds
- Coordinates data loading through `DataCoordinator`
- Stores user session information

**Key Patterns:**
- **Dependency Injection**: Provides shared dependencies to all managers
- **Observer Pattern**: Listens to authentication state changes
- **Coordination**: Orchestrates app-wide state updates

### 2. Authentication System

#### AuthManager
**File:** `AuthManager.swift`  
**Role:** Handles authentication, session management, and keychain storage

**Key Features:**
- **Secure Storage**: Uses `KeychainSwift` and `AppleSecureKeychain`
- **Session Restoration**: Automatic session recovery on app launch
- **Reactive Updates**: AsyncStream for `ClientManager` distribution
- **Error Handling**: Comprehensive authentication error management

**Authentication Flow:**
```
App Launch → Keychain Check → Session Restore → ClientManager Creation → Distribution
```

#### ClientManager
**File:** `ClientManager.swift`  
**Role:** API client wrapper providing access to ATProtoKit

```swift
@MainActor @Observable
public final class ClientManager: Sendable {
    public let credentials: ATProtocolConfiguration
    public let account: ATProtoKit
    public let bluesky: ATProtoBluesky
}
```

**Responsibilities:**
- Wraps ATProtoKit for clean API access
- Manages protocol configuration
- Provides both general AT Protocol and Bluesky-specific APIs

### 3. Data Management Layer

#### PostModel
**File:** `PostModel.swift`  
**Role:** Unified post data management across all features

**Key Components:**
- **PostItem**: Simplified post representation for UI
- **PostState**: Interaction state (likes, reposts, replies)
- **PostViewProtocol**: Consistent interface for different post types

**Benefits:**
- Consistent post handling across home feed, search, and profiles
- Efficient data transformation from API responses to UI models
- Centralized post state management

#### Manager Pattern
All feature managers follow consistent patterns:

```swift
@MainActor @Observable
public final class FeatureManager {
    @ObservationIgnored var appState: AppState?
    var clientManager: ClientManager? { appState?.clientManager }
    
    // Feature-specific properties and methods
}
```

**Common Responsibilities:**
- API interaction through `ClientManager`
- Data transformation and caching
- Error handling and logging
- UI state management

### 4. Post Interaction System

#### Protocol-Based Design
**Files:** `PostInteractions.swift`

```swift
protocol PostInteractionCapable: AnyObject {
    var clientManager: ClientManager? { get }
}

protocol PostFinder {
    func findPost(by postID: String) -> (any PostViewProtocol)?
}
```

**Benefits:**
- **Code Reusability**: Same interaction logic across all managers
- **Consistency**: Uniform behavior for likes, reposts, sharing
- **Maintainability**: Single source of truth for interaction logic

**Supported Interactions:**
- Like/Unlike posts
- Repost/Unrepost
- Share posts
- Copy post links
- Open external links

### 5. Feature Managers

#### UserManager
**Purpose:** Current user profile and timeline management  
**Key Features:**
- Profile data loading and caching
- User timeline management
- Profile picture handling

#### PostManager
**Purpose:** Home feed and general post management  
**Key Features:**
- Home timeline loading with pagination
- Author feed management
- Raw feed caching for offline support

#### SearchManager
**Purpose:** Post search functionality  
**Key Features:**
- Real-time search with debouncing
- Pagination support
- Search result caching

#### ProfileManager
**Purpose:** Other user profile viewing  
**Key Features:**
- Dynamic user profile loading
- Separate profile feed management
- Profile-specific interactions

#### TrendsManager
**Purpose:** Trending topics and hashtags  
**Key Features:**
- Trend discovery
- Real-time trend updates

## Information Flow Patterns

### 1. Authentication Flow

```
User Input → AuthManager.authenticate() → ATProtocolConfiguration → 
ClientManager Creation → AsyncStream Emission → AppState Update → 
Manager Distribution → DataCoordinator.loadAllData()
```

### 2. Data Loading Flow

```
Manager Method Call → ClientManager API → ATProtoKit → 
Raw API Response → PostModel Processing → UI Update
```

### 3. User Interaction Flow

```
User Action → PostInteractionCapable Protocol → PostFinder.findPost() → 
API Call via ClientManager → State Update → UI Refresh
```

### 4. Error Handling Flow

```
API Call → Try/Catch → Error Logging → User Feedback → 
Graceful Degradation
```

## Design Principles

### 1. Separation of Concerns
- **Views**: Only handle UI and user interaction
- **Managers**: Handle business logic and API calls
- **Models**: Represent data structures
- **Protocols**: Define shared behaviors

### 2. Reactive Programming
- **@Observable**: SwiftUI's built-in reactivity
- **AsyncStream**: Reactive authentication state
- **Task-based**: Async/await for all API calls

### 3. Protocol-Oriented Design
- **PostInteractionCapable**: Shared interaction logic
- **PostViewProtocol**: Unified post interface
- **PostFinder**: Consistent post lookup

### 4. Error Resilience
- Comprehensive error handling in all managers
- Graceful degradation when APIs fail
- User feedback through haptic and visual cues

### 5. Performance Optimization
- **Pagination**: Efficient data loading
- **Caching**: Raw data preservation for offline support
- **Lazy Loading**: On-demand data fetching

## Best Practices Demonstrated

### ✅ Code Organization
- Clear file structure with logical grouping
- Consistent naming conventions
- Proper use of `//MARK:` comments for organization

### ✅ Memory Management
- `@ObservationIgnored` for non-reactive references
- Weak references where appropriate
- Proper async/await usage

### ✅ Security
- Keychain integration for sensitive data
- Secure session management
- Proper credential handling

### ✅ User Experience
- Loading states for all async operations
- Haptic feedback for user actions
- Smooth animations and transitions

### ✅ Maintainability
- Single responsibility principle
- Minimal code complexity
- Consistent error handling patterns

## Data Flow Examples

### Home Feed Loading
1. App launches → `AppState.init()`
2. Authentication succeeds → `ClientManager` created
3. `DataCoordinator.loadAllData()` called
4. `PostManager.loadPosts()` executes
5. API call through `ClientManager.account.getTimeline()`
6. Raw data stored and processed through `PostModel`
7. UI updates reactively via `@Observable`

### Post Interaction
1. User taps like button in UI
2. View calls manager's interaction method
3. Manager uses `PostInteractionCapable` protocol
4. `findPost()` locates the specific post
5. API call made through `ClientManager`
6. Post state updated locally
7. UI reflects changes immediately

### Profile Navigation
1. User taps on profile
2. New `ProfileManager` created with target user DID
3. `loadProfile()` called automatically
4. Profile and feed data loaded in parallel
5. UI displays loaded content
6. Supports independent interaction state

## Future Extensibility

The architecture supports easy extension through:

- **New Managers**: Follow established patterns for new features
- **Protocol Extensions**: Add new interaction types via protocols
- **API Updates**: `ClientManager` abstracts API changes
- **UI Components**: Managers are UI-agnostic for reusability

This architecture demonstrates modern iOS development best practices while maintaining simplicity and focusing on user experience.

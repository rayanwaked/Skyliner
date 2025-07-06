# AppState Data Flow and Architecture

## Overview
The `AppState` class serves as the central hub for managing application state and coordinating data flow between different managers and models. It follows a hierarchical pattern where the `ClientManager` acts as the foundation that enables all other managers to communicate with the AT Protocol.

## Core Components

### ClientManager
The `ClientManager` is the foundational component that provides AT Protocol connectivity:
- **Purpose**: Manages authentication and protocol communication
- **Components**:
  - `configuration`: ATProtocolConfiguration with server details and credentials
  - `protoClient`: Main client for AT Protocol APIs (authentication, sessions)
  - `blueskyClient`: Specialized client for Bluesky-specific operations

### AppState Architecture
The `AppState` uses a backing storage pattern with underscore-prefixed private variables and public computed properties.

## Data Flow

### 1. Initialization Flow
```
AppState.init() 
    ↓
Task: Listen for authenticationManager.clientManagerUpdates
    ↓
MainActor.run {
    self.clientManager = clientManager
    self.configuration = clientManager?.configuration
    updateManagers(with: clientManager)
}
```

### 2. Configuration Update Flow
```
configuration.didSet
    ↓
Task { @MainActor in
    updateUserDIDFromConfiguration()
    ↓
    Parallel data fetching:
    - postModel = await postManager.getFeed()
    - trendModel = await trendManager.fetchTrends()
    - feedModel = await feedManager.fetchSavedFeeds()
    - profileModel = await profileManager.fetchCurrentUserProfile()
    - notificationModel = await notificationManager.fetchNotifications()
}
```

### 3. Manager Update Flow
```
updateManagers(with: clientManager)
    ↓
Distribute clientManager to all managers:
- _postManager.clientManager = clientManager
- _trendManager.clientManager = clientManager
- _feedManager.clientManager = clientManager
- _profileManager.clientManager = clientManager
- _notificationManager.clientManager = clientManager
```

## Manager Hierarchy

### Primary Managers
- **AuthenticationManager**: Handles user authentication and session management
- **PostManager**: Manages posts and timeline data
- **TrendManager**: Handles trending content
- **FeedManager**: Manages saved feeds
- **ProfileManager**: Handles user profile data
- **NotificationManager**: Manages notifications

### Manager Dependencies
All managers (except AuthenticationManager) depend on `ClientManager` for AT Protocol communication:
```
ClientManager → Individual Managers → Data Models
```

## Data Models

### Model Storage Pattern
Each model uses the same backing storage pattern:
```swift
private var _postModel: [PostModel] = PostModel.placeholders
var postModel: [PostModel] {
    get { _postModel }
    set { _postModel = newValue }
}
```

### Model Types
- **PostModel**: Array of post data
- **TrendModel**: Array of trending content
- **FeedModel**: Array of saved feeds
- **ProfileModel**: Array of profile information
- **NotificationModel**: Array of notifications

## Key Patterns

### Backing Storage Pattern
```swift
// Private backing storage
private var _variableName: Type = defaultValue

// Public computed property
var variableName: Type {
    get { _variableName }
    set { _variableName = newValue }
}
```

### Async Data Coordination
The `configuration.didSet` ensures all data is fetched in coordination when the AT Protocol configuration changes, maintaining consistency across all managers.

### MainActor Integration
All UI-related updates are dispatched to the MainActor to ensure thread safety with SwiftUI's observation system.

## User Session Management

### UserDefaults Integration
```swift
private var userDIDKey: String { "userDID" }
var userDID: String? {
    UserDefaults.standard.string(forKey: userDIDKey)
}
```

### Session Updates
The `updateUserDIDFromConfiguration()` function extracts the user's DID from the client session and persists it to UserDefaults for future use.

## Benefits of This Architecture

1. **Centralized State Management**: All app state flows through AppState
2. **Dependency Injection**: ClientManager is injected into all managers
3. **Data Consistency**: Configuration changes trigger coordinated data updates
4. **Encapsulation**: Private backing storage protects internal state
5. **Async Safety**: MainActor ensures thread-safe UI updates
6. **Extensibility**: Easy to add new managers following the same pattern

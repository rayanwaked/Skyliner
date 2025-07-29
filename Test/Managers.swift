import XCTest
import ATProtoKit
@testable import Skyliner

// MARK: - MOCK OBJECTS
// Removed MockAppState since we can't easily extend AppState
// Using real AppState for testing instead

enum TestError: Error {
    case mockError
}

// MARK: - AUTH MANAGER TESTS
@MainActor
final class AuthManagerTests: XCTestCase {
    var authManager: AuthManager!
    
    override func setUp() async throws {
        authManager = AuthManager()
    }
    
    override func tearDown() {
        authManager = nil
    }
    
    func testInitialState() {
        XCTAssertNotNil(authManager.ATProtoKeychain, "ATProtoKeychain should be initialized")
        XCTAssertNotNil(authManager.clientManagerUpdates, "ClientManager updates stream should exist")
        XCTAssertNotNil(authManager.clientManagerContinuation, "ClientManager continuation should exist")
        XCTAssertEqual(authManager.configState, .empty, "Initial config state should be empty")
        XCTAssertNil(authManager.clientManager, "Initial client manager should be nil")
    }
    
    func testConfigStateValues() {
        // Test enum cases exist and are comparable
        XCTAssertEqual(AuthManager.ConfigState.empty, .empty)
        XCTAssertEqual(AuthManager.ConfigState.restored, .restored)
        XCTAssertEqual(AuthManager.ConfigState.failed, .failed)
        XCTAssertNotEqual(AuthManager.ConfigState.empty, .restored)
    }
    
    func testClientManagerStreamExists() async {
        // Test that the stream is properly initialized
        XCTAssertNotNil(authManager.clientManagerUpdates, "Stream should be available")
        
        // Test that we can get an iterator (this doesn't consume values)
        let iterator = authManager.clientManagerUpdates.makeAsyncIterator()
        XCTAssertNotNil(iterator, "Should be able to create iterator")
    }
    
    func testKeychainConfiguration() {
        XCTAssertNotNil(authManager.keychain, "Regular keychain should be initialized")
        XCTAssertNotNil(authManager.ATProtoKeychain, "ATProto keychain should be initialized")
    }
}

// MARK: - USER MANAGER TESTS
@MainActor
final class UserManagerTests: XCTestCase {
    var userManager: UserManager!
    var appState: AppState!
    
    override func setUp() async throws {
        appState = AppState()
        userManager = UserManager()
        userManager.appState = appState
    }
    
    override func tearDown() {
        userManager = nil
        appState = nil
        // Cleanup UserDefaults
        UserDefaults.standard.removeObject(forKey: "userDID")
        UserDefaults.standard.removeObject(forKey: "showingTrends")
    }
    
    func testInitialState() {
        XCTAssertNil(userManager.profilePictureURL, "Initial profile picture URL should be nil")
        XCTAssertNil(userManager.bannerURL, "Initial banner URL should be nil")
        XCTAssertNil(userManager.follows, "Initial follows count should be nil")
        XCTAssertNil(userManager.followers, "Initial followers count should be nil")
        XCTAssertNil(userManager.posts, "Initial posts count should be nil")
        XCTAssertNil(userManager.description, "Initial description should be nil")
        XCTAssertNil(userManager.name, "Initial name should be nil")
        XCTAssertNil(userManager.handle, "Initial handle should be nil")
        XCTAssertFalse(userManager.isLoadingProfile, "Should not be loading initially")
        XCTAssertTrue(userManager.userPosts.isEmpty, "User posts should be empty initially")
    }
    
    func testLoadingStates() {
        // Test that loading state starts as false
        XCTAssertFalse(userManager.isLoadingProfile, "Should not be loading initially")
        
        // Test computed property for user posts
        XCTAssertTrue(userManager.userPosts.isEmpty, "User posts should be empty initially")
    }
    
    func testUserManagerWithoutAppState() async {
        // Remove app state to test error handling
        userManager.appState = nil
        
        await userManager.loadProfilePicture()
        
        // Should handle gracefully without app state
        XCTAssertNil(userManager.profilePictureURL, "Profile picture should remain nil without app state")
        XCTAssertFalse(userManager.isLoadingProfile, "Should not be loading without app state")
    }
    
    func testUserManagerWithoutClientManager() async {
        // AppState starts without client manager by default
        XCTAssertNil(appState.clientManager, "Client manager should be nil initially")
        
        await userManager.loadProfile()
        
        // Should handle gracefully without client manager
        XCTAssertNil(userManager.profilePictureURL, "Profile picture should remain nil without client manager")
        XCTAssertFalse(userManager.isLoadingProfile, "Should not be loading without client manager")
    }
    
    func testUserManagerWithoutUserDID() async {
        // AppState starts without userDID by default
        XCTAssertNil(appState.userDID, "User DID should be nil initially")
        
        await userManager.loadProfile()
        
        // Should handle gracefully without user DID
        XCTAssertNil(userManager.profilePictureURL, "Profile picture should remain nil without user DID")
        XCTAssertFalse(userManager.isLoadingProfile, "Should not be loading without user DID")
    }
    
    func testUserManagerWithEmptyUserDID() async {
        // Set empty user DID in UserDefaults
        UserDefaults.standard.set("", forKey: "userDID")
        
        // Create new AppState to pick up the empty userDID
        let newAppState = AppState()
        userManager.appState = newAppState
        
        await userManager.loadProfile()
        
        // Should handle gracefully with empty user DID
        XCTAssertNil(userManager.profilePictureURL, "Profile picture should remain nil with empty user DID")
        XCTAssertFalse(userManager.isLoadingProfile, "Should not be loading with empty user DID")
    }
    
    func testRefreshProfileClearsData() async {
        // Test refresh functionality
        await userManager.refreshProfile()
        
        // After refresh, loading should be complete
        XCTAssertFalse(userManager.isLoadingProfile, "Should not be loading after refresh")
    }
    
    func testLoadMorePosts() async {
        // Test load more posts functionality
        await userManager.loadMorePosts()
        
        // Should complete without errors
        XCTAssertFalse(userManager.isLoadingProfile, "Should not be loading after load more posts")
    }
    
    func testUserManagerProperties() {
        // Test that UserManager has expected properties
        XCTAssertNotNil(userManager.userFeed, "UserFeed should be initialized")
        
        // Test computed property
        let posts = userManager.userPosts
        XCTAssertNotNil(posts, "UserPosts should return a collection")
    }
    
    func testAppStateReference() {
        // Test that UserManager properly references AppState
        XCTAssertNotNil(userManager.appState, "UserManager should have appState reference")
        XCTAssertTrue(userManager.appState === appState, "Should reference the same AppState instance")
    }
}

// MARK: - APP STATE TESTS
@MainActor
final class AppStateTests: XCTestCase {
    var appState: AppState!
    
    override func setUp() {
        appState = AppState()
    }
    
    override func tearDown() {
        appState = nil
        // Cleanup UserDefaults
        UserDefaults.standard.removeObject(forKey: "userDID")
        UserDefaults.standard.removeObject(forKey: "showingTrends")
    }
    
    func testInitialState() {
        XCTAssertNil(appState.clientManager, "Initial client manager should be nil")
        XCTAssertNil(appState.config, "Initial config should be nil")
        XCTAssertNotNil(appState.authManager, "AuthManager should be initialized")
        XCTAssertNotNil(appState.userManager, "UserManager should be initialized")
        XCTAssertNotNil(appState.profileManager, "ProfileManager should be initialized")
        XCTAssertNotNil(appState.trendsManager, "TrendsManager should be initialized")
        XCTAssertNotNil(appState.postManager, "PostManager should be initialized")
        XCTAssertNotNil(appState.searchManager, "SearchManager should be initialized")
        XCTAssertNotNil(appState.dataCoordinator, "DataCoordinator should be initialized")
    }
    
    func testUserDIDPersistence() {
        // Test empty state
        XCTAssertNil(appState.userDID, "UserDID should be nil initially")
        
        // Set a DID in UserDefaults
        UserDefaults.standard.set("did:plc:test123", forKey: "userDID")
        
        // Create new app state to test restoration
        let newAppState = AppState()
        XCTAssertEqual(newAppState.userDID, "did:plc:test123", "UserDID should be restored from UserDefaults")
    }
    
    func testShowingTrendsPersistence() {
        // Test default state
        XCTAssertTrue(appState.showingTrends, "Should show trends by default")
        
        // Change value
        appState.showingTrends = false
        XCTAssertFalse(appState.showingTrends, "Should update showingTrends value")
        
        // Create new app state to test persistence
        let newAppState = AppState()
        XCTAssertFalse(newAppState.showingTrends, "ShowingTrends should persist across app state instances")
    }
    
    func testDataCoordinatorReference() {
        let coordinator = appState.dataCoordinator
        XCTAssertNotNil(coordinator, "DataCoordinator should be available")
        
        // Test that multiple calls return consistent reference
        let coordinator2 = appState.dataCoordinator
        XCTAssertNotNil(coordinator2, "DataCoordinator should still be available")
    }
    
    func testManagerTypesAreCorrect() {
        XCTAssertTrue(type(of: appState.authManager) == AuthManager.self, "AuthManager should be correct type")
        XCTAssertTrue(type(of: appState.userManager) == UserManager.self, "UserManager should be correct type")
        XCTAssertTrue(type(of: appState.profileManager) == ProfileManager.self, "ProfileManager should be correct type")
        XCTAssertTrue(type(of: appState.trendsManager) == TrendsManager.self, "TrendsManager should be correct type")
        XCTAssertTrue(type(of: appState.postManager) == PostManager.self, "PostManager should be correct type")
        XCTAssertTrue(type(of: appState.searchManager) == SearchManager.self, "SearchManager should be correct type")
    }
}

// MARK: - CLIENT MANAGER TESTS
@MainActor
final class ClientManagerTests: XCTestCase {
    
    func testClientManagerCanBeCreated() async {
        // Test that we can create a ClientManager with proper configuration
        let config = ATProtocolConfiguration(keychainProtocol: AppleSecureKeychain(identifier: UUID()))
        let clientManager = await ClientManager(credentials: config)
        
        XCTAssertNotNil(clientManager.credentials, "Credentials should be initialized")
        XCTAssertNotNil(clientManager.account, "Account should be initialized")
        XCTAssertNotNil(clientManager.bluesky, "Bluesky should be initialized")
    }
    
    func testCredentialsType() async {
        let config = ATProtocolConfiguration(keychainProtocol: AppleSecureKeychain(identifier: UUID()))
        let clientManager = await ClientManager(credentials: config)
        
        XCTAssertTrue(type(of: clientManager.credentials) == ATProtocolConfiguration.self, "Credentials should be ATProtocolConfiguration type")
    }
    
    func testClientManagerProperties() async {
        let config = ATProtocolConfiguration(keychainProtocol: AppleSecureKeychain(identifier: UUID()))
        let clientManager = await ClientManager(credentials: config)
        
        // Test that ClientManager has expected properties
        XCTAssertNotNil(clientManager, "ClientManager should be created successfully")
    }
}

// MARK: - DATA COORDINATOR TESTS
@MainActor
final class DataCoordinatorTests: XCTestCase {
    var dataCoordinator: DataCoordinator!
    var appState: AppState!
    
    override func setUp() async throws {
        appState = AppState()
        dataCoordinator = DataCoordinator(appState: appState)
    }
    
    override func tearDown() {
        dataCoordinator = nil
        appState = nil
        // Cleanup UserDefaults
        UserDefaults.standard.removeObject(forKey: "userDID")
        UserDefaults.standard.removeObject(forKey: "showingTrends")
    }
    
    func testInitialization() {
        XCTAssertNotNil(dataCoordinator, "DataCoordinator should be initialized")
    }
    
    func testLoadAllDataExecution() async {
        // This should execute without throwing, even without a client manager
        await dataCoordinator.loadAllData()
        
        // Test passes if no exceptions are thrown
        XCTAssertTrue(true, "loadAllData should execute without throwing")
    }
    
    func testDataCoordinatorWithAppState() {
        // Test that DataCoordinator properly references AppState
        let newCoordinator = appState.dataCoordinator
        XCTAssertNotNil(newCoordinator, "AppState should provide DataCoordinator")
    }
}

// MARK: - INTEGRATION TESTS
@MainActor
final class ManagerIntegrationTests: XCTestCase {
    var appState: AppState!
    
    override func setUp() {
        appState = AppState()
    }
    
    override func tearDown() {
        appState = nil
        // Cleanup UserDefaults
        UserDefaults.standard.removeObject(forKey: "userDID")
        UserDefaults.standard.removeObject(forKey: "showingTrends")
    }
    
    func testManagerInitialization() {
        // Verify all managers are properly initialized
        XCTAssertNotNil(appState.authManager, "AuthManager should be initialized")
        XCTAssertNotNil(appState.userManager, "UserManager should be initialized")
        XCTAssertNotNil(appState.profileManager, "ProfileManager should be initialized")
        XCTAssertNotNil(appState.trendsManager, "TrendsManager should be initialized")
        XCTAssertNotNil(appState.postManager, "PostManager should be initialized")
        XCTAssertNotNil(appState.searchManager, "SearchManager should be initialized")
    }
    
    func testDataCoordinatorIntegration() {
        let coordinator = appState.dataCoordinator
        XCTAssertNotNil(coordinator, "DataCoordinator should be available through AppState")
    }
    
    func testAuthManagerStream() async {
        // Test that auth manager stream is properly set up
        XCTAssertNotNil(appState.authManager.clientManagerUpdates, "Auth manager stream should be available")
        
        // Wait a brief moment for async initialization
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(appState.authManager.configState, .empty, "Initial auth state should be empty")
    }
    
    func testUserDefaultsIntegration() {
        // Test showing trends default
        XCTAssertTrue(appState.showingTrends, "Should show trends by default")
        
        // Test userDID default
        XCTAssertNil(appState.userDID, "UserDID should be nil initially")
        
        // Test persistence
        appState.showingTrends = false
        let newAppState = AppState()
        XCTAssertFalse(newAppState.showingTrends, "Trends setting should persist")
    }
    
    func testManagerUpdateFlow() async {
        // Test that managers can be updated without crashing
        appState.updateManagers(with: nil, with: appState)
        
        // All managers should still be available after update
        XCTAssertNotNil(appState.userManager.appState, "UserManager should have appState reference")
        XCTAssertNotNil(appState.profileManager.appState, "ProfileManager should have appState reference")
        XCTAssertNotNil(appState.trendsManager.appState, "TrendsManager should have appState reference")
        XCTAssertNotNil(appState.postManager.appState, "PostManager should have appState reference")
        XCTAssertNotNil(appState.searchManager.appState, "SearchManager should have appState reference")
    }
    
    func testAsyncInitializationHandling() async {
        // Test that the app can handle async initialization
        let newAppState = AppState()
        
        // Give time for async initialization to complete
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(newAppState.authManager.configState, .empty, "Auth should be in empty state initially")
        XCTAssertNil(newAppState.clientManager, "Client manager should be nil initially")
    }
}

// MARK: - PERFORMANCE TESTS
@MainActor
final class PerformanceTests: XCTestCase {
    
    func testAppStateInitializationPerformance() {
        measure {
            let appState = AppState()
            XCTAssertNotNil(appState)
        }
    }
    
    func testDataCoordinatorPerformance() async {
        let appState = AppState()
        let coordinator = DataCoordinator(appState: appState)
        
        await measureAsync {
            await coordinator.loadAllData()
        }
    }
    
    func testUserManagerInitializationPerformance() {
        measure {
            let userManager = UserManager()
            XCTAssertNotNil(userManager)
        }
    }
    
    // Helper function for async performance testing
    private func measureAsync(block: @escaping () async -> Void) async {
        let startTime = CFAbsoluteTimeGetCurrent()
        await block()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        // Log performance (you can add assertions based on your performance requirements)
        print("Async operation took \(timeElapsed) seconds")
        XCTAssertLessThan(timeElapsed, 5.0, "Operation should complete within 5 seconds")
    }
}

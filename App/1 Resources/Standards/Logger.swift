//
//  Logger.swift
//  Skyliner
//
//  Created by Rayan Waked on 3/11/26.
//

import Foundation
import os.log

// MARK: - APP LOGGER
enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.skyliner"
    
    // MARK: - CATEGORIES
    static let auth = Logger(subsystem: subsystem, category: "Auth")
    static let network = Logger(subsystem: subsystem, category: "Network")
    static let posts = Logger(subsystem: subsystem, category: "Posts")
    static let notifications = Logger(subsystem: subsystem, category: "Notifications")
    static let search = Logger(subsystem: subsystem, category: "Search")
    static let profile = Logger(subsystem: subsystem, category: "Profile")
    static let thread = Logger(subsystem: subsystem, category: "Thread")
    static let trends = Logger(subsystem: subsystem, category: "Trends")
    static let ui = Logger(subsystem: subsystem, category: "UI")
}

// MARK: - APP ERROR
enum AppError: LocalizedError {
    case network(underlying: Error)
    case parsing(message: String)
    case authentication(message: String)
    case postInteraction(action: String, underlying: Error?)
    case missingData(field: String)
    case unknown(underlying: Error)
    
    var errorDescription: String? {
        switch self {
        case .network(let error):
            return "Network error: \(error.localizedDescription)"
        case .parsing(let message):
            return "Failed to parse: \(message)"
        case .authentication(let message):
            return "Authentication error: \(message)"
        case .postInteraction(let action, let error):
            if let error {
                return "Failed to \(action): \(error.localizedDescription)"
            }
            return "Failed to \(action)"
        case .missingData(let field):
            return "Missing required data: \(field)"
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
    
    var userFacingMessage: String {
        switch self {
        case .network:
            return "Unable to connect. Please check your internet connection."
        case .parsing:
            return "Unable to load content. Please try again."
        case .authentication:
            return "Authentication failed. Please sign in again."
        case .postInteraction(let action, _):
            return "Unable to \(action). Please try again."
        case .missingData:
            return "Some data is missing. Please try again."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}

// MARK: - OPERATION RESULT
enum OperationResult<T> {
    case success(T)
    case failure(AppError)
    
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
    
    var value: T? {
        if case .success(let value) = self { return value }
        return nil
    }
    
    var error: AppError? {
        if case .failure(let error) = self { return error }
        return nil
    }
}

// MARK: - MANAGER BASE PROTOCOL
@MainActor
protocol ManagedByAppState: AnyObject {
    var appState: AppState? { get set }
    var clientManager: ClientManager? { get }
}

extension ManagedByAppState {
    var clientManager: ClientManager? { appState?.clientManager }
}

// MARK: - OPERATION EXECUTOR
@MainActor
protocol OperationExecutor: ManagedByAppState {
    var logger: Logger { get }
}

extension OperationExecutor {
    func execute<T>(
        _ operationName: String,
        operation: () async throws -> T
    ) async -> OperationResult<T> {
        do {
            let result = try await operation()
            logger.info("\(operationName) completed successfully")
            return .success(result)
        } catch {
            logger.error("Failed to \(operationName): \(error.localizedDescription)")
            return .failure(.network(underlying: error))
        }
    }
    
    func executeVoid(
        _ operationName: String,
        operation: () async throws -> Void
    ) async -> Bool {
        let result: OperationResult<Void> = await execute(operationName, operation: operation)
        return result.isSuccess
    }
}

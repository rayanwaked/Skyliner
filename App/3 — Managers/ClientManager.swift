//
//  ClientManager.swift
//  Skyliner
//
//  Created by Rayan Waked on 6/30/25.
//

// MARK: - Imports
@preconcurrency import ATProtoKit
import SwiftUI

// MARK: - Client Manager
@Observable
public final class ClientManager: Sendable {
  public let configuration: ATProtocolConfiguration
  public let protoClient: ATProtoKit
  public let blueskyClient: ATProtoBluesky

  public init(configuration: ATProtocolConfiguration) async {
    self.configuration = configuration
    self.protoClient = await ATProtoKit(sessionConfiguration: configuration)
    self.blueskyClient = ATProtoBluesky(atProtoKitInstance: protoClient)
  }
}

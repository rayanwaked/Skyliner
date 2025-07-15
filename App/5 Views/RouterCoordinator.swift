//
//  RouterCoordinator.swift
//  Skyliner
//
//  Created by Rayan Waked on 7/14/25.
//

import SwiftUI

@Observable
final class RouterCoordinator {
    // MARK: - PROPERTIES
    var isLoaded: Bool = false
    var selectedTab: Tabs = .home
    var showingCreate: Bool = false
    var exploreSearch: String = ""
    
    // MARK: - METHODS
    func selectTab(_ tab: Tabs) {
        selectedTab = tab
    }
    
    func toggleCreate() {
        showingCreate.toggle()
    }
    
    func clearExploreSearch() {
        exploreSearch = ""
    }
}

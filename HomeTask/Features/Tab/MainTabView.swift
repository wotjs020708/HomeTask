//
//  MainTabView.swift
//  HomeTask
//
//  Created by 어재선 on 4/7/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTab = .chore
    @State private var chorePath = NavigationPath()
    @State private var shoppingPath = NavigationPath()

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabContent(for: tab)
                    .tabItem { Label(tab.title, systemImage: tab.icon) }
                    .tag(tab)
            }
        }
    }

    @ViewBuilder
    private func tabContent(for tab: AppTab) -> some View {
        switch tab {
        case .chore:
            NavigationStack(path: $chorePath) {
                ChoreView()
            }
        case .shopping:
            NavigationStack(path: $shoppingPath) {
                ShoppingView()
            }
        case .settings:
            NavigationStack {
                SettingsView()
            }
        }
    }
}

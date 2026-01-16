//
//  MainTabView.swift
//  Moments
//
//  Created by han han on 2025/8/24.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            // 首页 - 展示所有物品
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label(
                    NSLocalizedString("tab_items", value: "物品", comment: ""),
                    systemImage: "rectangle.stack.fill"
                )
            }
            .tag(0)
            
            // 生活瞬间页面
            NavigationStack {
                MomentsView()
            }
            .tabItem {
                Label(
                    NSLocalizedString("tab_moments", value: "瞬间", comment: ""),
                    systemImage: "heart.text.square.fill"
                )
            }
            .tag(1)
            
            // 设置页面
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label(
                    NSLocalizedString("tab_settings", value: "设置", comment: ""),
                    systemImage: "gear"
                )
            }
            .tag(2)
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Baby.self, Moment.self], inMemory: true)
}

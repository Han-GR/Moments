//
//  MainTabView.swift
//  AiBaBy
//
//  Created by han han on 2025/8/24.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            // 首页 - 展示所有阿贝贝
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("首页", systemImage: "house.fill")
            }
            .tag(0)
            
            // 生活瞬间页面
            NavigationStack {
                MomentsView()
            }
            .tabItem {
                Label("瞬间", systemImage: "heart.text.square.fill")
            }
            .tag(1)
            
            // 设置页面
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("设置", systemImage: "gear")
            }
            .tag(2)
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Baby.self, Moment.self], inMemory: true)
}

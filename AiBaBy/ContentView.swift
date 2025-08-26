//
//  ContentView.swift
//  AiBaBy
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var babies: [Baby]

    var body: some View {
        NavigationStack {
            if babies.isEmpty {
                ContentUnavailableView("欢迎使用AiBaby", systemImage: "bubbles.and.sparkles", description: Text("点击添加按钮开始记录您的阿贝贝"))
                    .background(Color(.systemGroupedBackground))
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: BabyEditView()) {
                                Label("添加阿贝贝", systemImage: "plus")
                            }
                        }
                    }
                    .navigationTitle("AiBaby")
            } else {
                HomeView()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Baby.self, Moment.self], inMemory: true)
}

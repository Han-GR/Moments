//
//  SettingsView.swift
//  AiBaBy
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var babies: [Baby]
    @Query private var moments: [Moment]
    
    @State private var showingDeleteAllConfirmation = false
    @State private var showingAbout = false
    @State private var appVersion = ""
    
    var body: some View {
        List {
            Section("应用信息") {
                HStack {
                    Image(systemName: "heart.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.pink)
                        .padding(10)
                        .background(Color.pink.opacity(0.2))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text("爱贝贝")
                            .font(.headline)
                        Text("版本 \(appVersion)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
                
                Button(action: {
                    showingAbout = true
                }) {
                    Label("关于爱贝贝", systemImage: "info.circle")
                }
            }
            
            Section("统计") {
                HStack {
                    Label("阿贝贝数量", systemImage: "person.2.fill")
                    Spacer()
                    Text("\(babies.count)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label("生活趣事", systemImage: "heart.text.square.fill")
                    Spacer()
                    Text("\(moments.count)")
                        .foregroundColor(.secondary)
                }
            }
            
            Section("数据管理") {
                Button(role: .destructive, action: {
                    showingDeleteAllConfirmation = true
                }) {
                    Label("清除所有数据", systemImage: "trash")
                }
            }
        }
        .navigationTitle("设置")
        .onAppear {
            // 获取应用版本
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                appVersion = version
            } else {
                appVersion = "1.0"
            }
        }
        .alert("确认删除", isPresented: $showingDeleteAllConfirmation) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text("确定要删除所有阿贝贝和生活趣事数据吗？此操作无法撤销。")
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
    
    private func deleteAllData() {
        // 先删除所有趣事
        for moment in moments {
            modelContext.delete(moment)
        }
        
        // 再删除所有阿贝贝
        for baby in babies {
            modelContext.delete(baby)
        }
        
        // 尝试保存更改
        do {
            try modelContext.save()
        } catch {
            print("删除数据时出错: \(error)")
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "heart.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.pink)
                    .padding(20)
                    .background(Color.pink.opacity(0.2))
                    .clipShape(Circle())
                
                Text("爱贝贝")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("记录阿贝贝的美好时光")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                    .frame(height: 30)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("爱贝贝是一款专为记录和管理您的阿贝贝而设计的应用。无论是宠物、玩偶还是其他珍贵的物品，都可以在这里记录它们的成长和生活点滴。")
                    
                    Text("功能特点：")
                        .fontWeight(.bold)
                        .padding(.top, 10)
                    
                    FeatureRow(icon: "camera.fill", text: "拍照并上传阿贝贝的照片")
                    FeatureRow(icon: "pencil", text: "编辑阿贝贝的基本信息")
                    FeatureRow(icon: "heart.text.square.fill", text: "记录阿贝贝的生活趣事")
                    FeatureRow(icon: "house.fill", text: "在主页查看所有阿贝贝")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
                
                Text("© 2025 爱贝贝团队")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle("关于爱贝贝")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 25, height: 25)
            
            Text(text)
                .font(.body)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .modelContainer(for: [Baby.self, Moment.self], inMemory: true)
    }
}
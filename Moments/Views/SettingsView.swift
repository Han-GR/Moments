//
//  SettingsView.swift
//  每事每刻
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var babies: [Baby]
    @Query private var moments: [Moment]
    @Query private var groups: [Group]
    @AppStorage("isWipingData") private var isWipingData = false
    
    @State private var showingDeleteAllConfirmation = false
    @State private var showingAbout = false
    @State private var showingGroupManagement = false
    @State private var appVersion = ""
    
    var body: some View {
        List {
            Section("应用信息") {
                HStack {
                    Image(systemName: "bubbles.and.sparkles")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .padding(10)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text("每事每刻")
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
                    Label("关于Moments", systemImage: "info.circle")
                }
            }
            
            Section("统计") {
                HStack {
                    Label("物品数量", systemImage: "person.2.fill")
                    Spacer()
                    Text("\(babies.count)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label("生活瞬间", systemImage: "heart.text.square.fill")
                    Spacer()
                    Text("\(moments.count)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label("分组数量", systemImage: "folder.fill")
                    Spacer()
                    Text("\(groups.count)")
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
            Text("确定要删除所有物品和生活瞬间数据吗？此操作无法撤销。")
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
        .sheet(isPresented: $showingGroupManagement) {
            GroupManagementView()
        }
    }
    
    private func deleteAllData() {
        isWipingData = true
        
        // 创建快照，避免在迭代过程中 Query 动态变化导致的访问问题
        let momentsToDelete = Array(moments)
        let babiesToDelete = Array(babies)
        let groupsToDelete = Array(groups)
        
        // 先删除所有瞬间
        for moment in momentsToDelete {
            modelContext.delete(moment)
        }
        
        // 再删除所有物品
        for baby in babiesToDelete {
            modelContext.delete(baby)
        }

        // 最后删除所有分组
        for group in groupsToDelete {
            modelContext.delete(group)
        }
        
        // 尝试保存更改
        do {
            try modelContext.save()
        } catch {
                // 删除失败，静默处理
            }
        
        // 清空本地所有媒体文件（原图与缩略图）
        MediaStore.deleteAllImages()
        
        // 略微延迟，等待视图响应数据变化，避免其他 Tab 在删除瞬间读取已删除对象属性
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isWipingData = false
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "bubbles.and.sparkles")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .padding(20)
                    .clipShape(Circle())
                
                Text("每事每刻")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("记录物品的美好时光")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                    .frame(height: 30)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("每事每刻是一款专为记录和管理您的物品而设计的应用。您可以在这里记录与您有关的任何事物,不要错过任何瞬间。")
                    
                    Text("功能特点：")
                        .fontWeight(.bold)
                        .padding(.top, 10)
                    
                    FeatureRow(icon: "camera.fill", text: "拍照并上传物品的照片")
                    FeatureRow(icon: "pencil", text: "编辑物品的基本信息")
                    FeatureRow(icon: "heart.text.square.fill", text: "记录物品的生活瞬间")
                    FeatureRow(icon: "house.fill", text: "在主页查看所有物品")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
                
                Text("© 2025 Han-GR")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle("关于每事每刻")
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
            .modelContainer(for: [Baby.self, Moment.self, Group.self], inMemory: true)
    }
}

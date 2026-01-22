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
            Section(
                NSLocalizedString("section_app_info", value: "应用信息", comment: "")
            ) {
                Button(action: {
                    showingAbout = true
                }) {
                    HStack {
                        Image(systemName: "bubbles.and.sparkles")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .padding(10)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(
                                NSLocalizedString("app_name_cn", value: "每事每刻", comment: "")
                            )
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
            
            Section(
                NSLocalizedString("section_statistics", value: "统计", comment: "")
            ) {
                HStack {
                    Label(
                        NSLocalizedString("label_items_count", value: "物品数量", comment: ""),
                        systemImage: "person.2.fill"
                    )
                    Spacer()
                    Text("\(babies.count)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label(
                        NSLocalizedString("label_moments_count", value: "生活瞬间", comment: ""),
                        systemImage: "heart.text.square.fill"
                    )
                    Spacer()
                    Text("\(moments.count)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label(
                        NSLocalizedString("label_groups_count", value: "分组数量", comment: ""),
                        systemImage: "folder.fill"
                    )
                    Spacer()
                    Text("\(groups.count)")
                        .foregroundColor(.secondary)
                }
            }            
            Section(
                NSLocalizedString("section_data_management", value: "数据管理", comment: "")
            ) {
                Button(role: .destructive, action: {
                    showingDeleteAllConfirmation = true
                }) {
                    Label(
                        NSLocalizedString("action_clear_all_data", value: "清除所有数据", comment: ""),
                        systemImage: "trash"
                    )
                }
            }
        }
        .onAppear {
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                appVersion = version
            } else {
                appVersion = "1.0"
            }
        }
        .alert(
            NSLocalizedString("title_confirm_delete", value: "确认删除", comment: ""),
            isPresented: $showingDeleteAllConfirmation
        ) {
            Button(
                NSLocalizedString("action_cancel", value: "取消", comment: ""),
                role: .cancel
            ) { }
            Button(
                NSLocalizedString("action_delete", value: "删除", comment: ""),
                role: .destructive
            ) {
                deleteAllData()
            }
        } message: {
            Text(
                NSLocalizedString(
                    "confirm_delete_all_message",
                    value: "确定要删除所有物品和生活瞬间数据吗？此操作无法撤销。",
                    comment: ""
                )
            )
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
        // 直接按模型类型暴力删除（不加载对象，避免 UI 访问已删除对象属性）
        do {
            try modelContext.delete(model: MomentMedia.self)
            try modelContext.delete(model: Moment.self)
            try modelContext.delete(model: Baby.self)
            try modelContext.delete(model: Group.self)
            try modelContext.save()
        } catch {
                // 删除失败，静默处理
            }
        
        // 清空本地所有媒体文件（原图与缩略图）
        MediaStore.deleteAllImages()
        MediaStore.deleteAllVideos()
        
        // 短暂延迟后恢复 UI
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isWipingData = false
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var appVersion = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Image(systemName: "bubbles.and.sparkles")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .padding(20)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(Circle())
                        
                        VStack(spacing: 8) {
                            Text(
                                NSLocalizedString("app_name_cn", value: "每事每刻", comment: "")
                            )
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text(
                                NSLocalizedString("about_tagline", value: "记录物品的美好时光", comment: "")
                            )
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            if !appVersion.isEmpty {
                                Text(
                                    String(
                                        format: NSLocalizedString(
                                            "version_format",
                                            value: "版本 %@",
                                            comment: ""
                                        ),
                                        appVersion
                                    )
                                )
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text(
                                NSLocalizedString(
                                    "about_description",
                                    value: "每事每刻是一款专为记录和管理您的物品而设计的应用。您可以在这里记录与您有关的任何事物,不要错过任何瞬间。",
                                    comment: ""
                                )
                            )
                            
                            Text(
                                NSLocalizedString("about_features_title", value: "功能特点：", comment: "")
                            )
                                .fontWeight(.bold)
                                .padding(.top, 4)
                            
                            FeatureRow(
                                icon: "camera.fill",
                                text: NSLocalizedString(
                                    "about_feature_capture_photos",
                                    value: "拍照并上传物品的照片",
                                    comment: ""
                                )
                            )
                            FeatureRow(
                                icon: "pencil",
                                text: NSLocalizedString(
                                    "about_feature_edit_info",
                                    value: "编辑物品的基本信息",
                                    comment: ""
                                )
                            )
                            FeatureRow(
                                icon: "heart.text.square.fill",
                                text: NSLocalizedString(
                                    "about_feature_record_moments",
                                    value: "记录物品的生活瞬间",
                                    comment: ""
                                )
                            )
                            FeatureRow(
                                icon: "house.fill",
                                text: NSLocalizedString(
                                    "about_feature_view_all_items",
                                    value: "在主页查看所有物品",
                                    comment: ""
                                )
                            )
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        Text("© 2026 ruisapp")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                    .padding()
                }
            }
            .navigationTitle(
                NSLocalizedString("title_about_full", value: "关于每事每刻", comment: "")
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(
                        NSLocalizedString("action_close", value: "关闭", comment: "")
                    ) {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                appVersion = version
            } else {
                appVersion = "1.0"
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

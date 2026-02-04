//
//  HomeView.swift
//  Moments
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var babies: [Baby]
    @Query private var groups: [Group]
    @State private var searchText = ""
    @State private var isAddingNewBaby = false
    @State private var selectedGroupFilter: Group? = nil
    @State private var showingGroupManagement = false
    
    var filteredBabies: [Baby] {
        var result = babies
        
        // 按分组过滤
        if let selectedGroup = selectedGroupFilter {
            result = result.filter { $0.group?.id == selectedGroup.id }
        }
        
        // 按搜索文本过滤
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        return result
    }
    
    var groupedBabies: [(Group?, [Baby])] {
        let grouped = Dictionary(grouping: filteredBabies) { $0.group }
        return grouped.sorted { first, second in
            switch (first.key, second.key) {
            case (nil, _):
                return false // 无分组排在最后
            case (_, nil):
                return true
            case let (group1?, group2?):
                return group1.name < group2.name
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 分组选择器
                if !groups.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // 全部分组按钮
                            Button(action: {
                                selectedGroupFilter = nil
                            }) {
                                Text(
                                    NSLocalizedString("filter_all", value: "全部", comment: "")
                                )
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedGroupFilter == nil ? AppColors.selectedBlue : AppColors.grayBackground)
                                    .foregroundColor(selectedGroupFilter == nil ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                            
                            // 分组按钮
                            ForEach(groups, id: \.id) { group in
                                Button(action: {
                                    selectedGroupFilter = group
                                }) {
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(group.displayColor)
                                            .frame(width: 8, height: 8)
                                        Text(group.name)
                                    }
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedGroupFilter?.id == group.id ? group.displayColor.opacity(0.8) : AppColors.grayBackground)
                                    .foregroundColor(selectedGroupFilter?.id == group.id ? .white : .primary)
                                    .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                }
                
                // 主内容区域
                ZStack {
                    if babies.isEmpty {
                        ContentUnavailableView(
                            "",
                            systemImage: "bubbles.and.sparkles",
                            description: Text(
                                NSLocalizedString(
                                    "empty_items_hint_tap_plus",
                                    value: "点击加号添加您的第一个物品",
                                    comment: ""
                                )
                            )
                        )
                    } else if filteredBabies.isEmpty {
                        ContentUnavailableView(
                            NSLocalizedString(
                                "empty_items_title_no_results",
                                value: "没有找到物品",
                                comment: ""
                            ),
                            systemImage: "magnifyingglass",
                            description: Text(
                                NSLocalizedString(
                                    "empty_items_subtitle_try_adjust_filters",
                                    value: "尝试调整搜索条件或分组筛选",
                                    comment: ""
                                )
                            )
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                ForEach(groupedBabies, id: \.0?.id) { group, babies in
                                    GroupSectionView(group: group, babies: babies)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: NSLocalizedString("search_items_placeholder", value: "搜索物品", comment: "")
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingGroupManagement = true }) {
                        Label(
                            NSLocalizedString("menu_group_management", value: "分组管理", comment: ""),
                            systemImage: "folder"
                        )
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isAddingNewBaby = true }) {
                        Label(
                            NSLocalizedString("action_add_item", value: "添加物品", comment: ""),
                            systemImage: "plus"
                        )
                    }
                }
            }
            .sheet(isPresented: $isAddingNewBaby) {
                NavigationStack {
                    BabyEditView()
                }
            }
            .sheet(isPresented: $showingGroupManagement) {
                GroupManagementView()
            }
        }
    }
}

struct BabyGridItem: View {
    let baby: Baby
    
    var body: some View {
        VStack {
            if let path = baby.photoPath, let uiImage = MediaStore.loadImage(from: path, preferThumbnail: true) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 5)
            } else {
                Image(systemName: "bubbles.and.sparkles")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.pink)
                    .frame(width: 150, height: 150)
                    .background(AppColors.lightPinkBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 5)
            }
            
            Text(baby.name)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .padding(.bottom, 5)
        .frame(width: 160)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct GroupSectionView: View {
    let group: Group?
    let babies: [Baby]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 分组标题
            HStack {
                if let group = group {
                    Circle()
                        .fill(group.displayColor)
                        .frame(width: 16, height: 16)
                    Text(group.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                } else {
                    Image(systemName: "folder")
                        .foregroundColor(.gray)
                    Text(
                        NSLocalizedString("label_no_group", value: "未分组", comment: "")
                    )
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("\(babies.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 物品网格
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                ForEach(babies) { baby in
                    NavigationLink(destination: BabyDetailView(baby: baby)) {
                        BabyGridItem(baby: baby)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Baby.self, Moment.self, Group.self], inMemory: true)
}

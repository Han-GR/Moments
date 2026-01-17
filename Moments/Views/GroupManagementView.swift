//
//  GroupManagementView.swift
//  Moments
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import SwiftData

struct GroupManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var groups: [Group]
    
    @State private var showingAddGroup = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groups) { group in
                    GroupRowView(group: group)
                }
                .onDelete(perform: deleteGroups)
            }
            .navigationTitle(
                NSLocalizedString("menu_group_management", value: "分组管理", comment: "")
            )
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(
                        NSLocalizedString("action_done", value: "完成", comment: "")
                    ) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(
                        NSLocalizedString("action_add_group", value: "添加分组", comment: "")
                    ) {
                        showingAddGroup = true
                    }
                }
            }
            .sheet(isPresented: $showingAddGroup) {
                AddGroupView()
            }
        }
    }
    
    private func deleteGroups(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let group = groups[index]
                // 将该分组下的所有婴儿移出分组
                if let babies = group.babies {
                    for baby in babies {
                        baby.group = nil
                    }
                }
                modelContext.delete(group)
            }
            
            do {
                try modelContext.save()
            } catch {
                    // 删除失败，静默处理
                }
        }
    }
}

struct GroupRowView: View {
    let group: Group
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditGroup = false
    
    var body: some View {
        HStack {
            Circle()
                .fill(group.displayColor)
                .frame(width: 20, height: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.headline)
                
                Text(
                    String(
                        format: NSLocalizedString(
                            "group_items_count_format",
                            value: "%d 个物品",
                            comment: ""
                        ),
                        group.babies?.count ?? 0
                    )
                )
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showingEditGroup = true
        }
        .sheet(isPresented: $showingEditGroup) {
            EditGroupView(group: group)
        }
    }
}

// 预定义颜色常量
private let predefinedColors = [
    "#FF69B4", "#87CEEB", "#98FB98", "#FFB6C1",
    "#DDA0DD", "#F0E68C", "#FFA07A", "#20B2AA",
    "#FF6347", "#9370DB", "#32CD32", "#FF1493"
]

struct GroupColorSelectionGrid: View {
    @Binding var selectedColor: String
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
            ForEach(predefinedColors, id: \.self) { color in
                Circle()
                    .fill(Color(hex: color) ?? .pink)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Circle()
                            .stroke(selectedColor == color ? AppColors.primaryText : AppColors.strokeClear, lineWidth: 2)
                    )
                    .onTapGesture {
                        selectedColor = color
                    }
            }
        }
        .padding(.vertical, 8)
    }
}

struct AddGroupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var groupName = ""
    @State private var selectedColor = "#FF69B4"
    @State private var showingDuplicateAlert = false
    
    let onGroupCreated: ((Group) -> Void)?
    
    var body: some View {
        NavigationView {
            Form {
                Section(
                    NSLocalizedString("section_group_info", value: "分组信息", comment: "")
                ) {
                    TextField(
                        NSLocalizedString("field_group_name", value: "分组名称", comment: ""),
                        text: $groupName
                    )
                }
                
                Section(
                    NSLocalizedString("section_select_color", value: "选择颜色", comment: "")
                ) {
                    GroupColorSelectionGrid(selectedColor: $selectedColor)
                }
            }
            .navigationTitle(
                NSLocalizedString("action_add_group", value: "添加分组", comment: "")
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(
                        NSLocalizedString("action_cancel", value: "取消", comment: "")
                    ) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(
                        NSLocalizedString("action_save", value: "保存", comment: "")
                    ) {
                        saveGroup()
                    }
                    .disabled(groupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .alert(
            NSLocalizedString("error_group_name_exists", value: "分组名称已存在", comment: ""),
            isPresented: $showingDuplicateAlert
        ) {
            Button(
                NSLocalizedString("action_ok", value: "确定", comment: ""),
                role: .cancel
            ) { }
        }
    }
    
    init(onGroupCreated: ((Group) -> Void)? = nil) {
        self.onGroupCreated = onGroupCreated
    }
    
    private func saveGroup() {
        let trimmedName = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        // 检查分组名称是否重复
        let existingGroups = try? modelContext.fetch(FetchDescriptor<Group>())
        if let groups = existingGroups, groups.contains(where: { $0.name == trimmedName }) {
            showingDuplicateAlert = true
            return
        }
        
        let newGroup = Group(name: trimmedName, color: selectedColor)
        modelContext.insert(newGroup)
        
        do {
            try modelContext.save()
            onGroupCreated?(newGroup)
            dismiss()
        } catch {
            // 保存失败，静默处理
        }
    }
}

struct EditGroupView: View {
    let group: Group
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var groupName: String
    @State private var selectedColor: String
    @State private var showingDuplicateAlert = false
    
    init(group: Group) {
        self.group = group
        self._groupName = State(initialValue: group.name)
        self._selectedColor = State(initialValue: group.color)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(
                    NSLocalizedString("section_group_info", value: "分组信息", comment: "")
                ) {
                    TextField(
                        NSLocalizedString("field_group_name", value: "分组名称", comment: ""),
                        text: $groupName
                    )
                }
                
                Section(
                    NSLocalizedString("section_select_color", value: "选择颜色", comment: "")
                ) {
                    GroupColorSelectionGrid(selectedColor: $selectedColor)
                }
                
                Section(
                    NSLocalizedString("section_group_members", value: "分组成员", comment: "")
                ) {
                    if let babies = group.babies, !babies.isEmpty {
                        ForEach(babies, id: \.id) { baby in
                            HStack {
                                BabyAvatarView(baby: baby, size: 40)
                                
                                Text(baby.name)
                                    .font(.body)
                                
                                Spacer()
                            }
                        }
                    } else {
                        Text(
                            NSLocalizedString("label_no_members", value: "暂无成员", comment: "")
                        )
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(
                NSLocalizedString("title_edit_group", value: "编辑分组", comment: "")
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(
                        NSLocalizedString("action_cancel", value: "取消", comment: "")
                    ) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(
                        NSLocalizedString("action_save", value: "保存", comment: "")
                    ) {
                        saveChanges()
                    }
                    .disabled(groupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .alert(
            NSLocalizedString("error_group_name_exists", value: "分组名称已存在", comment: ""),
            isPresented: $showingDuplicateAlert
        ) {
            Button(
                NSLocalizedString("action_ok", value: "确定", comment: ""),
                role: .cancel
            ) { }
        }
    }
    
    private func saveChanges() {
        let trimmedName = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        // 检查分组名称是否重复（排除当前分组）
        let existingGroups = try? modelContext.fetch(FetchDescriptor<Group>())
        if let groups = existingGroups, groups.contains(where: { $0.name == trimmedName && $0.id != group.id }) {
            showingDuplicateAlert = true
            return
        }
        
        group.name = trimmedName
        group.color = selectedColor
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            // 保存失败，静默处理
        }
    }
}

struct GroupSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var groups: [Group]
    
    let onGroupSelected: (Group?) -> Void
    @State private var selectedGroup: Group?
    
    var body: some View {
        NavigationView {
            List {
                Button(action: {
                    onGroupSelected(nil)
                    dismiss()
                }) {
                    HStack {
                        Circle()
                            .fill(AppColors.lightGrayBackground)
                            .frame(width: 20, height: 20)
                        
                        Text(
                            NSLocalizedString("label_no_group", value: "无分组", comment: "")
                        )
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if selectedGroup == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(AppColors.selectedBlue)
                        }
                    }
                }
                
                ForEach(groups) { group in
                    Button(action: {
                        onGroupSelected(group)
                        dismiss()
                        }) {
                            HStack {
                            Circle()
                                .fill(group.displayColor)
                                .frame(width: 20, height: 20)
                            
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(group.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text(
                                        String(
                                            format: NSLocalizedString(
                                                "group_items_count_format",
                                                value: "%d 个物品",
                                                comment: ""
                                            ),
                                            group.babies?.count ?? 0
                                        )
                                    )
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedGroup?.id == group.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.selectedBlue)
                            }
                        }
                    }
                }
            }
            .navigationTitle(
                NSLocalizedString("label_select_group", value: "选择分组", comment: "")
            )
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(
                        NSLocalizedString("action_cancel", value: "取消", comment: "")
                    ) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    init(selectedGroup: Group? = nil, onGroupSelected: @escaping (Group?) -> Void) {
        self.selectedGroup = selectedGroup
        self.onGroupSelected = onGroupSelected
    }
}

#Preview {
    GroupManagementView()
        .modelContainer(for: [Baby.self, Moment.self, Group.self], inMemory: true)
}

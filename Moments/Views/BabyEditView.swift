//
//  BabyEditView.swift
//  Moments
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import SwiftData
import UIKit

struct BabyEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var groups: [Group]
    @Query private var existingBabies: [Baby]
    
    @StateObject private var viewModel: BabyEditViewModel
    
    init(baby: Baby? = nil) {
        _viewModel = StateObject(wrappedValue: BabyEditViewModel(baby: baby))
    }
    
    var body: some View {
        Form {
            Section(
                NSLocalizedString("section_photos", value: "照片", comment: "")
            ) {
                VStack {
                    let photoSize: CGFloat = 200
                    let iconSize: CGFloat = 80
                    let cornerRadius: CGFloat = 15
                    
                    if let selectedImage = viewModel.selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: photoSize, height: photoSize)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    } else if let path = viewModel.photoPath {
                        AsyncDiskImage(filename: path, preferThumbnail: true) {
                            Image(systemName: "bubbles.and.sparkles")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: iconSize, height: iconSize)
                                .frame(width: photoSize, height: photoSize)
                                .background(AppColors.lightPinkBackground)
                                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        }
                        .scaledToFill()
                        .frame(width: photoSize, height: photoSize)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    } else {
                        Image(systemName: "bubbles.and.sparkles")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: iconSize, height: iconSize)
                            .frame(width: photoSize, height: photoSize)
                            .background(AppColors.lightPinkBackground)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    }
                    
                    Button(action: {
                        viewModel.isShowingPhotoPicker = true
                    }) {
                        Text(
                            NSLocalizedString("action_add_photo", value: "添加照片", comment: "")
                        )
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .padding(.top, 8)
                    .background(
                        PhotoPickerSheet(
                            selectedImages: Binding(
                                get: { viewModel.selectedImage.map { [$0] } ?? [] },
                                set: { images in
                                    viewModel.selectedImage = images.first
                                }
                            ),
                            isPresented: $viewModel.isShowingPhotoPicker
                        )
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            
            Section(
                NSLocalizedString("section_basic_info", value: "基本信息", comment: "")
            ) {
                TextField(
                    NSLocalizedString("field_name", value: "名字", comment: ""),
                    text: $viewModel.name
                )
                
                CollapsibleDatePickerRow(
                    title: NSLocalizedString("field_birthday", value: "生日", comment: ""),
                    placeholder: NSLocalizedString("label_not_set", value: "未设置", comment: ""),
                    date: $viewModel.birthDate,
                    minimumDate: nil,
                    maximumDate: Date()
                )
            }
            
            Section(
                NSLocalizedString("section_notes", value: "笔记", comment: "")
            ) {
                TextEditor(text: $viewModel.notes)
                    .frame(minHeight: 100)
            }
            
            Section(
                NSLocalizedString("section_group", value: "分组", comment: "")
            ) {
                Menu {
                    Button(
                        NSLocalizedString("label_no_group", value: "无分组", comment: "")
                    ) {
                        viewModel.selectedGroup = nil
                    }
                    
                    if !groups.isEmpty {
                        Divider()
                        
                        // 限制显示的分组数量，避免菜单过长
                        ForEach(groups.prefix(5), id: \.id) { group in
                            Button(action: {
                                viewModel.selectedGroup = group
                            }) {
                                HStack {
                                    Circle()
                                        .fill(group.displayColor)
                                        .frame(width: 12, height: 12)
                                    Text(group.name)
                                        .lineLimit(1)
                                }
                            }
                        }
                        
                        if groups.count > 5 {
                            Button(
                                NSLocalizedString("action_see_more_groups", value: "查看更多分组...", comment: "")
                            ) {
                                viewModel.showingGroupManagement = true
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    Button(action: {
                        viewModel.showingAddGroup = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text(
                                NSLocalizedString("action_new_group", value: "新建分组", comment: "")
                            )
                        }
                    }
                } label: {
                    HStack {
                        Text(
                            NSLocalizedString("label_select_group", value: "选择分组", comment: "")
                        )
                            .foregroundColor(.primary)
                        Spacer()
                        if let selectedGroup = viewModel.selectedGroup {
                            HStack {
                                Circle()
                                    .fill(selectedGroup.displayColor)
                                    .frame(width: 12, height: 12)
                                Text(selectedGroup.name)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            Text(
                                NSLocalizedString("label_no_group", value: "无分组", comment: "")
                            )
                                .foregroundColor(.secondary)
                        }
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
            }
        }
        .navigationTitle(
            viewModel.isEditing
                ? NSLocalizedString("title_edit_item", value: "编辑物品", comment: "")
                : NSLocalizedString("action_add_item", value: "添加物品", comment: "")
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
                    viewModel.save(modelContext: modelContext, existingBabies: existingBabies)
                }
                .disabled(viewModel.name.isEmpty)
            }
        }
        .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
        .alert(
            NSLocalizedString("error_item_name_exists", value: "物品名字已存在", comment: ""),
            isPresented: $viewModel.showingDuplicateAlert
        ) {
            Button(
                NSLocalizedString("action_ok", value: "确定", comment: ""),
                role: .cancel
            ) { }
        }
        .alert(isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Alert(
                title: Text(NSLocalizedString("error_title", value: "错误", comment: "")),
                message: Text(viewModel.errorMessage ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $viewModel.showingAddGroup) {
            AddGroupView { newGroup in
                viewModel.selectedGroup = newGroup
                viewModel.showingAddGroup = false
            }
        }
        .sheet(isPresented: $viewModel.showingGroupManagement) {
            GroupSelectionView(selectedGroup: viewModel.selectedGroup) { group in
                viewModel.selectedGroup = group
            }
        }
    }
}

#Preview {
    NavigationStack {
        BabyEditView()
            .modelContainer(for: [Baby.self, Moment.self, Group.self], inMemory: true)
    }
}

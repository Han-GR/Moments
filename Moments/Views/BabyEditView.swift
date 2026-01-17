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
    
    @State private var name = ""
    @State private var birthDate: Date? = nil
    @State private var notes = ""
    @State private var photoPath: String? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var isShowingPhotoPicker = false
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingCameraAlert = false
    @State private var showingDuplicateAlert = false
    @State private var selectedGroup: Group? = nil
    @State private var showingAddGroup = false
    @State private var showingGroupManagement = false
    
    var baby: Baby? = nil
    
    var isEditing: Bool {
        baby != nil
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
                    
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .frame(width: photoSize, height: photoSize)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    } else if let path = photoPath, let uiImage = MediaStore.loadImage(from: path, preferThumbnail: true) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
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
                        isShowingPhotoPicker = true
                    }) {
                        Text(
                            NSLocalizedString("action_add_photo", value: "添加照片", comment: "")
                        )
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .padding(.top, 8)
                    .confirmationDialog(
                        NSLocalizedString("dialog_select_photo_title", value: "选择照片", comment: ""),
                        isPresented: $isShowingPhotoPicker,
                    ) {
                        Button(
                            NSLocalizedString("action_take_photo", value: "拍照", comment: "")
                        ) {
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                sourceType = .camera
                                showingImagePicker = true
                            } else {
                                showingCameraAlert = true
                            }
                        }
                        
                        Button(
                            NSLocalizedString("action_choose_from_library", value: "从相册选择", comment: "")
                        ) {
                            sourceType = .photoLibrary
                            showingImagePicker = true
                        }
                        
                        Button(
                            NSLocalizedString("action_cancel", value: "取消", comment: ""),
                            role: .cancel
                        ) {
                            isShowingPhotoPicker = false
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            
            Section(
                NSLocalizedString("section_basic_info", value: "基本信息", comment: "")
            ) {
                TextField(
                    NSLocalizedString("field_name", value: "名字", comment: ""),
                    text: $name
                )
                
                CollapsibleDatePickerRow(
                    title: NSLocalizedString("field_birthday", value: "生日", comment: ""),
                    placeholder: NSLocalizedString("label_not_set", value: "未设置", comment: ""),
                    date: $birthDate,
                    minimumDate: nil,
                    maximumDate: Date()
                )
            }
            
            Section(
                NSLocalizedString("section_notes", value: "笔记", comment: "")
            ) {
                TextEditor(text: $notes)
                    .frame(minHeight: 100)
            }
            
            Section(
                NSLocalizedString("section_group", value: "分组", comment: "")
            ) {
                Menu {
                    Button(
                        NSLocalizedString("label_no_group", value: "无分组", comment: "")
                    ) {
                        selectedGroup = nil
                    }
                    
                    if !groups.isEmpty {
                        Divider()
                        
                        // 限制显示的分组数量，避免菜单过长
                        ForEach(groups.prefix(5), id: \.id) { group in
                            Button(action: {
                                selectedGroup = group
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
                                showingGroupManagement = true
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    Button(action: {
                        showingAddGroup = true
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
                        if let selectedGroup = selectedGroup {
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
            isEditing
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
                    saveBaby()
                }
                .disabled(name.isEmpty)
            }
        }
        .onAppear {
            if let baby = baby {
                name = baby.name
                birthDate = baby.birthDate
                notes = baby.notes
                photoPath = baby.photoPath
                selectedGroup = baby.group
            }
        }

        .onChange(of: selectedImage) { _, _ in }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(
                selectedImages: Binding(
                    get: { selectedImage.map { [$0] } ?? [] },
                    set: { images in
                        selectedImage = images.first
                    }
                ),
                sourceType: sourceType,
                allowsMultipleSelection: false
            )
        }
        .alert(
            NSLocalizedString("camera_unavailable_title", value: "相机不可用", comment: ""),
            isPresented: $showingCameraAlert
        ) {
            Button(
                NSLocalizedString("action_ok", value: "确定", comment: ""),
                role: .cancel
            ) { }
        } message: {
            Text(
                NSLocalizedString(
                    "camera_not_supported_message",
                    value: "此设备不支持相机功能",
                    comment: ""
                )
            )
        }
        .alert(
            NSLocalizedString("error_item_name_exists", value: "物品名字已存在", comment: ""),
            isPresented: $showingDuplicateAlert
        ) {
            Button(
                NSLocalizedString("action_ok", value: "确定", comment: ""),
                role: .cancel
            ) { }
        }
        .sheet(isPresented: $showingAddGroup) {
            AddGroupView { newGroup in
                selectedGroup = newGroup
                showingAddGroup = false
            }
        }
        .sheet(isPresented: $showingGroupManagement) {
                GroupSelectionView(selectedGroup: selectedGroup) { group in
                    selectedGroup = group
                }
            }
    }
    
    private func saveBaby() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 检查名字是否重复
        let isDuplicate: Bool
        if let currentBaby = baby {
            // 编辑模式：检查是否有其他物品使用了相同名字
            isDuplicate = existingBabies.contains { $0.id != currentBaby.id && $0.name == trimmedName }
        } else {
            // 添加模式：检查是否有物品使用了相同名字
            isDuplicate = existingBabies.contains { $0.name == trimmedName }
        }
        
        if isDuplicate {
            showingDuplicateAlert = true
            return
        }
        
        if let baby = baby {
            // 更新现有的物品
            baby.name = trimmedName
            baby.birthDate = birthDate
            baby.notes = notes
            baby.group = selectedGroup
            if let selectedImage = selectedImage {
                if let filename = MediaStore.saveImage(selectedImage, quality: 0.85) {
                    _ = MediaStore.saveThumbnail(of: selectedImage, basedOn: filename)
                    baby.photoPath = filename
                }
            }
        } else {
            // 创建新的物品
            var finalPath: String? = nil
            if let selectedImage = selectedImage {
                finalPath = MediaStore.saveImage(selectedImage, quality: 0.85)
                if let name = finalPath {
                    _ = MediaStore.saveThumbnail(of: selectedImage, basedOn: name)
                }
            }
            let newBaby = Baby(name: trimmedName, birthDate: birthDate, photoPath: finalPath, notes: notes)
            newBaby.group = selectedGroup
            modelContext.insert(newBaby)
        }
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
                // 保存失败，静默处理
            }
    }
}

#Preview {
    NavigationStack {
        BabyEditView()
            .modelContainer(for: [Baby.self, Moment.self, Group.self], inMemory: true)
    }
}

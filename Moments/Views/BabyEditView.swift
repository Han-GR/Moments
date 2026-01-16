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
    @State private var showDatePicker = false
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
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        
        Form {
            Section("照片") {
                VStack {
                    let photoSize: CGFloat = isIPad ? 280 : 200
                    let iconSize: CGFloat = isIPad ? 120 : 80
                    let cornerRadius: CGFloat = isIPad ? 20 : 15
                    
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
                        Text("添加照片")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(isIPad ? .large : .large)
                    .padding(.top, isIPad ? 12 : 8)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, isIPad ? 12 : 8)
            }
            
            Section("基本信息") {
                TextField("名字", text: $name)
                
                HStack {
                    Text("生日")
                    Spacer()
                    if let birthDate = birthDate {
                        Text(birthDate, style: .date)
                            .foregroundColor(.secondary)
                    } else {
                        Text("未设置")
                            .foregroundColor(.secondary)
                    }
                    Button(action: { showDatePicker.toggle() }) {
                        Image(systemName: "calendar")
                    }
                }
                
                if showDatePicker {
                    DatePicker(
                        "选择生日",
                        selection: Binding(
                            get: { birthDate ?? Date() },
                            set: { birthDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                }
            }
            
            Section("笔记") {
                TextEditor(text: $notes)
                    .frame(minHeight: 100)
            }
            
            Section("分组") {
                Menu {
                    Button("无分组") {
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
                            Button("查看更多分组...") {
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
                            Text("新建分组")
                        }
                    }
                } label: {
                    HStack {
                        Text("选择分组")
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
                            Text("无分组")
                                .foregroundColor(.secondary)
                        }
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
            }
            

        }
        .navigationTitle(isEditing ? "编辑物品" : "添加物品")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("取消") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
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
        .confirmationDialog("选择照片", isPresented: $isShowingPhotoPicker, titleVisibility: .visible) {
            Button("拍照") {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    sourceType = .camera
                    showingImagePicker = true
                } else {
                    showingCameraAlert = true
                }
            }
            
            Button("从相册选择") {
                sourceType = .photoLibrary
                showingImagePicker = true
            }
            
            Button("取消", role: .cancel) {
                isShowingPhotoPicker = false
            }
        }
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
        .alert("相机不可用", isPresented: $showingCameraAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text("此设备不支持相机功能")
        }
        .alert("物品名字已存在", isPresented: $showingDuplicateAlert) {
            Button("确定", role: .cancel) { }
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

//
//  BabyEditView.swift
//  Moments
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import SwiftData

struct BabyEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var groups: [Group]
    
    @State private var name = ""
    @State private var birthDate: Date? = nil
    @State private var notes = ""
    @State private var photoData: Data? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var showDatePicker = false
    @State private var isShowingPhotoPicker = false
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingCameraAlert = false
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
                    
                    if let photoData = photoData, let uiImage = UIImage(data: photoData) {
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
        .navigationTitle(isEditing ? "编辑阿贝贝" : "添加阿贝贝")
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
                    dismiss()
                }
                .disabled(name.isEmpty)
            }
        }
        .onAppear {
            if let baby = baby {
                name = baby.name
                birthDate = baby.birthDate
                notes = baby.notes
                photoData = baby.photo
                selectedGroup = baby.group
            }
        }

        .onChange(of: selectedImage) { _, newImage in
            if let image = newImage {
                photoData = image.jpegData(compressionQuality: 0.8)
                selectedImage = nil
            }
        }
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
        if let baby = baby {
            // 更新现有的阿贝贝
            baby.name = name
            baby.birthDate = birthDate
            baby.notes = notes
            baby.photo = photoData
            baby.group = selectedGroup
        } else {
            // 创建新的阿贝贝
            let newBaby = Baby(name: name, birthDate: birthDate, photo: photoData, notes: notes)
            newBaby.group = selectedGroup
            modelContext.insert(newBaby)
        }
        
        do {
            try modelContext.save()
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
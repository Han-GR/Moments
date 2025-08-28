//
//  MomentEditView.swift
//  AiBaBy
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import SwiftData

struct MomentEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var allBabies: [Baby]
    
    // 如果传入了特定的阿贝贝，则默认选择该阿贝贝
    var baby: Baby?
    // 如果传入了moment，则为编辑模式
    var moment: Moment?
    

    @State private var content = ""
    @State private var date = Date()
    @State private var selectedBaby: Baby?
    @State private var selectedPhotosData: [Data] = []
    @State private var selectedImages: [UIImage] = []
    @State private var isShowingBabyPicker = false
    @State private var isShowingPhotoPicker = false
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingCameraAlert = false
    
    var body: some View {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        
        Form {
            Section("阿贝贝") {
                HStack {
                    if let selectedBaby = selectedBaby {
                        HStack {
                            BabyAvatarView.medium(baby: selectedBaby)
                            
                            Text(selectedBaby.name)
                                .font(.headline)
                        }
                    } else {
                        Text("选择阿贝贝")
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        isShowingBabyPicker = true
                    }) {
                        Text(selectedBaby == nil ? "选择" : "更改")
                    }
                }
            }
            

            
            Section("日期") {
                DatePicker("选择日期", selection: $date, displayedComponents: [.date])
                    .datePickerStyle(.compact)
            }
            
            Section("瞬间内容") {
                TextEditor(text: $content)
                    .frame(minHeight: 100)
            }
            
            Section("照片") {
                Button(action: {
                    isShowingPhotoPicker = true
                }) {
                    Label("添加照片", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
                
                if !selectedPhotosData.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: isIPad ? 15 : 10) {
                            ForEach(0..<selectedPhotosData.count, id: \.self) { index in
                                if let uiImage = UIImage(data: selectedPhotosData[index]) {
                                    let imageSize: CGFloat = isIPad ? 140 : 100
                                    let cornerRadius: CGFloat = isIPad ? 12 : 8
                                    
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(1, contentMode: .fill)
                                            .frame(width: imageSize, height: imageSize)
                                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                                        
                                        Button(action: {
                                            selectedPhotosData.remove(at: index)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .background(AppColors.blackOverlay)
                                                .clipShape(Circle())
                                                .padding(isIPad ? 6 : 4)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, isIPad ? 8 : 5)
                    }
                }
            }
        }
        .navigationTitle(moment != nil ? "编辑生活瞬间" : "记录生活瞬间")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("取消") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    saveMoment()
                }
                .disabled(selectedBaby == nil || (content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedPhotosData.isEmpty))
            }
        }
        .onAppear {
            // 如果是编辑模式，初始化现有数据
            if let moment = moment {
                content = moment.content
                date = moment.date
                selectedBaby = moment.baby
                if let photos = moment.photos {
                    selectedPhotosData = photos
                }
            } else {
                // 如果传入了特定的阿贝贝，则默认选择该阿贝贝
                if let baby = baby {
                    selectedBaby = baby
                } else if let firstBaby = allBabies.first {
                    // 如果没有传入特定的阿贝贝，则默认选择第一个阿贝贝
                    selectedBaby = firstBaby
                }
            }
        }

        .onChange(of: selectedImages) { _, newImages in
            for image in newImages {
                if let data = image.jpegData(compressionQuality: 0.8) {
                    selectedPhotosData.append(data)
                }
            }
            selectedImages.removeAll()
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
                selectedImages: $selectedImages,
                sourceType: sourceType,
                allowsMultipleSelection: sourceType == .photoLibrary
            )
        }
        .alert("相机不可用", isPresented: $showingCameraAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text("此设备不支持相机功能")
        }
        .sheet(isPresented: $isShowingBabyPicker) {
            NavigationStack {
                List(allBabies) { baby in
                    Button(action: {
                        selectedBaby = baby
                        isShowingBabyPicker = false
                    }) {
                        HStack {
                            BabyAvatarView.medium(baby: baby)
                            
                            Text(baby.name)
                                .font(.headline)
                            
                            Spacer()
                            
                            if selectedBaby?.id == baby.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .navigationTitle("选择阿贝贝")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("取消") {
                            isShowingBabyPicker = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
    
    private func saveMoment() {
        guard let selectedBaby = selectedBaby else { return }
        
        if let existingMoment = moment {
            // 编辑模式：更新现有瞬间
            existingMoment.content = content
            existingMoment.date = date
            existingMoment.baby = selectedBaby
            existingMoment.photos = selectedPhotosData.isEmpty ? nil : selectedPhotosData
        } else {
            // 新建模式：创建新瞬间
            let newMoment = Moment(
                content: content,
                date: date,
                photos: selectedPhotosData.isEmpty ? nil : selectedPhotosData
            )
            
            // 设置关系
            newMoment.baby = selectedBaby
            
            // 添加到数据库
            modelContext.insert(newMoment)
        }
        
        // 立即保存更改
        do {
            try modelContext.save()
        } catch {
            // 保存失败，静默处理
        }
        
        // 关闭视图
        dismiss()
    }
}

#Preview {
    NavigationStack {
        MomentEditView()
            .modelContainer(for: [Baby.self, Moment.self], inMemory: true)
    }
}
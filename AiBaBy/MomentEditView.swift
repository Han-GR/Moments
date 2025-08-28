//
//  MomentEditView.swift
//  AiBaBy
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import SwiftData
import PhotosUI

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
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedPhotosData: [Data] = []
    @State private var selectedImages: [UIImage] = []
    @State private var isShowingBabyPicker = false
    @State private var isShowingPhotoPicker = false
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingCameraAlert = false
    
    var body: some View {
        Form {
            Section("阿贝贝") {
                HStack {
                    if let selectedBaby = selectedBaby {
                        HStack {
                            if let photoData = selectedBaby.photo, let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "bubbles.and.sparkles")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .padding(10)
                                    .background(Color.pink.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            
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
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
                
                if !selectedPhotosData.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(0..<selectedPhotosData.count, id: \.self) { index in
                                if let uiImage = UIImage(data: selectedPhotosData[index]) {
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(1, contentMode: .fill)
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        
                                        Button(action: {
                                            selectedPhotosData.remove(at: index)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .background(Color.black.opacity(0.7))
                                                .clipShape(Circle())
                                                .padding(4)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 5)
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
        .onChange(of: selectedItems) { _, newItems in
            Task {
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            selectedPhotosData.append(data)
                        }
                    }
                }
                // 清空选择
                await MainActor.run {
                    selectedItems = []
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
                            if let photoData = baby.photo, let uiImage = UIImage(data: photoData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "bubbles.and.sparkles")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .padding(10)
                                    .background(Color.pink.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            
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
            print("保存瞬间失败: \(error)")
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
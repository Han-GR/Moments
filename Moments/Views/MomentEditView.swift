//
//  MomentEditView.swift
//  Moments
//
//  Created by han han on 2025/8/24.
//

import SwiftUI
import SwiftData
import UIKit

struct MomentEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var allBabies: [Baby]
    
    // 如果传入了特定的物品，则默认选择该物品
    var baby: Baby?
    // 如果传入了moment，则为编辑模式
    var moment: Moment?
    

    @State private var content = ""
    @State private var date = Date()
    @State private var selectedBaby: Baby?
    @State private var selectedImages: [UIImage] = []
    @State private var isProcessingImages = false
    @State private var isShowingBabyPicker = false
    @State private var isShowingPhotoPicker = false
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingCameraAlert = false
    
    var body: some View {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        
        Form {
            Section("物品（可选）") {
                HStack {
                    if let selectedBaby = selectedBaby {
                        HStack {
                            BabyAvatarView.medium(baby: selectedBaby)
                            
                            Text(selectedBaby.name)
                                .font(.headline)
                        }
                    } else {
                        Text("无物品")
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
                    if selectedImages.count < 9 {
                        isShowingPhotoPicker = true
                    }
                }) {
                    Label(selectedImages.count >= 9 ? "已达到最大数量(9张)" : "添加照片 (\(selectedImages.count)/9)", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(selectedImages.count >= 9 ? .gray : .blue)
                        .cornerRadius(8)
                }
                .disabled(selectedImages.count >= 9)
                
                if !selectedImages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: isIPad ? 15 : 10) {
                            ForEach(0..<selectedImages.count, id: \.self) { index in
                                let uiImage = selectedImages[index]
                                let imageSize: CGFloat = isIPad ? 140 : 100
                                let cornerRadius: CGFloat = isIPad ? 12 : 8
                                
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fill)
                                        .frame(width: imageSize, height: imageSize)
                                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                                    
                                    Button(action: {
                                        selectedImages.remove(at: index)
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
                .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedImages.isEmpty)
            }
        }
        .onAppear {
            // 如果是编辑模式，加载现有数据
            if let moment = moment {
                content = moment.content
                date = moment.date
                selectedBaby = moment.baby
                if let items = moment.mediaItems {
                    let photos = items.filter { $0.type == .photo || $0.type == .livePhoto }
                    selectedImages = photos.compactMap { MediaStore.loadImage(from: $0.originalPath) }
                }
            } else {
                // 新建模式：如果传入了特定物品则选择，否则保持为nil
                if let baby = baby {
                    selectedBaby = baby
                }
                // 不再自动选择第一个物品，让用户自主选择
            }
        }

        .onChange(of: selectedImages) { _, _ in }
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
                List {
                    // 无物品选项
                    Button(action: {
                        selectedBaby = nil
                        isShowingBabyPicker = false
                    }) {
                        HStack {
                            Image(systemName: "person.slash")
                                .foregroundColor(.gray)
                                .frame(width: 40, height: 40)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(Circle())
                            
                            Text("无物品")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedBaby == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // 物品列表
                    ForEach(allBabies) { baby in
                        Button(action: {
                            selectedBaby = baby
                            isShowingBabyPicker = false
                        }) {
                            HStack {
                                BabyAvatarView.medium(baby: baby)
                                
                                Text(baby.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if selectedBaby?.id == baby.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .navigationTitle("选择物品")
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
        if let existingMoment = moment {
            // 编辑模式：更新现有瞬间
            existingMoment.content = content
            existingMoment.date = date
            existingMoment.baby = selectedBaby // 可以为nil
            if let items = existingMoment.mediaItems {
                for item in items {
                    modelContext.delete(item)
                }
                existingMoment.mediaItems = []
            }
            let newItems: [MomentMedia] = selectedImages.compactMap { img in
                guard let filename = MediaStore.saveImage(img, quality: 0.85) else { return nil }
                let thumb = MediaStore.saveThumbnail(of: img, basedOn: filename)
                let media = MomentMedia(type: .photo, originalPath: filename, thumbnailPath: thumb)
                media.moment = existingMoment
                return media
            }
            existingMoment.mediaItems = newItems
        } else {
            // 新建模式：创建新瞬间
            let newMoment = Moment(content: content, date: date)
            
            // 设置关系（可以为nil）
            newMoment.baby = selectedBaby
            
            let newItems: [MomentMedia] = selectedImages.compactMap { img in
                guard let filename = MediaStore.saveImage(img, quality: 0.85) else { return nil }
                let thumb = MediaStore.saveThumbnail(of: img, basedOn: filename)
                let media = MomentMedia(type: .photo, originalPath: filename, thumbnailPath: thumb)
                media.moment = newMoment
                return media
            }
            newMoment.mediaItems = newItems
            
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

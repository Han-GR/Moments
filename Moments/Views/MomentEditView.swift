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
    @State private var selectedMedia: [PickerMediaItem] = []
    @State private var isProcessingImages = false
    @State private var isShowingBabyPicker = false
    @State private var isShowingPhotoPicker = false
    @State private var showingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingCameraAlert = false
    @State private var previewVideoURL: URL?
    @State private var isShowingVideoPlayer = false
    
    var body: some View {
        formContent
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
                    .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedMedia.isEmpty)
                }
            }
            .onAppear(perform: loadData)
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
                    selectedMedia: $selectedMedia,
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
                BabyPickerSheet(selectedBaby: $selectedBaby, isPresented: $isShowingBabyPicker, allBabies: allBabies)
            }
            .sheet(isPresented: $isShowingVideoPlayer) {
                if let url = previewVideoURL {
                    VideoPlayerItemView(url: url)
                } else {
                    Text("无法加载视频")
                }
            }
    }
    
    private var formContent: some View {
        Form {
            babySection
            dateSection
            contentSection
            photosSection()
        }
    }

    private func loadData() {
        // 如果是编辑模式，加载现有数据
        if let moment = moment {
            content = moment.content
            date = moment.date
            selectedBaby = moment.baby
            if let items = moment.mediaItems {
                selectedMedia = items.compactMap { media in
                    // 加载缩略图或原图用于显示
                    if let image = MediaStore.loadImage(from: media.thumbnailPath ?? media.originalPath, preferThumbnail: true) {
                        var videoURL: URL? = nil
                        if media.type == .video {
                            videoURL = MediaStore.videoURL(for: media.originalPath)
                        }
                        return PickerMediaItem(
                            image: image,
                            type: media.type,
                            videoURL: videoURL,
                            originalFilename: media.originalPath
                        )
                    }
                    return nil
                }
            }
        } else {
            // 新建模式：如果传入了特定物品则选择，否则保持为nil
            if let baby = baby {
                selectedBaby = baby
            }
            // 不再自动选择第一个物品，让用户自主选择
        }
    }
    
    private var babySection: some View {
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
    }
    
    private var dateSection: some View {
        Section("日期") {
            DatePicker("选择日期", selection: $date, displayedComponents: [.date])
                .datePickerStyle(.compact)
        }
    }
    
    private var contentSection: some View {
        Section("瞬间内容") {
            TextEditor(text: $content)
                .frame(minHeight: 100)
        }
    }
    
    private func photosSection() -> some View {
        Section("照片") {
            Button(action: {
                if selectedMedia.count < 9 {
                    isShowingPhotoPicker = true
                }
            }) {
                Label(
                    selectedMedia.count >= 9 ? "已达到最大数量(9张)" : "添加照片/视频 (\(selectedMedia.count)/9)",
                    systemImage: "plus.circle.fill"
                )
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(selectedMedia.count >= 9 ? .gray : .blue)
                .cornerRadius(8)
            }
            .disabled(selectedMedia.count >= 9)
            
            if !selectedMedia.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(selectedMedia) { item in
                            let imageSize: CGFloat = 100
                            let cornerRadius: CGFloat = 8
                            
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: item.image)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(width: imageSize, height: imageSize)
                                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                                
                                if item.type == .video {
                                    Image(systemName: "play.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .shadow(radius: 2)
                                        .padding(4)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                } else if item.type == .livePhoto {
                                    Image(systemName: "livephoto")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .shadow(radius: 2)
                                        .padding(4)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                }
                                
                                Button(action: {
                                    if let index = selectedMedia.firstIndex(where: { $0.id == item.id }) {
                                        selectedMedia.remove(at: index)
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .background(AppColors.blackOverlay)
                                        .clipShape(Circle())
                                        .padding(4)
                                }
                            }
                            .onTapGesture {
                                if item.type == .video {
                                    if let url = item.videoURL {
                                        previewVideoURL = url
                                        isShowingVideoPlayer = true
                                    } else if let filename = item.originalFilename {
                                        previewVideoURL = MediaStore.videoURL(for: filename)
                                        isShowingVideoPlayer = true
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
            let newItems: [MomentMedia] = selectedMedia.compactMap { item in
                // 如果是已有文件，直接复用
                if let originalFilename = item.originalFilename {
                    let thumb = MediaStore.thumbnailName(for: originalFilename)
                    let media = MomentMedia(type: item.type, originalPath: originalFilename, thumbnailPath: thumb)
                    media.moment = existingMoment
                    return media
                }
                
                // 新文件
                if item.type == .video, let videoURL = item.videoURL {
                    guard let filename = MediaStore.saveVideo(from: videoURL) else { return nil }
                    _ = MediaStore.generateVideoThumbnail(for: filename)
                    let thumb = MediaStore.thumbnailName(for: filename)
                    let media = MomentMedia(type: .video, originalPath: filename, thumbnailPath: thumb)
                    media.moment = existingMoment
                    return media
                } else {
                    // 图片或Live Photo (静态部分)
                    guard let filename = MediaStore.saveImage(item.image, quality: 0.85) else { return nil }
                    let thumb = MediaStore.saveThumbnail(of: item.image, basedOn: filename)
                    // 如果是 Live Photo，保留类型标记
                    let finalType: MomentMedia.MediaType = (item.type == .livePhoto) ? .livePhoto : .photo
                    let media = MomentMedia(type: finalType, originalPath: filename, thumbnailPath: thumb)
                    media.moment = existingMoment
                    return media
                }
            }
            existingMoment.mediaItems = newItems
        } else {
            // 新建模式：创建新瞬间
            let newMoment = Moment(content: content, date: date)
            
            // 设置关系（可以为nil）
            newMoment.baby = selectedBaby
            
            let newItems: [MomentMedia] = selectedMedia.compactMap { item in
                if item.type == .video, let videoURL = item.videoURL {
                    guard let filename = MediaStore.saveVideo(from: videoURL) else { return nil }
                    _ = MediaStore.generateVideoThumbnail(for: filename)
                    let thumb = MediaStore.thumbnailName(for: filename)
                    let media = MomentMedia(type: .video, originalPath: filename, thumbnailPath: thumb)
                    media.moment = newMoment
                    return media
                } else {
                    guard let filename = MediaStore.saveImage(item.image, quality: 0.85) else { return nil }
                    let thumb = MediaStore.saveThumbnail(of: item.image, basedOn: filename)
                    let finalType: MomentMedia.MediaType = (item.type == .livePhoto) ? .livePhoto : .photo
                    let media = MomentMedia(type: finalType, originalPath: filename, thumbnailPath: thumb)
                    media.moment = newMoment
                    return media
                }
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

struct BabyPickerSheet: View {
    @Binding var selectedBaby: Baby?
    @Binding var isPresented: Bool
    let allBabies: [Baby]
    
    var body: some View {
        NavigationStack {
            List {
                Button(action: {
                    selectedBaby = nil
                    isPresented = false
                }) {
                    HStack {
                        Text("无物品")
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedBaby == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                ForEach(allBabies) { baby in
                    Button(action: {
                        selectedBaby = baby
                        isPresented = false
                    }) {
                        HStack {
                            BabyAvatarView.small(baby: baby)
                            Text(baby.name)
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedBaby?.id == baby.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("选择物品")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        isPresented = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    NavigationStack {
        MomentEditView()
            .modelContainer(for: [Baby.self, Moment.self], inMemory: true)
    }
}
